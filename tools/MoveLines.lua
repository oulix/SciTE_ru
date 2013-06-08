--[[--------------------------------------------------
MoveLines.lua
Authors: codewarlock1101, Tymur Gubayev
Version: 1.2.0
------------------------------------------------------
Description:
 ����������� ���������� ����� (��� 1 ������) �����, ����, ������, �����
 ����������� ����������� ������� �� ������ ������ � �����
------------------------------------------------------
*  PIE_MOVE_TYPE
*     0 �� ���������
*     1 ��� ���������� ����������� �� �������� �������
*     2 ��� ���������� ����������� �� ����� ������
*     3 ���������� �����������
--]]--------------------------------------------------
local copy = ...

    local PIE_MOVE_TYPE=2
    local sel_start_line = editor:LineFromPosition(editor.SelectionStart)
    local sel_end_line = editor:LineFromPosition(editor.SelectionEnd-1)
    local slend=editor:GetLineSelEndPosition(sel_end_line)
    local slend2=editor:GetLineSelEndPosition(sel_end_line-1)
    local sel_txt=editor:GetSelText()
    local nap=0
      
    if slend==slend2 then
      nap=1
    end
    local anti_nap=math.abs(nap-1)
  if horizontal==1 then
        if PIE_MOVE_TYPE==0 or (sel_start_line~=sel_end_line or sel_txt=="" or (editor:PositionFromLine(sel_start_line)==editor.SelectionStart and editor.LineEndPosition[sel_end_line]==editor.SelectionEnd)) then
      for i = sel_start_line, sel_end_line-nap do
        if string.gsub(editor:textrange(editor:PositionFromLine(i),editor.LineEndPosition[i]),' ','')~='' then
            editor.LineIndentation [i]=editor.LineIndentation [i]+vertical*(-1)
        end
      end
        else
        if editor.SelectionStart~=0 or vertical==-1 then
            editor:ReplaceSel('')
            if editor.SelectionStart==editor:PositionFromLine(sel_start_line) and vertical==1 then
              if PIE_MOVE_TYPE==1 then editor:CharLeft() end
              if PIE_MOVE_TYPE==1 or PIE_MOVE_TYPE==3 then editor.SelectionStart=editor.SelectionStart+vertical end
              if PIE_MOVE_TYPE==2 then editor.SelectionStart=editor.LineEndPosition[sel_end_line]+vertical end
            end
            if editor.SelectionStart==editor.LineEndPosition[sel_start_line] and vertical==-1 then
              if PIE_MOVE_TYPE==1 then editor:CharRight() end
              if PIE_MOVE_TYPE==1 or PIE_MOVE_TYPE==3 then editor.SelectionStart=editor.SelectionStart+vertical end
              if PIE_MOVE_TYPE==2 then editor.SelectionStart=editor:PositionFromLine(sel_start_line)+vertical end
            end
            editor.SelectionStart=editor.SelectionStart+(-1)*vertical
            local strt=editor.SelectionStart
            editor:InsertText(editor.SelectionStart, sel_txt)
            if vertical==1 then
              editor.SelectionEnd=editor.SelectionStart-1
              editor.SelectionStart=editor.SelectionStart-string.len(sel_txt)
            else
              editor.SelectionStart=strt

              editor.SelectionEnd=editor.SelectionStart+string.len(sel_txt)
            end 
        end
        end
  elseif not copy then
      if (sel_txt == "") or (sel_start_line==sel_end_line) then
          local xsel_s=editor.SelectionStart-editor:PositionFromLine(sel_start_line)
          local xsel_e=editor.SelectionEnd-editor:PositionFromLine(sel_end_line)
      if vertical==1 then
       if sel_end_line-nap<editor.LineCount-1 then
         editor:LineDown() 
         editor:LineTranspose()
       else 
         vertical=0
       end
      else
        editor:LineTranspose() 
        editor:LineUp()
      end
      if (sel_txt ~= "")  then
        xsel_s = editor:PositionFromLine(sel_start_line+vertical)+xsel_s
        xsel_e = xsel_s + string.len(sel_txt)
        editor:SetSel(xsel_s,xsel_e)
      end
    else

      if (sel_start_line>0 and vertical==-1) or (sel_end_line-nap<editor.LineCount-1 and vertical==1) then
        -- editor:BeginUndoAction()
        if vertical==1 then
        -- Down
            editor:GotoLine(sel_end_line+anti_nap)
            for i = sel_end_line-nap+anti_nap, sel_start_line+anti_nap, -1 do
              editor:LineTranspose()
              editor:LineUp()
            end
        else
        -- Up
            editor:GotoLine(sel_start_line)
            for i = sel_start_line, sel_end_line-nap do
              editor:LineTranspose()
              editor:LineDown()
            end
        end
        local sel_start = editor:PositionFromLine(sel_start_line+vertical)
        local sel_end = editor:PositionFromLine(sel_end_line+vertical+anti_nap)
        editor:SetSel(sel_start,sel_end)
        -- editor:EndUndoAction()
      end
    end
  else -- copy line or selection up or down
    local text, n_text, s,e
    local eol, n_eol = GetEOL()
    local ss, se = editor.SelectionStart, editor.SelectionEnd
    if ss~=se then -- there's a selection
        text, n_text = editor:GetSelText()
        s = editor:PositionFromLine(editor:LineFromPosition(ss))
        e = editor.LineEndPosition[editor:LineFromPosition(se)]
    else
        --- Returns current lines text, start and end position
        local function GetCurrentLine(pos)
            local current_pos = pos or editor.CurrentPos
            local line_idx = editor:LineFromPosition(current_pos)
            local linestart = editor:PositionFromLine(line_idx)
            local lineend = editor.LineEndPosition[line_idx]
            return editor:textrange(linestart, lineend), linestart, lineend
        end
        text, s, e = GetCurrentLine()
        n_text = #text
    end
    if vertical == -1 then -- copy upwards
        editor:InsertText(s, text..eol)
        local d = n_text+1 --@todo: why +1 and not +n_eol? i have no idea.
        ss, se = ss + d, se + d -- selection should stay at current line
    else
        editor:InsertText(e, eol..text)
    end
    if ss~=se then editor:SetSel(ss,se) end
  end
