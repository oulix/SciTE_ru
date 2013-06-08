--[[--------------------------------------------------
AutocompleteObject.lua
mozers�, Tymur Gubayev
version 3.10.11
------------------------------------------------------
Inputting of the symbol set in autocomplete.[lexer].start.characters causes the popup list of properties and methods of input_object. They undertake from corresponding api-file.
In the same case inputting of a separator changes the case of symbols in input_object's name according to a api-file.
(for example "ucase" is automatically replaced on "UCase".)

Warning: This script needed function IsComment and string.pattern (COMMON.lua)
props["APIPath"] available only in SciTE-Ru

Connection:
In file SciTEStartup.lua add a line:
  dofile (props["SciteDefaultHome"].."\\tools\\AutocompleteObject.lua")
Set in a file .properties:
  autocomplete.lua.start.characters=.:

------------------------------------------------------
���� �����������, ��������� � autocomplete.[lexer].start.characters
�������� ������ ������� � ������� ������� �� ���������������� api �����
���� ����������� �������� ������� �������� � ����� ������� � ������������ � ������� � api ����� (�������� "ucase" ��� ����� ������������� ���������� �� "UCase")

��������: � ������� ������������ ������� IsComment � string.pattern �� COMMON.lua
props["APIPath"] �������� ������ � SciTE-Ru

�����������:
� ���� SciTEStartup.lua �������� ������:
  dofile (props["SciteDefaultHome"].."\\tools\\AutocompleteObject.lua")
������� � ����� .properties ���������������� �����
������, ����� ����� ��������, ����� ��������� ��������������:
  autocomplete.lua.start.characters=.:
------------------------------------------------------
��� ��������� ��������� ������ �������, ���������, ��� � ������
azimuth:left;list-style-|type:upper-roman
��� ������ ����� � �������, ���������� ������ "|", � ������ "-" �������� ����� �� ������������, �����
list-style  - ����� ���������� "������"
type        - ����� ���������� "�����"
��� ������������� ��������� �� ���� ������ ���������������� (css ��� - ������ ��� �������)
������ ����� ��������� �������� ������ � "�����������" api ������� (��. �������� ������� � ActiveX.api)
------------------------------------------------------
�����:
���� ����� ����� ����������� ������ ������� � ������� �� ������ (���� ��� ������� � api �����),
��, ��������, ������ �� ���� ���������� ��� ������ �������.
�������� ��� � ����, ������� ����� ������� � ������������� ��������:
mydoc = document
��� mydoc - ��� ������ �������
document - ��� ����� �� �������, �������� � api �����
------------------------------------------------------
History:
3.10.7 (mozers):
	- ��� ����������� ������������ ������� SciTE ������ ������������ �-��� AddEventHandler �� COMMON.lua
3.10.6 (Tymur):
	- ������� FindDeclaration ���������� ������ ���� ��� �������� � ����� ���������� �����, ��� ����������� �������� ������ ������� ��� ������� ������.
3.10.4 (mozers):
	- ���������� ������ ����������� � ��������� ��������������� ������ � ���� ������
3.10.3 (Tymur):
	- ������� �������������� ������� � ������� ��� ������ �������� � COMMON.lua
3.0 (Tymur):
	- ������ ���� ���� ����� case sensitive �� ��������� �� ������
	* ��������� ������� objects_table, alias_table �� �������� ����� � ������� �� ���������� �������
	* ������� �������� ������ 1 � 2 �� ������ ����
	+ ������� ���� ��� ���: ������������� ��������� ���������� � ���� (������������� � �������� string)
	+ ������� � �������� ������ ������ ��������� ����� ������������� ��� ��������. ��. new_delim_behavior
	* FindDeclaration() ���� ����������� � ������������ � ������: ���������� ������� ������� �� $(word.characters.$(file.patterns.LANGUAGE))$(autocomplete.LANGUAGE.start.characters)
	* � ����� ������ ������ �������� ������� (�������� ����� ������� ������) �� ���� ����������� ���������� ������ CreateObjectsTable() � CreateAliasTable() �� ���� ������, � ������ �� ������������� (get_api == true)
	* �������� ������ ���, ��������� � ��������� VoidVolker: http://forum.ru-board.com/topic.cgi?forum=5&topic=24956&start=840#5
	��������� ������ ��� ���, ���� ��� �������� :)
	+ ���� � api-����� ��� ����������� ������� ����: t["a-b+c"]\n��� ����� ������ ��������,
	  �� ����� ����� �������� � autocomplete.lua.start.characters ������ '['
3.01(Tymur):
	+ ������ ����� ���������������� � �������� (��. "-" ������ 3.0)
	+ ������������� ������������ ������� �������� ���������� ����� ������� (����� ����� �� �����������) �� ��������� � api-����� (��� ���: StriNG ������ string), �� ������ ��� ������������� ��������������.
3.05(Tymur):
	* ����������� �������� ���������� ��������������� ����� ����� �����������
	+ �� �������������� �������� ���������� ������ ���� new_delim_behavior ������ props["autocomplete.object.alt"]=="1", ��� ��� �������� ������������ ����� ���������� ������ ��������� �����. ���������.
	* ���������� ������ ������ ���������, ����� �� �� ������� ��� *.css (� �� ������) ������ (��������� mozers). ������ ����� �� word.characters.*.css ������ ������ "-".
	* �������� �������� ������������� ������ ���������: ��� ���������� ������� ��� �������� �������� ����� (����� ��������) ������������ �������� ��� (��� ������������) (������ ��������).
3.06(mozers):
	* �������� autocomplete.object.alt � ���������� new_delim_behavior_better_buggy �������� �� ������ �������� autocomplete.object.method=0|1|2 � ������� �������� ����� ������� ���� �� ���� ���������� ���������.
3.07(mozers):
	- �������� autocomplete.object.method ������ �� ������������. ��� ��������� ������� ����� ����������.
	* ������� GetInputObject ����������. ������������ ��������� [GetWordChars] BioInfo.
3.08(mozers):
	* ����� � ������ ����������� �������� � �������� ������� � ��������� ��������� IsObject � IsString
	* ������ � lua ������ ������� string ��������� ����� �����, � ����������� ������ ��������� ���������� - ����� : (������������� ��������� SciTELua.api)
3.09(Tymur):
	- IsString ���������� �� �������������
	+ ������ � .api ������ ��������� ����������� ���� #$string_value=^'.*' � ���� #$file=io.open%b(). ����� ������ �� ����� "=" -- �������, ������������ ��� ������������� �������. �.�. �������� ��������� ���������������� ���� ��� ������������� ����� �� ��, ��� ������� ����������� ����������� ���.
	! ������ ��� �� ���� ������ �� ��������� ��������� �������! ���������� ������ .api-������:
		��������, � ����� lua.api ���������� ��������� ��������� �������:
			#$string_value=^".*"
			#$string_value=^'.*'
			#$string_value=^%[%[.*%]%]
3.10(Tymur):
	* �������� ������ ���, ����� �� �������������� ��������� ������� ("azimuth:right-" �� ������� ������ � "side")
	* �������� ������� ������������� ������� (������ ������� ������ ���� autocomplete.lexer.start.characters ������������ � word.characters.lexer, ��������, ��� css)
3.10.2(Tymur):
	* ��������� ���� ��� css (� ���������� ������ ������ �� ����� ���������� ������������ ��������, �����. "text-"�� � ����� �����)
--]]----------------------------------------------------

