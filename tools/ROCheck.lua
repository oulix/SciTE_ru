--[[--------------------------------------------------
ROCheck.lua
Authors: Midas, VladVRO
Version: 1.1.1
------------------------------------------------------
������ ��� �������������� ��������� R/O ������ ��� ������
� �������-�� ����������� RHS
------------------------------------------------------
�����������:
  �������� � SciTEStartup.lua ������
    dofile (props["SciteDefaultHome"].."\\tools\\ROCheck.lua")
--]]--------------------------------------------------

local function ROCheck()
	-- ������� ��������� �����
	local FileAttr = props['FileAttr']
-- ���� ����� ���������� ReadOnly/Hidden/System, � �� ���������� ����� R/O
	if string.find(FileAttr, "[RHS]") and not editor.ReadOnly then
	-- �� ��������� ����� R/O
		scite.MenuCommand(IDM_READONLY)
	end
end

-- ��������� ���� ���������� ������� OnOpen
AddEventHandler("OnOpen", ROCheck)
