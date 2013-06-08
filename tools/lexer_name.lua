--[[--------------------------------------------------
lexer_name.lua
Authors: mozers�, VladVRO
version 1.1.4
------------------------------------------------------
����� ����� �������� ������� � ������ �������

�����������:
� ���� SciTEStartup.lua �������� ������:
  dofile (props["SciteDefaultHome"].."\\tools\\lexer_name.lua")
�������� scite.lexer.name � ��������� ������:
  statusbar.text.1=Line:$(LineNumber) Col:$(ColumnNumber) [$(scite.lexer.name)]
--]]--------------------------------------------------

local last_lexer
local function SetPropLexerName()
	if props['FileName'] == '' then return end
	local cur_lexer = props['Language']
	if cur_lexer ~= last_lexer then
		if cur_lexer == "hypertext" then
			props["scite.lexer.name"] = "html"
		else
			props["scite.lexer.name"] = cur_lexer
		end
		last_lexer = cur_lexer
	end
end

-- ��������� ���� ���������� ������� OnUpdateUI
AddEventHandler("OnUpdateUI", SetPropLexerName)

-- ��������� ���� ���������� ������� OnSwitchFile
AddEventHandler("OnSwitchFile", SetPropLexerName)
