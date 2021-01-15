Sub Macro()

'
'   Second part of the macro to analyse FURA experiments
'
'   READ INSTRUCTION BEFORE USE:
'
'       This Excel file need to be localised withing the main folder containing
'       the subfolder "3_Analysis"
'
'       Works only if you used the script "FURA-Analysis_1.ijm" before
'       Import a single wavelength dataset into excel from txt file generated
'       with the "FURA-Analysis_1.ijm"
'
'   Christopher Henry - V1 - 2019-04-3
'

Dim Path As String
Dim File As String
Dim Extension As String
Dim PathFile As String
Dim x As Integer
Dim LineValue As String
Dim Table1 As Variant


PathFinal = Application.ThisWorkbook.Path & "\"
Path = PathFinal & "3_Analysis\"
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFolder = objFSO.GetFolder(Path)

For Each objfile In objFolder.Files
    File = objfile.Name
    FileDate = Replace(File, ".txt", "")
    Exit For
Next objfile

Workbooks.Add
ActiveWorkbook.SaveAs Filename:=PathFinal & FileDate, FileFormat:=xlOpenXMLWorkbook
ActiveWorkbook.Sheets.Add Count:=1
Sheets(1).Name = "360 nm"
Sheets(2).Name = "F div F0"

ctotal = 1
For Each objfile In objFolder.Files
    File = objfile.Name
    
    DishNumber = File
    
    Workbooks.Open Filename:=Path & File
    Workbooks(File).Activate
    
    r = Range("A1").End(xlDown).Row
    c = Range("A1").End(xlToRight).Column
    
    Workbooks(File).Activate
    ToCopy = Workbooks(File).Worksheets(1).Range(Cells(1, 1), Cells(r, c)).Value
    
    Workbooks(FileDate).Activate
    Workbooks(FileDate).Worksheets(1).Activate
    Workbooks(FileDate).Worksheets(1).Range(Cells(3, 3 + ctotal), Cells(r + 2, ctotal + c + 2)).Value = ToCopy
    Workbooks(FileDate).Worksheets(1).Range(Cells(1, 3 + ctotal), Cells(1, ctotal + c + 2)).Value = DishNumber
    Workbooks(FileDate).Worksheets(2).Activate
    Workbooks(FileDate).Worksheets(2).Range(Cells(1, 3 + ctotal), Cells(1, ctotal + c + 2)).Value = DishNumber
    For i = 1 To c
        Workbooks(FileDate).Worksheets(1).Activate
        Workbooks(FileDate).Worksheets(1).Cells(2, ctotal + i + 2).Value = "Cell" & i
        Workbooks(FileDate).Worksheets(2).Activate
        Workbooks(FileDate).Worksheets(2).Cells(2, ctotal + i + 2).Value = "Cell" & i
    Next
    ctotal = ctotal + c + 1
    
    Workbooks(File).Close
Next objfile

Workbooks(FileDate).Worksheets(2).Activate
Workbooks(FileDate).Worksheets(2).Range(Cells(3, 4), Cells(r + 2, ctotal + 2)).Formula = "=IF(ISBLANK('360 nm'!D3)," & Chr(34) & Chr(34) & ",'360 nm'!D3/AVERAGE('360 nm'!D$3:D$13))"



Workbooks(FileDate).Activate
ActiveWorkbook.Save
MsgBox ("Job done")

End Sub
