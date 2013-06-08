--[[--------------------------------------------------
SciTE Smart comment
Author: Dmitry Maslov
Version: 2.7.5
------------------------------------------------------
�������� ����� �������� �� ���������� ������ 
� �������� ���������� ����������� � ������ ��������������
������: �������� ������ � cpp, ������ �� ������� * ��� /
-------------------------------------------------
������ 2.7
������ ����� ��������� � ������������� ������
-------------------------------------------------
������ 2.3
������ ������ ��������� ����������
-------------------------------------------------
������ 2.2
��������� ���, ���� ������ �� �������� ������,
�� ������ ��� ���� ��������������
-------------------------------------------------
������ 2.1
�������� ������� ������������ �� ���� ������ �� ������� 
������� �������� �����������, �� ��� ������ ;) 
������������� mozers �� ��������� � ����������.
-------------------------------------------------
������ 1.0
��������� ������������ � cpp * � / (/**/ � //~ )
��������� ������������ � lua - ( -- )
��������� ������ � lua
��������� ����������� � props # ( #~ )
--]]--------------------------------------------------

-- ������� ����� �������� ��� ������
-- (���������� ������������� ��������� ��������)
local function MakeFind( text )
	local strres = ''
	local simbol
	for i = 1, string.len(text), 1
	do
		simbol = string.format( '%c', string.byte( text, i ) )
		if	( simbol == "(" )
			or
			( simbol == "[" )
			or
			( simbol == "." )
			or
			( simbol == "%" )
			or
			( simbol == "*" )
			or
			( simbol == "/" )
			or
			( simbol == "-" )
			or
			( simbol == ")" )
			or
			( simbol == "]" )
			or
			( simbol == "?" )
			or
			( simbol == "+" )
		then
			simbol = string.format( "%%%s", simbol )
		end
		strres = strres..simbol
	end
	return strres
end

-- ���������� ������ ������� ����� ������?
local function prevIsEOL(pos)
	if string.find(editor:textrange(editor:PositionBefore(pos-string.len(GetEOL())+1), pos),GetEOL())
	then
		return true
	end
	return false
end

-- ��������� ������ � ������ - ����� ������?
local function IsEOLlast(text)
	-- � ��� ����� ������ ������ ���� ������
	if string.find(text,GetEOL(),string.len(text)-1)
	then
		return true
	end
	return false
end

local function StrimComment(commentbegin, commentend)
	local text = editor:GetSelText()
	local selbegin = editor.SelectionStart
	local selend = editor.SelectionEnd
	local b,e = string.find(text, MakeFind(commentbegin))
	if (e and (string.byte(text, e+1) == 10 or string.byte(text, e+1) == 13))
	then
		e=e+1 
	end
	if (e and (string.byte(text, e+1) == 10 or string.byte(text, e+1) == 13))
	then
		e=e+1 
	end
	local b2,e2
	if IsEOLlast(text)
	then
		b2,e2 = string.find(text, MakeFind(commentend), 
			string.len(text)-string.len(commentend)-string.len(GetEOL()))
	else
		b2,e2 = string.find(text, MakeFind(commentend), 
			string.len(text)-string.len(commentend))
	end
	if (b2 and (string.byte(text, b2-1) == 10 or string.byte(text, b2-1) == 13))
	then
		b2=b2-1 
	end
	if (b2 and (string.byte(text, b2-1) == 10 or string.byte(text, b2-1) == 13))
	then
		b2=b2-1 
	end
	editor:BeginUndoAction()
	if (b and b2)
	then
		local add=''
		if (string.find(text,GetEOL(),string.len(text)-string.len(GetEOL())))
		then
			add = GetEOL()
		end
		text = string.sub(text,e+1,b2-1)
		editor:ReplaceSel(text..add)
		editor:SetSel(selbegin, selbegin+string.len(text..add))
	else
		if (editor:LineFromPosition(selend)==editor:LineFromPosition(selbegin))
		then
			editor:insert(selend, commentend)
			editor:insert(selbegin, commentbegin)
			editor:SetSel(selbegin, selend+string.len(commentbegin)+string.len(commentend))
		else
			local eolcount = 0
			if (prevIsEOL(selend))
			then
				editor:insert(selend, commentend..GetEOL())
				eolcount = eolcount + 1
			else
				editor:insert(selend, commentend)
			end
			if (prevIsEOL(selbegin))
			then
				editor:insert(selbegin, commentbegin..GetEOL())
				eolcount = eolcount + 1
			else
				editor:insert(selbegin, commentbegin)
			end
			editor:SetSel(selbegin, selend+string.len(commentbegin)+string.len(commentend)+string.len(GetEOL())*eolcount)
		end
	end
	editor:EndUndoAction()
	return true
end

local function BlockComment()
	local selbegin = editor.SelectionStart
	editor:BeginUndoAction()
	if (string.find(editor:textrange(selbegin-string.len(GetEOL()), selbegin),GetEOL()))
	then
		scite.MenuCommand(IDM_BLOCK_COMMENT)
		editor:SetSel(selbegin, editor.SelectionEnd)
	else
		scite.MenuCommand(IDM_BLOCK_COMMENT)
		editor:SetSel(editor.SelectionStart, editor.SelectionEnd)
	end
	editor:EndUndoAction()
	return true
end

local function GetIndexFindCharInProps(value, findchar)
	if findchar
	then
		local resIndex = string.find(props[value], MakeFind(findchar), 1)
		if (resIndex~=nil) and (string.sub(props[value],resIndex,resIndex) == findchar)
		then
			return resIndex
		end
	end
	return nil
end

local function SmartComment(char)
	if (editor.SelectionStart~=editor.SelectionEnd)
	then
		-- ������ �������������� ��������� �� ��������
		if (props['Language'] == 'cpp')
		then
			if (char == '*' ) then return StrimComment('/*', '*/') end
		end
		-- ������ �������� �� ������� �����������
		if GetIndexFindCharInProps('comment.block.'..props['Language'], char) == 1
		then
			return BlockComment()
		end
	end

	return false
end

AddEventHandler("OnKey", function(key, shift, ctrl, alt, char)
	if editor.Focus and char~='' then
		return SmartComment(char)
	end
end)
