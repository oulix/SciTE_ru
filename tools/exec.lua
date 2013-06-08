--[[-------------------------------------------------
Exec.lua
Version: 1.2.2
Author: HSolo, mozers�
---------------------------------------------------
������ ����������� ������ ��� ��������������� ���������
��� �������� � �������� ����������� URL
http://forum.ru-board.com/topic.cgi?forum=5&topic=3215&start=2020#3
--]]-------------------------------------------------

local function FindExpression(str)
	local patternNum = "([\-\+\*\/%b()%s]*%d+[\.\,]*%d*[\)]*)"
	local startPos, endPos, number, formula
	startPos = 1
	formula = ''
	while true do
		startPos, endPos, number = str:find(patternNum, startPos) -- ������� �����, �����, ������ (�.�. ��� ��� ����� ������� �� ����� �������)
		if startPos == nil then break end
		startPos = endPos + 1
		number = number:gsub('%s+', '')                           -- ������� �������
		number = number:gsub('^([\(%d]+)', '+%1')                 -- ���, ��� ����� ������ ��� �����, ������ "+" (�.�. ������� � �������� ����� ���������� �� "+")
		number = number:gsub('^([\)]+)([%d]+)', '%1+%2')          -- ��������� ���� "+" (��� ��� ����������) ����� ������ � �������
		formula = formula..number                                 -- ��������� ����� ��������������� ������
	end
	formula = formula:gsub('^[\+]', '')                      -- � ����� ������ ��������� ������ "+" - ������� ���
	formula = formula:gsub("[\,]+",'.')                      -- �� ����� ������ � ������� - ����������� ���������� ����� :)
	formula = formula:gsub("([\+])([\+]+)",'%1')             -- ������� ��������� ����� (++) = (+)
	formula = formula:gsub("([\-])([\+]+)",'%1')             -- ������� ��������� ����� (-+) = (-)
	formula = formula:gsub("([\+\-\*\/])([\*\/]+)",'%1')     -- ������� ��������� ����� ����� * � / �.�. ��� ����� �����
	formula = formula:gsub("([\+\-\*\/])([\*\/]+)",'%1')     -- ��� ���������� ������� ��������� ������
	formula = formula:gsub("([%d\)]+)([\+\*\/\-])",'%1 %2 ') -- ��������� ������ ���������
	return formula
end

local str = ''
if editor.Focus then
	str = editor:GetSelText()
else
	str = props['CurrentSelection']
end
if (str == '') then
	str = editor:GetCurLine()
end
if (#str < 3) then return end

if str:find('https?://(.*)') then
	shell.exec(str)
else
	if str:find("(math\.%w+)") then  -- � ������ ������� �������������� ��������� �������������� ��������� �� ������������
		str = str:gsub("[=]",'')
	else
		str = FindExpression(str)
	end
	local result = loadstring('return '..str)()

	print('-> '..scite.GetTranslation("Calculate Expression")..': '..str)
	print('>> '..scite.GetTranslation("Result")..': '..result)

	--[[ -------- insert result to text ------
	editor:LineEnd() 
	local sel_start = editor.SelectionStart + 1
	local sel_end = sel_start + string.len(result)
	editor:AddText('\n= '..result)
	editor:SetSel(sel_start, sel_end+2)
	--]] -------------------------------------
end

--[[-------------------------------------------------
����� ���� :)
1/2 56/4 - 56 (8-6)*4  4,5*(1+2)    66
3/6 6.4/2 6  (7-6)*4  45/4.1 66

dmfdmk v15*6dmd.ks skm4.37/3d(k)gm/sk+d skdmg(6,7+6)skdmgk

������� = 24.5��. * 120���./��
������(ABC) = (2500��. / (11,5�./100��.)) * 18.4���./� + �������� =100���.
���������� = 22.4 �2 /80���./100 �2

http://scite-ru.org
--]]-------------------------------------------------