local current_pos = 0    -- ������� ������� �������, ����� ��� InsertMethod
local sep_char = ''      -- ��������� � ���������� ������ (� ����� ������ - ���� �� ������������ ".:")
local auto_start_chars_patt = '' -- �������, ���������� �������������� ������� �� ��������� autocomplete.lexer.start.characters
local get_api = true     -- ����, ������������ ������������� ������������ api �����
local api_table = {}     -- ��� ������ api ����� (��������� �� �������� ��� ����������)
local objects_table = {} -- ��� "�������", ��������� � api ����� � ���� objects_table[objname]=true
local alias_table = {}   -- ������������� "������ = �������"
local patterns_table = {}-- ������������� "������ = ������� ��� �������� ������"
local methods_table = {} -- ��� "������" ��������� "�������", ��������� � api �����
local object_names = {}  -- ��� ����� ��������� api ����� "��������", ������� ������������� ��������� � ������� ����� "������"
local autocomplete_start_characters = '' -- ������� ����������� �������� (�� ��������� autocomplete.lexer.start.characters)
local object_good_name = '' -- "�������" ��� �������, ���, ��� ������� � api-�����, �������� �������
local word_chars_patt = ''

------------------------------------------------------
-- ��������� ������� �� �������� � ������� ���������
local function TableSort(table_name)
	table.sort(table_name, function(a, b) return a:upper() < b:upper() end)
	-- remove duplicates
	for i = #table_name-1, 0, -1 do
		if table_name[i] == table_name[i+1] then
			table.remove (table_name, i+1)
		end
	end
	return table_name
