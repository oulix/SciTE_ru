--[[--------------------------------------------------
CIViewer (Color Image Viewer)
Author: mozers�
Version: 2.0.2
------------------------------------------------------
* Preview of color or image under mouse cursor
* ������������ �����, ��������� ��������� � ���� "#6495ED" ��� "red" ��� ������� �� ��� URI
* ������ ������ ������ ��� ����������� ����������������� ��������� ���������� CIViewer.hta
-----------------------------------------------
��� ����������� ����������������� �������� � SciTEStartup.lua ������:
    dofile (props["SciteDefaultHome"].."\\tools\\CIViewer\\CIViewer.lua")

��� ������ ���������� �� ���� Tools �������� � ���� ���� .properties ��������� ������:
    command.parent.112.*=9
    command.name.112.*=Color Image Viewer
    command.112.*="$(SciteDefaultHome)\tools\CIViewer\CIViewer.hta"
    command.mode.112.*=subsystem:shellexec
--]]----------------------------------------------------

-- ����� �� ������ (������������ ������ ��������� � �������� �������)
local function FindInLine(str_line, pattern, cur_pos)
	local _start, _end, _match
	_start = 1
	repeat
		_start, _end, _match = string.find(str_line, pattern, _start)
		if _start == nil then return '' end
		if ((cur_pos >= _start) and (cur_pos < _end)) then return _match end
		_start = _end + 1
	until false
end

-- ����� ������� �������� �� URI � ������� ������� ����
local function GetURI(pos)
	local cur_line = editor:LineFromPosition(pos)
	local line_start_pos = editor:PositionFromLine(cur_line)
	local line_string = editor:GetLine(cur_line)
	local pos_from_line = pos - line_start_pos + 1

	local URI = ''
	URI = FindInLine(line_string, '"(.-)"', pos_from_line)
	if URI ~= '' then return URI end
	URI = FindInLine(line_string, "'(.-)'", pos_from_line)
	if URI ~= '' then return URI end
	URI = FindInLine(line_string, '%((.-)%)', pos_from_line)
	if URI ~= '' then return URI end
	URI = FindInLine(line_string, '([^%s"|=]+)', pos_from_line)
	return URI
end

AddEventHandler("OnDwellStart", function(pos, word)
	if pos ~= 0 then
		-- ����������� �������� ���������� (CIViewer.hta ����� ������������ �� ���������)
		props["civiewer.word"] = word
		props["civiewer.pos"] = pos
		props["civiewer.uri"] = GetURI(pos)
	end
end)
