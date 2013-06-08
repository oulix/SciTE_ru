--[[--------------------------------------------------
abbrevlist.lua
Authors: Dmitry Maslov, frs, mozers? Tymur Gubayev
version 3.4.17
------------------------------------------------------
  Если пр?вставк?расшифровк?аббревиатуры (Ctrl+B) не нашлос?точног?соответств?,
  то выводится список соответствий начинающих? ?этой комбинации символов.
  Возможен автоматический режи?работы (появление списка бе?нажатия на Ctrl+B).
  Он включает? параметром abbrev.lexer.auto=3,
        гд?lexer - имя соответствующего лексер?
              ?3 - min длин?введенно?строки пр?которо?он?буде?анализироваться ка?аббревиатура

  Если ?расшифровк?аббревиатуры задано нескольк?курсорны?мето? то посл?вставк?расшифровк?курсор устанавливается на первую из ни?
  На вс?остальны?устанавливаются невидимы?метк? перехо?по которы?осуществ?ет? клавишей Tab.
  Пр?установк?параметр?abbrev.multitab.clear.manual=1 скрипт не очищае?метк?табу?торо?посл?перемещения на ни?по Tab. Их пользователь удаляет вручну?комбинацие?Ctrl+Tab.
  Параметр abbrev.multitab.indic.style=#FF6600,diagonal позволяет показывать метк?табу?торо?заданным стилем (значен? задают? та?же ка??параметрах indic.style.number)
  Установк?параметр?abbrev.lexer.ignore.comment=1 разрешае?скрипт?игнорировать символ комментария ?файлах аббревиату?для указанны?лексеров (?? вс?закомментированные строки буду?воспринимать? ка?обычны?аббревиатуры ?начальны?символом #)
  Параметром abbrev.list.width можн?задать максимальную ширину раскрывающегося списка расшифрово?аббревиату?(?символах)
  Параметром abbrev.lexer.prev.chars можн?задать индивидуальный для избранного лексер?список символов, отличный от дефолтовог?набора ' ([{<', которы?предшествуют аббревиатуре. Учтите, чт?эт?символ?уж?нель? буде?включать ?состав аббревиату?

  Предупреждение:
  Встроенные функци?SciTE (Ctrl+B, Ctrl+Shift+R), которы?заме?ет скрипт, работают совершенно инач?
  Поэтом?файл?сокращений от оригинальног?SciTE подлежат внимательном?пересмотру.

  Подключени?
    ?файл SciTEStartup.lua добавьте строку:
    dofile (props["SciteDefaultHome"].."\\tools\\abbrevlist.lua")
--]]--------------------------------------------------

local table_abbr_exp = {}     -- полный список аббревиату??расшифрово??ни?
local table_user_list = {}    -- список подходящи??текущему тексту аббревиату??расшифрово??ни?
local get_abbrev = true       -- призна?того, чт?этот список надо пересоздат?
local chars_count_min = 0     -- min длин?введенно?строки пр?которо?он?буде?анализироваться
local sep = '\1'              -- разделител?для строки раскрывающегося списка
local typeUserList = 11       -- идентификато?раскрывающегося списка
local smart_tab = 0           -- ко?во дополнительных позици?табу?ци?(невидимы?маркеров)
local cr = string.char(1)     -- символ для временно?подмен?метк?курсор?|
local clearmanual = tonumber(props['abbrev.multitab.clear.manual']) == 1
local abbrev_length = 0       -- длин?аббревиатуры
local prev_chars = ' ([{<'    -- символ?которы?предшествуют аббревиатуре

-- Возвращает номе?свободного маркер??присваивае?ем?атрибу?"невидимы?
local function SetHiddenMarker()
	for indic_number = 0, 31 do
		local mark = props["indic.style."..indic_number]
		if mark == "" then
			local indic_style = props["abbrev.multitab.indic.style"]
			if indic_style == '' then
				props["indic.style."..indic_number] = "hidden"
			else
				props["indic.style."..indic_number] = indic_style
			end
			return indic_number
		end
	end
end
local num_hidden_indic = SetHiddenMarker()   -- номе?маркер?позици?курсор?(для обхода по TAB)

-- Чтение всех подключенных abbrev-файлов ?таблиц?table_abbr_exp
local function CreateExpansionList()
	local abbrev_filename = props["AbbrevPath"]
	if abbrev_filename == '' then return end
	table_abbr_exp = ReadAbbrevFile(abbrev_filename) or {}
	for k,v in pairs(table_abbr_exp) do
		v.abbr = v.abbr:utf8upper()
		v.exp = v.exp:gsub('\t','\\t')
	end
end

-- Вставк?расшифровк? из раскрывающегося списка
local function InsertExpansion(expansion, abbrev_length)
	if not abbrev_length then abbrev_length = 0 end
	editor:BeginUndoAction()
	-- удаление введенно?аббревиатуры ?сохранение?выделения
	local sel_start, sel_end = editor.SelectionStart - abbrev_length, editor.SelectionEnd - abbrev_length
	if abbrev_length > 0 then
		editor:remove(sel_start, editor.SelectionStart)
		editor:SetSel(sel_start, sel_end)
		abbrev_length = 0
	end
	-- вставк?расшифровк?c замено?всех мето?курсор?| (кром?первой) на символ cr
	expansion = expansion:gsub("|", cr):gsub(cr..cr, "||"):gsub(cr, "|", 1)
	local _, tab_count = expansion:gsub(cr, cr) -- опреде?ем ко?во дополнительных мето?курсор?
	local before_length = editor.Length
	scite.InsertAbbreviation(expansion)
	--------------------------------------------------
	if tab_count>0 then -- если есть дополнительные метк?курсор?
		local start_pos = editor.CurrentPos
		local end_pos = sel_end + editor.Length - before_length
		if clearmanual then
			EditorMarkText(start_pos-1, 1, num_hidden_indic)
		else
			EditorClearMarks(num_hidden_indic) -- если от предыдущей вставк?остались маркер?(пользователь заполнил не вс?по?), то удаляем их
		end

		repeat -- убирае?символ?# из расшифровк? ставя вместо ни?невидимы?маркер?
			local tab_start = editor:findtext(cr, 0, end_pos, start_pos)
			if not tab_start then break end
			editor:GotoPos(tab_start+1)  editor:DeleteBack()
			EditorMarkText(tab_start-1, 1, num_hidden_indic)
			end_pos = tab_start-1
		until false

		editor:GotoPos(start_pos)
		smart_tab = tab_count -- разрешае?особую обработк?нажатия на TAB (по событи?OnKey)
	end
	--------------------------------------------------
	editor:EndUndoAction()
end
-- export global
scite_InsertAbbreviation = InsertExpansion

-- Пока?списка из расшифрово? соответствующи?введенно?аббревиатуре
local function ShowExpansionList(event_IDM_ABBREV)
	if get_abbrev then -- пр?открытии ?переключении вкладк?
		-- опреде?ем символ?которы?предшествуют аббревиатуре
		prev_chars = props['abbrev.'..props['Language']..'.prev.chars']
		if prev_chars == '' then prev_chars = ' ([{<' end
		prev_chars = '['..prev_chars:gsub(' ', 's'):gsub('(.)', '\\%1')..']'
	end
	local sel_start = editor.SelectionStart
	local line_start_pos = editor:PositionFromLine(editor:LineFromPosition(sel_start))
	-- ищем начало сокращен? - первый пробельный символ
	local abbrev_start = editor:findtext(prev_chars, SCFIND_REGEXP, sel_start-1, line_start_pos) --@ `-1` in `sel_start-1` is propably wrong, but so you can make "& =bla" abbreviation
	abbrev_start = abbrev_start and abbrev_start+1 or line_start_pos

	local abbrev = editor:textrange(abbrev_start, sel_start)
	abbrev_length = #abbrev
	if abbrev_length == 0 then return event_IDM_ABBREV end
	-- если длин?вероятной аббревиатуры меньше заданног?ко?ва символов то выходи?
	if not event_IDM_ABBREV and abbrev_length < chars_count_min then return true end

	-- если мы переключилис?на другой файл, то строим таблиц?table_abbr_exp заново
	if get_abbrev then
		CreateExpansionList()
		get_abbrev = false
	end
	if #table_abbr_exp == 0 then return event_IDM_ABBREV end

	local cp = editor:codepage()
	if cp ~= 65001 then abbrev = abbrev:to_utf8(cp) end
	abbrev = abbrev:utf8upper()
	table_user_list = {}
	 -- выбираем из table_abbr_exp только записи соответствующи?этой аббревиатуре
	for i = 1, #table_abbr_exp do
		if table_abbr_exp[i].abbr:find(abbrev, 1, true) == 1 then
			table_user_list[#table_user_list+1] = {table_abbr_exp[i].abbr, table_abbr_exp[i].exp}
		end
	end
	if #table_user_list == 0 then return event_IDM_ABBREV end
	-- если мы используем Ctrl+B (?не автоматическое срабатывание)
	if (event_IDM_ABBREV)
		-- ?если найден единственный вариан?расшифровк?
		and (#table_user_list == 1)
		-- ?аббревиатура полность?соответствуе?введенно?
		and (abbrev == table_user_list[1][1])
			-- то вставк?производим немедленно
			then
				InsertExpansion(table_user_list[1][2], abbrev_length)
				return true
	end

	-- показываем раскрывающий? список из расшифрово? соответствующи?введенно?аббревиатуре
	local tmp = {}
	local list_width = tonumber(props['abbrev.list.width']) or -1
	for i = 1, #table_user_list do
		tmp[#tmp+1] = table_user_list[i][2]:sub(1, list_width)
	end
	local table_user_list_string = table.concat(tmp, sep):gsub('%?', ' ')
	if cp ~= 65001 then table_user_list_string = table_user_list_string:from_utf8(cp) end
	local sep_tmp = editor.AutoCSeparator
	editor.AutoCSeparator = string.byte(sep)
	editor:UserListShow(typeUserList, table_user_list_string)
	editor.AutoCSeparator = sep_tmp
	return true
end

------------------------------------------------------
AddEventHandler("OnMenuCommand", function(msg)
	if msg == IDM_ABBREV then
		return ShowExpansionList(true)
	end
end)


AddEventHandler("OnChar", function()   
	chars_count_min = tonumber(props['abbrev.'..props['Language']..'.auto']) or tonumber(props['abbrev.*.auto']) or 0
	if chars_count_min ~= 0 then
		return ShowExpansionList(false)
	end
end)

AddEventHandler("OnKey", function(key, shift, ctrl, alt,charAdded)
   local sel_txt = editor:GetSelText()
   local toClose = { ['('] = ')', ['{'] = '}', ['['] = ']', ['"'] = '"', ["'"] = "'" }
   if toClose[charAdded] ~= nil then   
      --auto add ) } ] ' " to end of seleted text
      if not (sel_txt == '' or sel_txt == nil) then
         local rep_txt = charAdded..sel_txt..toClose[charAdded]
         editor:ReplaceSel(rep_txt)
         return true     
      else  --auto complete () {} []  '' "      
        editor:InsertText(editor.CurrentPos,toClose[charAdded])
      end
   end
  
  
     if editor.Focus and smart_tab > 0 and key == 9 then -- TAB=9
          if not (shift or ctrl or alt) then
               for i = editor.CurrentPos, editor.Length do
                    if editor:IndicatorValueAt(num_hidden_indic, i)==1 then
                         editor:GotoPos(i+1)
                         if not clearmanual then
                              EditorClearMarks(num_hidden_indic, i, 1)
                              smart_tab = smart_tab - 1
                         end
                         return true
                    end
               end
          elseif ctrl and not (shift or alt) then
               EditorClearMarks(num_hidden_indic)
               smart_tab = 0
               return true
          end
     end
end)

AddEventHandler("OnUserListSelection", function(tp, sel_value, sel_item_id)
	if tp == typeUserList then
		InsertExpansion(table_user_list[sel_item_id][2], abbrev_length)
	end
end)

AddEventHandler("OnSwitchFile", function()
	get_abbrev = true
end)

AddEventHandler("OnOpen", function()
	get_abbrev = true
end)
