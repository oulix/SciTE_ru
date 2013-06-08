--[[--------------------------------------------
xComment
Version: 1.4.4
Author: mozers�, VladVRO
-------------------------------------------------
  C ������� �������� ����������� ���������� Ctrl+Q (���������������|������ �����������)

��� ����������� ������� �� ��������� ������:
  * ���� ������� ����� ������, �� ������ ������|������� ��������� �����������.
  * ���� �������� ����� ������(������� ������ �������� ������) ��� ��������� �����, �� �� ������ ������|������� ������� �����������.
  * ���� ��������� �����������, �� ��������|��������� ������� ����������� �� ������� ������.
  * ���� ��������� comment.stream.* ����������, �� ���������� �� ������� ��������� ��������|��������� ������� �����������.

������/��������� ����������� ������� �� ������� ������� ���������:
  * ���� ������ ������ � ��������� ����������������, �� ����������� ��������� �� ����� ���������.
  * ���� - ���, �� �� ��� ��������� �������� �����������.

�����������:
� ���� SciTEStartup.lua �������� ������:
  dofile (props["SciteDefaultHome"].."\\tools\\xComment.lua")
������� � ����� .properties ������������ ���� ������ ���������:
  comment.block.lexer
  comment.block.at.line.start.lexer
  comment.stream.start.lexer
  comment.stream.end.lexer

� �������� �������� ��� ���� ������� "~". ������ ��� ������ ������� �� �����������!
��������: � ������� ������������ ������� IsComment (����������� ����������� COMMON.lua)
--]]--------------------------------------------

-- local iDEBUG = true -- ���������� ��� ������� �������
local lexer = ""
local sel_text = ""
local sel_start = 0
local sel_end = 0
local line_sel_start = 0
local line_sel_end = 0
local comment_block = ""
local comment_block_at_line_start = 0
local comment_block_use_space = 1 -- ����� ������ ���-�� ��������, ���������� ������� �� ����
local comment_stream_start = ""
local comment_stream_end = ""
local PatternStream = ""

--------------------------------------------------
local function Pattern(text)
-- ��������� �������� ��� ������ �������� ����������� � ������
	local pat = ""
	for i = 1, string.len(text) do
		pat = pat.."%"..string.sub(text,i,i)
	end
	return pat
end

---------------------------------------------
local function FirstLetterFromBlock()
-- ���������� ������� ������� �� ����������� ������� � �����
	local text_line = sel_text
	if sel_text == "" then
		text_line = editor:GetLine(line_sel_start)
		sel_start = editor:PositionFromLine(line_sel_start)
	end
	local first_letter, _, _ = string.find(text_line, "[^%s]", 1)
	if first_letter ~= nil then
			first_letter = sel_start + first_letter - 1
	else
		first_letter = -1
	end
	if iDEBUG then print("FirstLetterFromBlock = "..first_letter) end
	return first_letter
end

--------------------------------------------------
local function IsBlock()
-- ����������� ��� �������� - ���� ��� �����
	if sel_text == "" then return true end
	if sel_end > 0 and editor.CharAt[sel_end - 1] == 10 then
		if iDEBUG then print ("This Block") end
		return true
	end
	if iDEBUG then print ("This NOT Block") end
	return false
end

--------------------------------------------------
local function IsStreamComment()
-- ����������� ��� �������� - ��������� ����������� ��� ������������������ ������
	if PatternStream ~= "" then
		if string.find(sel_text,PatternStream) then
			if iDEBUG then print ("This Stream Comment") end
			return true
		end
	end
	if iDEBUG then print ("This NOT Stream Comment") end
	return false
end

--------------------------------------------------
local function LineComment()
-- ��������������� ����� ������������ ������
	if iDEBUG then print ("Line Comment") end
	if comment_block == "" then
		print("! ����������� �������� ".."comment.block."..lexer)
	else
		comment_block = comment_block..string.rep(" ", comment_block_use_space)
		local cur_pos = editor.CurrentPos
		if comment_block_at_line_start == 1 then
			editor:GotoPos(editor:PositionFromLine(line_sel_start))
		else
			editor:GotoPos(editor.LineIndentPosition[line_sel_start])
		end
		editor:ReplaceSel(comment_block)
		editor:GotoPos(cur_pos + string.len(comment_block))
	end
end

--------------------------------------------------
local function BlockComment()
-- ��������������� ���������� ���������� �����
	if iDEBUG then print ("Block Comment") end
	if comment_block == "" then
		print("! ����������� �������� ".."comment.block."..lexer)
	else
		comment_block = comment_block..string.rep(" ", comment_block_use_space)
		local text_comment = ""
		for i = line_sel_start, line_sel_end-1 do
			local text_line = editor:GetLine(i)
			if string.find(text_line,"[^%s]") then
				if comment_block_at_line_start == 1 then
					text_comment = text_comment..comment_block..text_line
				else
					text_comment = text_comment..string.gsub(text_line,"([^%s])",comment_block.."%1",1)
				end
				sel_end = sel_end + string.len(comment_block)
			else
				text_comment = text_comment..text_line
			end
		end
		editor:ReplaceSel(text_comment)
		-- ��������������� ���������
		editor:SetSel(sel_start, sel_end)
	end
