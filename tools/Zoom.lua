--[[-------------------------------------------------
Zoom.lua
Version: 1.2.3
Authors: mozers�, ������� ������
-----------------------------------------------------
��������� ����������� ������� Zoom
������ � ������������� ��������, �������������� � ��������� �� ������� �����
�������� �������� ���������������� ���������� font.current.size, ������������ ��� ����������� ������� ������� ������ � ������ ���������
�������� �������� ���������� (magnification, print.magnification, output.magnification) ����������� � ������� save_settings.lua
-----------------------------------------------------
��� ����������� �������� � ���� .properties:
  statusbar.text.1=$(font.current.size)px
� ���� SciTEStartup.lua:
  dofile (props["SciteDefaultHome"].."\\tools\\Zoom.lua")
--]]-------------------------------------------------

local function ChangeFontSize(zoom)
	if output.Focus then
		props["output.magnification"] = output.Zoom
	else
		props["magnification"] = zoom
		props["print.magnification"] = zoom
		if props["pane.accessible"] == '1' then
			editor.PrintMagnification = zoom
		end
		local font_current_size = props["style.*.32"]:match("size:(%d+)")
		props["font.current.size"] = font_current_size + zoom -- Used in statusbar
		scite.UpdateStatusBar()
	end
end

-- ��������� ���� ���������� ������� OnSendEditor
AddEventHandler("OnSendEditor", function(id_msg, wp, lp)
	if id_msg == SCI_SETZOOM then
		ChangeFontSize(lp)
	end
end)
