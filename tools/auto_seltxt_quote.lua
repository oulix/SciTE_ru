-- [[--------------------------------------------------
-- auto_seltxt_quote.lua
-- author: jianxin.ou@gmail.com
-- version 1.0.0
-------------------------------------------------------
-- select some of text, then input char " ' [ { ( <  or > ) }  ] ' ", will automaticly 
-- add coresponding char at the sel text begin/end pos.

-- SciteStartup.lua:
-- dofile (props["SciteDefaultHome"].."\\tools\\auto_seltxt_quote.lua")
-- 
--]]---------------------------------------------------- 




local function auto_seltxt_quote(charAdded)
   local sel_text = editor:GetSelText()
   local rep_text = ''   
   editor:ReplaceSel( rep_text )
end



AddEventHandler("OnKey", function(key, shift, ctrl, alt, char)
	if editor.Focus and ctrl then
    return auto_seltxt_quote(char) -- true - break event
  end
end)
