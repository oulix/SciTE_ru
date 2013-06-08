/*
RestoreRecent.js
Authors: mozers�
Version: 1.5.2
------------------------------------------------------
Description:
  It is started on close SciTE (from RestoreRecent.lua)
  Save position, bookmarks, folds to SciTE.recent file
  ����������� ��� �������� SciTE �� ������� RestoreRecent.lua
  ������ ������� �������, �������� � ������� �� ����� SciTE.session � ��������� ��� ���� SciTE.recent
*/
var link_age_max = 7; // ���� ����� ������ � SciTE.recent (����)

var WshShell = new ActiveXObject("WScript.Shell");
var FSO = new ActiveXObject("Scripting.FileSystemObject");

// ������ SciTE.recent � ������ ��������, ������ �� ������� ����� �������� date, path, position, bookmarks � folds
function ReadRecentFile(filename) {
	var arr = [];
	if (FSO.FileExists(filename)) {
		if (FSO.GetFile(filename).Size > 0) {
			var file = FSO.OpenTextFile(filename, 1);
			while (!file.AtEndOfStream){
				var line = file.ReadLine();
				var r = line.match(/buffer\.(\d+)\.([a-z]+)=(.+)$/);
				if (r) { // r = ������: {1-�����_�����, 2-���_���������, 3-��������}
					var link_num = r[1];
					if (!arr[link_num]) arr[link_num] = {};
					arr[link_num][r[2]] = r[3];
				}
			}
			file.Close();
		}
	}
	return(arr);
}

// ������ SciTE.session � ������, �������� ������� � ��� ����������� �������
function ReadSessionFile(filename){
	// Return date as string 'dd.mm.yyyy'
	function DateString(){
		function format(x){return (x < 10) ? ('0' + x) : String(x);}
		var d = new Date();
		var year = String(d.getYear());
		var month = format(d.getMonth()+1);
		var day = format(d.getDate());
		return day + '.' + month + '.' + year;
	}

	// �������� ������� � ������� ������ � ������ �����
	function IsRecent(filespec){
		for (var i=1; i<recent_arr.length; i++) {
			if (recent_arr[i].path.toLowerCase() == filespec.toLowerCase()) {
				break;
			}
		}
		// ���� ������ � ����� ���������� - ������� ��� ������� ������ � ���
		// ���� ������ ���������� - ������� �� � ���������� ����� ������ �������
		recent_arr[i] = {};
		recent_arr[i].date = cur_date_string;
		return i;
	}

	if (FSO.FileExists(filename)) {
		if (FSO.GetFile(filename).Size > 0) {
			var file = FSO.OpenTextFile(filename, 1);
			var cur_date_string = DateString();
			var x;
			while (!file.AtEndOfStream) {
				var line = file.ReadLine();
				var r = line.match(/buffer\.(\d+)\.([a-z]+)=(.+)$/);
				if (r) { // r = ������: {1-�����_�����, 2-���_���������, 3-��������}
					if (r[2] == 'path') x = IsRecent(r[3]);
					if (r[2] != 'current') recent_arr[x][r[2]] = r[3];
				}
			}
			file.Close();
		}
	}
}

// ������� ����� �� �������
// (������ � ������ � ������� ������������ ���� ������ �� ������� �, ��� � ���� - ������ ������)
function RemoveWaste(){
	// ��� ����������� SciTE.recent ?
	function IsTodaysRecent(){
		if (FSO.FileExists(recent_filename)) {
			var recent_date = FSO.GetFile(recent_filename).DateLastModified;
			var current_date = new Date();
			var date_diff = new Date(current_date - recent_date);
			if (parseInt(date_diff/86400000) === 0) return true;
		}
		return false;
	}

	// ����������� �������� ������
	function LinkAge(link_date_string){
		var arrDate = link_date_string.match(/(\d+)\.(\d+)\.(\d+)/);
		var current_date = new Date();
		var link_date = new Date(arrDate[3], arrDate[2]-1, arrDate[1]);
		var date_diff = new Date(current_date.valueOf() - link_date.valueOf());
		return parseInt(date_diff/86400000);
	}

	// ����������� ���-�� ��-null-���� ���������� � �������
	function CountParams(arr){
		var count = 0;
		for (var i in arr){
			if (arr[i]) count++;
		}
		return count;
	}

	// ������� ����������������� ������
	for (var i in recent_arr){
		if ((CountParams(recent_arr[i]) == 3) && (recent_arr[i].position == 1)) {
		// ���� � ������ � ����� ������ 3 ��������� {����,�������,����} � �������=1 ��:
			recent_arr[i] = null;
		}
	}

	// ������� ������ ������
	if (!IsTodaysRecent()) { // ��������� ������� ����������� ������ 1 ��� � ����
		for (var j in recent_arr){
			if (recent_arr[j]){
				if (LinkAge(recent_arr[j].date) > link_age_max){
					// ���� ������� ����� ������ ���������� ���������� ����, ��:
					recent_arr[j] = null;
				}
			}
		}
	}
}

// C�������� ������ � SciTE.recent
function SaveRecentFile(filename){
	try {
		var file = FSO.OpenTextFile(filename, 2, true);
	} catch(e) {
		WshShell.Popup(filename+"\nPermission denied!", 10, "Restore Recent", 16);
		WScript.Quit(1);
	}
	var buf = 0;
	for (var i in recent_arr){
		if (recent_arr[i]){
			buf++;
			for (var params in recent_arr[i]) {
				file.WriteLine('buffer.' + buf + '.' + params + '=' + recent_arr[i][params]);
			}
			file.WriteLine(''); // ����� ��� ������� :)
		}
	}
	file.Close();
}

try {
	var scite_user_home = WScript.Arguments(0); // ���� �������� ���������� � ���.������ ������������� ������� (RestoreRecent.lua)
	if (!FSO.FolderExists(scite_user_home)) {
		WshShell.Popup("Folder SciteUserHome\n"+scite_user_home+"\nNOT EXIST!", 10, "Restore Recent", 16);
		WScript.Quit(1);
	}
} catch(e) {
	WScript.Echo('This script started only from RestoreRecent.lua!');
	WScript.Quit(1);
}

var session_filename = scite_user_home + '\\SciTE.session';
var recent_filename = scite_user_home + '\\SciTE.recent';
var recent_arr = ReadRecentFile(recent_filename);

ReadSessionFile(session_filename);
RemoveWaste();
SaveRecentFile(recent_filename);
