'  This - an example and descriptions of all available methods SciTE Helper:
'  ��� - ������ � �������� ���� ��������� ������� SciTE Helper:
'  ===============================================
'  In the beginning we create object
'  ������� ������� ������
On Error Resume Next
Set SciTE = CreateObject("SciTE.Helper")
If Err.Number <> 0 Then
	WScript.Echo "Please install SciTE Helper before!"
	WScript.Quit 1
End If
On Error GoTo 0

' ������ ������ � ���� ������� (��� �������� � �������� ������)
' Writes string to the output pane (no prefix, no newlines)
SciTE.Trace("Example of all available methods:\n\n")

' SciTE window size and position
SciTE.Trace ("position.Left = " & SciTE.Left & "\n")
SciTE.Trace ("position.top = " & SciTE.Top & "\n")
SciTE.Trace ("position.width = " & SciTE.Width & "\n")
SciTE.Trace ("position.height = " & SciTE.Height & "\n\n")

'  Get all text with active page
'  ��������� ���� ����� � �������� ��������
all_text = SciTE.GetText

SciTE.Send ("find:scite")
'  Get only selected text with active page
'  ��������� ������ ���������� ����� � �������� ��������
sel_text = SciTE.GetSelText
SciTE.Trace ("Selected text: """ & sel_text & """\n")

'  Replace selected on active page text on our
'  �������� ���������� �� �������� �������� ����� �� ���
'~ SciTE.ReplaceSel ("<http://scite-ru.org>")

'  Run command use SciTE Lua Scripting Extension
'  ��������� LUA ������� � �������� ���������
CurrentPos = SciTE.LUA("editor.CurrentPos")
SciTE.Trace ("editor.CurrentPos = " & CurrentPos & "\n")

'  ������ ���� � property � ��� ��������
'  Set the value of a property
value = WScript.FullName
SciTE.Props("my.key") = WScript.Name

'  ������ �������� ��������� �����
'  Return the value of a property
prop = SciTE.Props ("my.key")
SciTE.Trace ("my.key = " & prop & "\n")

'  Send actions use SciTE Director Interface
'  List of all available commands - in file SciTEDirector.html
'  �������� ������� ��������� SciTE Director Interface
'  ������ ���� ��������� ������ - � ����� SciTEDirector.html
filename  = SciTE.Send ("askfilename:")
filename = Replace(filename,"\","\\")
SciTE.Trace (filename & "\n")

'  Run internal menu command SciTE (call "About" window)
'  List of all available commands - in file SciTE.h
'  �������� ���������� ������� ���� SciTE (������ "� ���������")
'  ������ ���� ��������� ������ - � ����� SciTE.h
SciTE.MenuCommand (902)

'  �� ��� �� ��� ����� :)
SciTE.About()