end

--------------------------------------------------
local function LineUnComment()
-- ������ ����������� � ����� ������������ ������
	if iDEBUG then print ("Line UnComment") end
	if comment_block == "" then
		print("! ����������� �������� ".."comment.block."..lexer)
	else
		local cur_pos = editor.CurrentPos
		local text_line = editor:GetCurLine()
		local comment_pos, _ = string.find(text_line,Pattern(comment_block).."~? ?", 1)
		local line_uncomment = string.gsub(text_line,Pattern(comment_block).."~? ?","",1)
		local line_pos_start = editor:PositionFromLine(line_sel_start)
		local line_pos_end = line_pos_start + string.len(text_line)
		editor:SetSel(line_pos_start, line_pos_end)
		editor:ReplaceSel(line_uncomment)
		if comment_pos and cur_pos > (line_pos_start + comment_pos) then
			editor:GotoPos(cur_pos - string.len(text_line) + string.len(line_uncomment))
		else
			editor:GotoPos(cur_pos)
		end
	end
end

--------------------------------------------------
local function BlockUnComment()
-- ������ ����������� � ���������� ���������� �����
	if iDEBUG then print ("Block UnComment") end
	if comment_block == "" then
		print("! ����������� �������� ".."comment.block."..lexer)
	else
		local text_uncomment = ""
		for i = line_sel_start, line_sel_end-1 do
			local text_line = editor:GetLine(i)
			local line_uncomment = string.gsub(text_line,Pattern(comment_block).."~? ?","",1)
			text_uncomment = text_uncomment..line_uncomment
			if line_uncomment ~= text_line then
				sel_end = sel_end - string.len(text_line) + string.len(line_uncomment)
			end
		end
		editor:ReplaceSel(text_uncomment)
		-- ��������������� ���������
		editor:SetSel(sel_start, sel_end)
	end
end

--------------------------------------------------
local function StreamComment()
-- ��������������� ����������� ������ ������
	if iDEBUG then print ("Stream Comment") end
	if comment_stream_start == "" or comment_stream_end == "" then
		print("! ����������� ��������� ".."comment.stream.start."..lexer.." � ".."comment.stream.end."..lexer)
	else
		local text_comment = comment_stream_start..sel_text..comment_stream_end
		editor:ReplaceSel(text_comment)
		if sel_text ~= "" then
			-- ��������������� ���������
			editor:SetSel(sel_start, sel_end + string.len(comment_stream_start) + string.len(comment_stream_end))
		end
	end
end

--------------------------------------------------
local function StreamUnComment()
-- ������ ����������� � ����������� ������ ������
	if iDEBUG then print ("Stream UnComment") end
	if PatternStream == "" then
		print("! ����������� ��������� ".."comment.stream.start."..lexer.." � ".."comment.stream.end."..lexer)
	else
		local text_uncomment = string.gsub(sel_text,PatternStream,"%1",1)
		editor:ReplaceSel(text_uncomment)
		if sel_text ~= "" then 
			-- ��������������� ���������
			editor:SetSel(sel_start, sel_end - string.len(comment_stream_start) - string.len(comment_stream_end))
		end
	end
end

---------------------------------------------
local function xComment()
-- ��������� ������� �� Ctrl+Q
	lexer = props['Language']
	sel_text = editor:GetSelText()
	sel_start = editor.SelectionStart
	sel_end = editor.SelectionEnd
	line_sel_start = editor:LineFromPosition(sel_start)
	line_sel_end = editor:LineFromPosition(sel_end)
	comment_block = props["comment.block."..lexer]

	comment_block_at_line_start = tonumber(props["comment.block.at.line.start."..lexer])
	comment_stream_start = props["comment.stream.start."..lexer]
	comment_stream_end = props["comment.stream.end."..lexer]

	if sel_text == "" then
		-- This Line
		if IsComment(FirstLetterFromBlock()) then
			LineUnComment()
		else
			LineComment()
		end
		return true
	end

	if IsBlock() then
	-- This Block
		if IsComment(FirstLetterFromBlock()) then
			BlockUnComment()
		else
			BlockComment()
		end
	else
	-- This Stream
		if comment_stream_start ~= "" and comment_stream_end ~= "" then
			PatternStream = Pattern(comment_stream_start).."(.-)"..Pattern(comment_stream_end)
		else
			-- ���� ��������� comment.stream.* �����������, �� ��������� ��������� ������ �� �����
			-- � ������������|��������� ������� �����������
			-- (����������� frs <http://forum.ru-board.com/topic.cgi?forum=5&topic=24956&start=660#6>)
			line_sel_end = line_sel_end + 1
			editor:SetSel(editor:PositionFromLine(line_sel_start), editor:PositionFromLine(line_sel_end))
			-- This Block
			if IsComment(FirstLetterFromBlock()) then
				BlockUnComment()
			else
				BlockComment()
			end
			return true
		end

		if IsStreamComment() then
			StreamUnComment()
		else
			StreamComment()
		end
	end
	return true
end

AddEventHandler("OnMenuCommand", function(msg, source)
	if msg == IDM_BLOCK_COMMENT then -- (Ctrl+Q)
		return xComment() -- true �� ���� ���������� ���������� �������
	end
end)
