--[[--------------------------------------------------
CodePage.lua
Authors: YuriNB, VladVRO, mozers™
Version: 2.5.2
------------------------------------------------------
Гибрид 2х скриптов:
win1251 to cp866 keyboard mapper (YuriNB icq#2614215)
 Переключатель кодировки текущего ввода и отображения win1251/dos866
 Одновременно переключается кодировка окна консоли
и
codepage.lua (VladVRO)
 Показ текущей кодировки в статусной строке.

Кроме того, скрипт пытается отличить кодировку cp866 от win1251 при открытии файла или при переключении на него.
Если это удается, то происходит автоматическое переключение отображения и ввода.
------------------------------------------------------
Connection:
 In file SciTEStartup.lua add a line:
    dofile (props["SciteDefaultHome"].."\\tools\\CodePage.lua")
 Set in a file .properties:
    command.name.29.*=DOS Mode (cp866)
    command.29.*=change_codepage_ru
    command.checked.29.*=$(code.page.866)
    command.mode.29.*=subsystem:lua,savebefore:no

    code.page.866.detect=1
--]]--------------------------------------------------

local chars_accented = 'АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя'

local function UpdateStatusCodePage(mode)
	local code_page_name = props["editor.code.page.name"]
	props["code.page.866"]='0'
	if mode == IDM_ENCODING_UCS2BE then
		props["editor.code.page.name"]='UTF-16 BE'
	elseif mode == IDM_ENCODING_UCS2LE then
		props["editor.code.page.name"]='UTF-16 LE'
	elseif mode == IDM_ENCODING_UTF8 then
		props["editor.code.page.name"]='UTF-8 BOM'
	elseif mode == IDM_ENCODING_UCOOKIE then
		props["editor.code.page.name"]='UTF-8'
	else
		if props["character.set"]=='255' then
			props["editor.code.page.name"]='DOS-866'
			props["code.page.866"]='1'
		elseif props["character.set"]=='204' then
			props["editor.code.page.name"]='WIN-1251'
		elseif tonumber(props["character.set"])==0 then
			props["editor.code.page.name"]='CP1252'
		elseif props["character.set"]=='238' then
			props["editor.code.page.name"]='CP1250'
		elseif props["character.set"]=='161' then
			props["editor.code.page.name"]='CP1253'
		elseif props["character.set"]=='162' then
			props["editor.code.page.name"]='CP1254'
		else
			props["editor.code.page.name"]='???'
		end
	end
	if props["editor.code.page.name"] == code_page_name then return end

	if mode == nil or mode == IDM_ENCODING_DEFAULT then
		if props["character.set"]=='255' then
			props["chars.accented"] = chars_accented:from_utf8(866)
			scite.Perform("reloadproperties:")
-- print(' dos866 > '..props['CurrentWordCharacters'])
		else
			props["chars.accented"] = chars_accented:from_utf8(1251)
			scite.Perform("reloadproperties:")
-- print('win1251 > '..props['CurrentWordCharacters'])
		end
	else -- utf8
		props["chars.accented"] = chars_accented
		scite.Perform("reloadproperties:")
-- print('   utf8 > '..props['CurrentWordCharacters'])
	end

	props["editor.code.page"]=editor:codepage()
	scite.UpdateStatusBar()
end

local function CharsetDetect()
	if tonumber(props["code.page.866.detect"]) ~= 1 then return false end
	function CharsetDOS()
		local a, b
		a = editor:findtext("[\128-\175][\128-\175][\128-\175]", SCFIND_REGEXP, 0)
		if a then
			b = editor:findtext("[\240-\255][\240-\255][\240-\255]", SCFIND_REGEXP, 0)
			if not b then
				b = editor:findtext("[\192-\233][\192-\233][\192-\233]", SCFIND_REGEXP, 0)
			end
			if b and b < a then return false end
			return true
		end
		return false
	end
	if tonumber(props["editor.unicode.mode"]) == IDM_ENCODING_DEFAULT then
		if (props["character.set"]=='204' and CharsetDOS())
			or (props["character.set"]=='255' and not CharsetDOS()) then
			change_codepage_ru()
			return true
		end
	end
	return false
end

-- Добавляем свой обработчик события OnSwitchFile
AddEventHandler("OnSwitchFile", function(file)
	if not CharsetDetect() then
		UpdateStatusCodePage(tonumber(props["editor.unicode.mode"]))
	end
end)

-- Добавляем свой обработчик события OnOpen
AddEventHandler("OnOpen", function(file)
	if not CharsetDetect() then
		UpdateStatusCodePage(tonumber(props["editor.unicode.mode"]))
	end
end)

-- Добавляем свой обработчик события OnMenuCommand
AddEventHandler("OnMenuCommand", function(cmd, source)
	if cmd > 149 and cmd < 155 then -- IDM_ENCODING_DEFAULT, IDM_ENCODING_UCS2BE, IDM_ENCODING_UCS2LE, IDM_ENCODING_UTF8, IDM_ENCODING_UCOOKIE
		UpdateStatusCodePage(cmd)
	end
end)

-------------------------------------------------------------
-- win1251 to cp866 keyboard mapper
-------------------------------------------------------------

function change_codepage_ru()
	scite.MenuCommand(IDM_ENCODING_DEFAULT)
	if props["character.set"]=='255' then
		props["character.set"]='204'
	else
		props["character.set"]='255'
	end
	scite.Perform('reloadproperties:')
	UpdateStatusCodePage()
end

local charset1251to866 =
{
[168]=240, --Ё
[184]=241, --ё
[185]=252, --№
[192]=128,[193]=129,[194]=130,[195]=131,[196]=132,
[197]=133,[198]=134,[199]=135,[200]=136,[201]=137,
[202]=138,[203]=139,[204]=140,[205]=141,[206]=142,
[207]=143,[208]=144,[209]=145,[210]=146,[211]=147,
[212]=148,[213]=149,[214]=150,[215]=151,[216]=152,
[217]=153,[218]=154,[219]=155,[220]=156,[221]=157,
[222]=158,[223]=159,[224]=160,[225]=161,[226]=162,
[227]=163,[228]=164,[229]=165,[230]=166,[231]=167,
[232]=168,[233]=169,[234]=170,[235]=171,[236]=172,
[237]=173,[238]=174,[239]=175,[240]=224,[241]=225,
[242]=226,[243]=227,[244]=228,[245]=229,[246]=230,
[247]=231,[248]=232,[249]=233,[250]=234,[251]=235,
[252]=236,[253]=237,[254]=238,[255]=239
}

local function Win2DOS(charAdded)
	local a1=string.byte(charAdded)
	if charset1251to866[a1] ~= nil then
		local pos = editor.CurrentPos
		editor:SetSel(pos, pos - 1)
		editor:ReplaceSel( string.char( charset1251to866[a1] ) )
	end
end

-- Добавляем свой обработчик события OnChar
AddEventHandler("OnChar", function(char)
	if props["character.set"]=='255' then
		Win2DOS(char)
	end
end)