end

------------------------------------------------------
-- ���������� �� api-����� �������� ���� ��������, ������� ������������� ����������
-- �.�. ������ "������" wShort, � ������ ����� ������ ��� WshShortcut � WshURLShortcut
local function GetObjectNames(text)
	local TEXT = text:upper()
	local obj_names = {}
	-- ����� �� ������� ���� "��������"
	if objects_table[TEXT] then
		obj_names[1] = objects_table[TEXT]
		return obj_names, objects_table[TEXT] -- ���� �������, �� ��������� �����
	end

	-- ����� �� ������� ������������� "������ - �������"
	if alias_table[TEXT] then
		for _,v in pairs(alias_table[TEXT]) do obj_names[#obj_names+1] = v end
		return obj_names , (alias_table[TEXT] and alias_table[TEXT]())
	end

	-- �������� �� ���������:
	for obj_name, patterns in pairs(patterns_table) do
		for _, patt in ipairs(patterns) do
			if text:find(patt) then
				obj_names[#obj_names+1] = obj_name
			end
		end	
	end
	return obj_names , nil -- ���� ����� �� ��������, �� ��� "�����������" ����� �������, �� ������� ����� ���� �� ��������� ���������
end

------------------------------------------------------
-- ���������� �� �������� ����� ����� �������, � ������� "��������":
-- ����� "�����" ����� �� �������, ������ ������� ������� autocomplete.start.characters ������ ����� �����
local function GetInputObject()
	local word_chars = props['CurrentWordCharacters']
	-- ��������� ����������� - ��� ������ ���� ����� �����
	editor.WordChars = word_chars..autocomplete_start_characters

	-- ���� ����������� ����� ����� ������ -- ���� ����� ����� �� ������ ������ � ����.
	-- ����� ��� ����������� �������-���������
	local word_start_pos = editor:BraceMatch(current_pos-2)
	if word_start_pos == -1 then word_start_pos = current_pos end
	-- ����� �� ��� ������� ��� ������ editor:WordStartPosition
	word_start_pos = editor:WordStartPosition(word_start_pos-1)
	-- ���������� ��������� �����
	editor.WordChars = word_chars
	return editor:textrange(word_start_pos, current_pos-1)
end

------------------------------------------------------
-- ���������� ������ �������-�������, ������� ���������� "����������" ���
local function CreateAliasEntry(obj)
	return setmetatable({}, { __call = function () return obj end })
end

------------------------------------------------------
-- �������� ����� � ������� ������������� "������ - �������"
local function AddAlias(alias, obj)
	local ALIAS = alias:upper()
	-- ���� ������� ����� �����, ������ �������
	alias_table[ALIAS] = alias_table[obj] or CreateAliasEntry(alias)
	-- ��������� ������� alias � ������� obj
	alias_table[ALIAS][obj:upper()] = obj
end

------------------------------------------------------
-- �������� ������� � ������� ������������� "������ - �������"
local function AddPattern(obj, patt)
	-- ���� ������� ����� �����, ������ �������
	patterns_table[obj] = patterns_table[obj] or {}
	-- ��������� ������� patt � ������� obj
	table.insert(patterns_table[obj], patt)
end

------------------------------------------------------
-- �������� �� �������� �� ����� ������������ �������
local function IsObject(text)
	-- ������ ������� ���� ��� ��������. �� ������ ����� ��� ������ ������� -- ��� �������� �� �������.
	local words_to_test = {text}
	for words in text:gmatch(word_chars_patt) do
		words_to_test[#words_to_test+1] = words
	end
	
	for _, sValue in ipairs(words_to_test) do
		local objects = GetObjectNames(sValue)
		for i = 1, #objects do
			-- ��������� �������� ����� ����� ������� ������������� _���_ �������, � �� �����.
			if objects_table[objects[i]:upper()] then
				return objects[i]
			end
		end
		--@debug: ��� �� ������ �������� ������.
		if #objects > 0 then
			print('ATTENTION: object '..sValue..' has only aliases, and no correct name!\n\tSee function IsObject from AutocompleteObject.lua')
		end
	end --for words in text
	--return ''
end

------------------------------------------------------
-- ����� ���������� ���������� ���������������� ���������� ��������� �������
-- �.�. � ������� ����� ���� ����������� ���� "������� = ������"
local function FindDeclaration()
	local text_all = editor:GetText()
	local _start, _end, sVar, sRightString
	-- ���� ��, ��� �������� �, ��������, word.characters.$(file.patterns.lua)
	word_chars_patt = '['..props['CurrentWordCharacters']:pattern()..auto_start_chars_patt..']+'

	-- @todo: ������ ����� ����� ������ �� ������ ���������.
	local pattern = '('..word_chars_patt..')%s*=%s*(%C+)'
	_start = 1
	while true do
		_start, _end, sVar, sRightString = text_all:find(pattern, _start)
		if _start == nil then break end
		-- ������� ������� � ������/�����
		sRightString = sRightString:gsub("^%s*(%S*)%s*$", "%1")
		if sRightString ~= '' then
			-- ����������� ����� ������ �� ����� "="
			-- ���������, � �� ���������� �� ��� ��������� � api ������?
			local obj = IsObject(sRightString)
			-- ���� �������������, ����� "������" ����������, �� ��������� ��� � ������� ������������� "������ - �������"
			if obj then AddAlias(sVar, obj) end
		end
		_start = _end + 1
	end
end

------------------------------------------------------
-- ������ api ����� � ������� api_table (����� ����� �� ���������� ����, � ��� ������ �� ���)
local function CreateAPITable()
	api_table = {}
	local word_patt = props['CurrentWordCharacters']:pattern()
	local word_extended_patt = '['..word_patt..auto_start_chars_patt..']'
	for api_filename in props["APIPath"]:gmatch("[^;]+") do
		if api_filename ~= nil then
			local api_file = io.open(api_filename)
			if api_file then
				for line in api_file:lines() do
					-- �������� �����������, �������� ������-�������� ��� ���������
					line = line:match('^#$%s*'..word_extended_patt..'+=.+$') or line:match('^[^%s%(]+')
					if line then
						api_table[#api_table+1] = line
					end
				end
				api_file:close()
			end
		end
	end
	get_api = false
	return false
end

------------------------------------------------------
-- �������� �������, ���������� ��� ����� "��������" ��������� � api �����
-- �������� �������, ���������� ��� ������������� "#������� = ������" ��������� � api �����
local function CreateObjectsAndAliasTables()
	objects_table = {}
	alias_table = {}
	patterns_table = {}
	local word_patt = props['CurrentWordCharacters']:pattern()
	local word_extended_patt = '['..word_patt..auto_start_chars_patt..']'
	word_patt = '['..word_patt..']'

	for i = 1, #api_table do
		local line = api_table[i]
		-- ����� ������ �����, ����� � ����� ��� ������ [auto_start_chars_patt], �.�. �������� "[.:]" ��� ���
		-- �.�. ��� ������� �������� ������ ��� api_get, ����� ����� �����.
		local obj_name = line:match('^[^#]') and line:match('^('..word_extended_patt..'*)['..auto_start_chars_patt..']')
		if obj_name then objects_table[obj_name:upper()]=obj_name end

		-- ��� ����� ���� "#a=b" ���������� a,b � ������� �������
		local sObj, sAlias = line:match('^#('..word_extended_patt..'+)=(%S+)$') --@todo: �������� ��� ���������...
		if sObj then
			AddAlias(sAlias, sObj)
		end

		-- ��� ����� ���� "#$a=b" ���������� a,b � ������� ���������
		local sObj, sPatt = line:match('^#$%s*('..word_extended_patt..'+)=(.+)$') --@todo: �������� ��� ���������...
		if sObj then
			AddPattern(sObj, sPatt)
		end
	end
end

------------------------------------------------------
-- �������� ������� "�������" ��������� "�������"
local function CreateMethodsTable(obj)
	for i = 1, #api_table do
		local line = api_table[i]
		-- ���� ������, ������� ���������� � ��������� "�������"
		local _start, _end = line:find(obj..sep_char, 1, true)
		if _end ~= nil and line:sub(1,1)~='#' and
			(_start == 1 or line:gsub(_start-1,_start-1)==sep_char) then
			-- local _start, _end, str_method = line:find('([^'..auto_start_chars_patt..']+)', _end+1)
			local _start, _end, str_method = line:find('(['..props['CurrentWordCharacters']:pattern()..']+)', _end+1)
			if _start ~= nil then
				methods_table[#methods_table+1] = str_method
			end
		end
	end
end

------------------------------------------------------
-- ���������� �������������� ������ "�������"
local function ShowUserList()
	if #methods_table == 0 then return false end
	local sep = '�' -- ����������� ��� ������ ��������������� ������
	local methods_list = table.concat(methods_table, sep)
	if methods_list == '' then return false end
	local sep_tmp = editor.AutoCSeparator
	editor.AutoCSeparator = string.byte(sep)
	editor:UserListShow(7, methods_list)
	editor.AutoCSeparator = sep_tmp
	return true -- �������� ���������� ��������� OnChar (����������� � ��.)
end

------------------------------------------------------
-- ��������� ��������� �� ��������������� ������ ����� � ������������� ������
AddEventHandler("OnUserListSelection", function(tp, sel_value)
	if tp == 7 then
		-- current_pos ���������, ��� �� ���� ��� ����� �����������,
		-- editor.CurrentPos ������ - ��� ������ ����� ����� �� current_pos,
		-- sel_value �������� ��� �����+�����������+��� ���� ��������.
		editor:SetSel(current_pos, editor.CurrentPos)
		editor:ReplaceSel(--[[object_good_name..]]sel_value)
	end
end)

-- �������� ��������� ��� ������� �� ��� ��� �� api ����� (��������, 'wscript' �� 'WScript'))
local function CorrectRegisterSymbols(object_name)
	editor:SetSel(current_pos - #object_name, current_pos)
	editor:ReplaceSel(object_name)
end

-- �������� ��������� (������������ ������� �� �������)
local function AutocompleteObject(char)
	if IsComment(editor.CurrentPos-2) then return false end  -- ���� ������ ����������������, �� �������

	autocomplete_start_characters = props["autocomplete."..props['Language']..".start.characters"]
	-- ���� � �������� autocomplete.lexer.start.characters ������, �� �������
	if autocomplete_start_characters == '' then return false end

	-- workaround ��� �������� ���������� �������
	-- ���� char �� �� autocomplete.lexer.start.characters, ��
	if not autocomplete_start_characters:find(char, 1, 1) then
		local word_start = editor:WordStartPosition(editor.CurrentPos)
		local leftchar = editor:textrange(word_start-1, word_start)
		-- ���� ����� �� ������ ����� ��-���� �����������, �� ���������� ������ ������: �������/���������.
		-- �.�., ���� ������������ ������, �� ��� ��������� ����������� OnChar �� �����������.
		return autocomplete_start_characters:find(leftchar, 1, 1) and editor:AutoCActive()
	end

	-- ������� �� �� ������ ��� ��������� ������ - ������ ��� �����������!
	sep_char = char
	auto_start_chars_patt = autocomplete_start_characters:pattern()

	if get_api then
		CreateAPITable()
		CreateObjectsAndAliasTables()
		FindDeclaration() -- ������� ������������� ������-������� ������������ ������ ����� ����������
	end
	-- ���� � api_table ����� - �������.
	if not next(api_table) then return false end

	-- �����: ���������� ������ ������� ������� (����� "string.b|[Enter]" ����������� � "string.bbyte")
	current_pos = editor.CurrentPos

	-- ����� � �������� ������� ����� ����� �� �������, ��������� current_pos �� ������ ����� ����� �� �������.
	local input_object = GetInputObject(autocomplete_start_characters)

	-- ���� ����� �� ������� ����������� �����, ������� ����� ����������� ��� ��� �������, �� �������
	if input_object == '' then return false end

	object_names, object_good_name = GetObjectNames(input_object)
	if object_good_name and input_object ~= object_good_name then
		CorrectRegisterSymbols(object_good_name..char)
	end

	-- �������, ���� ��������� ����� �� ��� �������
	if not next(object_names) then return false end

	-- ������� ������� ������ �������, ��������� ������
	methods_table = {}
	for i = 1, #object_names do
		CreateMethodsTable(object_names[i])
	end
	methods_table = TableSort(methods_table)
	return ShowUserList()
end

------------------------------------------------------
AddEventHandler("OnChar", AutocompleteObject)

AddEventHandler("OnSwitchFile", function()
	get_api = true
end)

AddEventHandler("OnOpen", function()
	get_api = true
end)

AddEventHandler("OnBeforeSave", function()
	get_api = true
end)
