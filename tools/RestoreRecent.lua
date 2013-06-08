--[[--------------------------------------------------
RestoreRecent.lua
Authors: mozers�
Version: 1.2.4
------------------------------------------------------
Description:
  Restore position, bookmarks, folds at opening recent file
  ��������������� ������� �������, �������� � ������� ��� ��������� �������� �����
  (������������ ������ ����� SciTE.session, ������� ������ ���� ��������� ����������
  import home\SciTE.session
  �������� save.session.recent=1 ��������� ������������ ��� ���������� � �������������� ������ ���� SciTE.recent
  � ���� ������ ������� �������, �������� � ������� ����������������� � ���� ������������� ������.
  ��� ����� �������� ��� ������� ������� RestoreRecent.js, ������������� � ��� �� �������� ��� � ������ ������.

  ����� ������ ������������� ����������� ��� ������ ��� �������� ������
  � ������������ ��������� ���������� fold.on.open.ext
------------------------------------------------------
Connection:
 In file SciTEStartup.lua add a line:
    dofile (props["SciteDefaultHome"].."\\tools\\RestoreRecent.lua")

 Set in a file .properties (optional):
    save.session.recent=1
    fold.on.open.ext=properties,ini
--]]--------------------------------------------------
require 'shell'

----------------------
-- ON STARTUP SCITE --
----------------------
local buffers = {} -- ����� {�����_�����, {���_���������, ��������_���������} }
local opened = {} -- ������ � ������� ��������� ���� �� ���� ����������� ������

-- ������ ���������� SciTE.session � ������� buffers (��������� ��������, ��������� ���� ��������� ���������� import)
local function ReadSessionToTable()
	for i = 1, props['buffers'] do
		local path = props['buffer.'..i..'.path']
		if path ~= '' then
			-- ���� ������� ������� �����������, �� ������� ��� (��� ��������� �������)
			if buffers[i] == nil then buffers[i] = {} end
			buffers[i].path = path
		else
			break
		end

		local position = props['buffer.'..i..'.position']
		if position ~= '' then buffers[i].position = position end

		local bookmarks = props['buffer.'..i..'.bookmarks']
		if bookmarks ~= '' then buffers[i].bookmarks = bookmarks end

		local folds = props['buffer.'..i..'.folds']
		if folds ~= '' then buffers[i].folds = folds end
	end
end

-- ������ ���������� SciTE.recent � ������� buffers
local function ReadRecentToTable()
	local recent_file = io.open(props['SciteUserHome']..'\\SciTE.recent')
	if recent_file then
		local pattern = "buffer%.(%d+)%.(%a+)=(.+)"
		for line in recent_file:lines() do
			if #line > 10 then
				-- �����_�����, ���_���������, ��������:
				local num, prop, value = string.match (line, pattern)
				if num ~= nil then
					num = tonumber(num)
					-- ���� ������� ������� �����������, �� ������� ��� (��� ��������� �������)
					if buffers[num] == nil then buffers[num] = {} end
					buffers[num][prop] = value
				end
			end
		end
		recent_file:close()
	end
end

-- � ����������� �� ������� ��������� save.session.recent=1 ��������
-- ������� �� ������ ����� ����� ��������� ������� buffers
if tonumber(props['save.session.recent']) == 1 then
	ReadRecentToTable() -- ������ �������� �� ����� SciTE.recent
else
	ReadSessionToTable() -- ������ ������� �� ���������� SciTE.session
end

------------------
-- ON OPEN FILE --
------------------

-- �������� ������� � ������� buffers ������ � ������� �����
local function CheckSession()
	for i = 1, #buffers do
		-- ��� ������� ������ ���������� ������ ���� ���������� (� �� ��������) ��� ����� �����
		if buffers[i]['path']:lower() == props['FilePath']:lower() then return buffers[i] end
	end
end

-- �������������� ������� �������, ��������� � �������� ��� ��������� �����
local function Restore(file)
	local FileParams = CheckSession() -- �������� ������� ������ � ����� � ������� buffers
	if FileParams ~= nil then
		-- Restore folding
		if tonumber(props['session.folds']) == 1 then
			local folds = FileParams['folds']
			if folds ~= nil then
				for line_num in string.gmatch(folds, "%d+") do
					line_num = tonumber(line_num)-1
					if editor.FoldExpanded[line_num] then
						editor:ToggleFold(line_num)
					end
				end
			end
		end
		-- Restore bookmarks
		if tonumber(props['session.bookmarks']) == 1 then
			local bookmarks = FileParams['bookmarks']
			if bookmarks ~= nil then
				for line_num in string.gmatch(bookmarks, "%d+") do
					editor:MarkerAdd(tonumber(line_num)-1, 1)
				end
			end
		end
		-- Restore position
		if tonumber(props['save.position']) == 1 then
			local pos = FileParams['position']
			if pos ~= nil then
				editor:GotoPos(pos-1)
			end
		end
	else
		local toggle_foldall_ext = props['fold.on.open.ext']:lower()
		local current_ext = props['FileExt']:lower()
		for ext in toggle_foldall_ext:gmatch("%w+") do
			if current_ext == ext then scite.MenuCommand (IDM_TOGGLE_FOLDALL) end
		end
	end
end

AddEventHandler("OnOpen", function(file)
	if tonumber(props['save.session']) == 1 then
		if file ~= '' then opened[file] = true end
	end
end)

AddEventHandler("OnUpdateUI", function()
	local file = props["FilePath"]
	if opened[file] then
		Restore(file)
		opened[file] = nil
	end
end)

-----------------------
-- ON FINALISE SCITE --
-----------------------

AddEventHandler("OnFinalise", function()
	if props['FileName'] ~= '' then
		if tonumber(props['save.session.recent']) == 1 then
			-- ������ ���������������� ������� ��� ���������� ������ � SciTE.recent
			-- (������ � ���.������ �������� � ���������� ������ ������ � �������������� SciteUserHome)
			local script_dir = debug.getinfo(1, "S").source:gsub('^@(.+\\).-$', '%1')
			script_dir = script_dir
			local cmd = 'wscript "'..script_dir..'RestoreRecent.js" "'..props["SciteUserHome"]..'"'
			shell.exec(cmd, nil, true, false)
		end
	end
end)
