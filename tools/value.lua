--[[--------------------------------------------------
value.lua
Author: Mingun
version 1.1.0
------------------------------------------------------
  ���������� ����������� ��������
   - ����������, �������� � ������ .properties
   - ���������� � ������, �������� � ���������� ������� _G

  ��� ����������� �������� � ���� ���� .properties ��������� ������:
    command.name.18.*.properties;*.lua=Value of variable
    command.18.*.properties;*.lua=dofile $(SciteDefaultHome)\tools\value.lua
    command.mode.18.*.properties;*.lua=subsystem:lua,savebefore:no
    command.shortcut.18.*.properties;*.lua=Alt+V
--]]--------------------------------------------------

-- ������� ���������� ������� � ���� ������
local function print_table(tbl, tbl_name)
	if tbl_name == nil then tbl_name = '.' end
	for fields, value in pairs(tbl) do
		if type(fields)=='string' then fields = "'"..fields.."'" end
		if type(value) == "table" then
			print("+", tbl_name.."["..fields.."] =", value)
			print_table(value, tbl_name.."["..fields.."]")
		else
			print("-", tbl_name.."["..fields.."] =", value)
		end
	end
end

local value = props['CurrentSelection']
if (value == '') then value = props['CurrentWord'] end

local res = _G[value] or props[value]
print('\n'..value..'='..tostring(res))
if type(res) == "table" then
	-- �������� ���������� �������
	print_table(res, value)
end