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
'       It will create txt files containing the data to import into Excel
'       Important point is to have one file for the 340 nm and one for the 380 nm
'       If you need to import a single wavelength dataset, you can use the other vba script
'       called "FURA-Analysis_2_MnQuench", it will import into excel any txt file generated
'       from the "FURA-Analysis_1.ijm"
'
'   Christopher Henry - V1 - 2019-03-16
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
    FileDate = Mid(File, 1, 10)
    Exit For
Next objfile

Workbooks.Add
ActiveWorkbook.SaveAs Filename:=PathFinal & FileDate, FileFormat:=xlOpenXMLWorkbook
ActiveWorkbook.Sheets.Add Count:=3
Sheets(1).Name = "340 nm"
Sheets(2).Name = "380 nm"
Sheets(3).Name = "340 div 380"
Sheets(4).Name = "R div R0"

ctotal = 1
For Each objfile In objFolder.Files
    
    File = objfile.Name
    If InStr(1, File, "dish") <> 0 Then
        DishNumber = Mid(File, InStr(1, File, "dish"), 7)
    ElseIf InStr(1, File, "Dish") <> 0 Then
        DishNumber = Mid(File, InStr(1, File, "Dish"), 7)
    End If
    
    If (InStr(1, File, "340") = 0 And InStr(1, File, "380") = 0) Then
        GoTo ContinueLoop
    End If
    
    Workbooks.Open Filename:=Path & File
    Workbooks(File).Activate
    
    r = Range("A1").End(xlDown).Row
    c = Range("A1").End(xlToRight).Column
    
    Workbooks(File).Activate
    ToCopy = Workbooks(File).Worksheets(1).Range(Cells(1, 1), Cells(r, c)).Value
    
    Workbooks(FileDate).Activate
    If InStr(1, File, "340") <> 0 Then
        Workbooks(FileDate).Worksheets(1).Activate
        Workbooks(FileDate).Worksheets(1).Range(Cells(3, 3 + ctotal), Cells(r + 2, ctotal + c + 2)).Value = ToCopy
        Workbooks(FileDate).Worksheets(1).Range(Cells(1, 3 + ctotal), Cells(1, ctotal + c + 2)).Value = DishNumber
        Workbooks(FileDate).Worksheets(3).Activate
        Workbooks(FileDate).Worksheets(3).Range(Cells(1, 3 + ctotal), Cells(1, ctotal + c + 2)).Value = DishNumber
        Workbooks(FileDate).Worksheets(4).Activate
        Workbooks(FileDate).Worksheets(4).Range(Cells(1, 3 + ctotal), Cells(1, ctotal + c + 2)).Value = DishNumber
        For i = 1 To c
            Workbooks(FileDate).Worksheets(1).Activate
            Workbooks(FileDate).Worksheets(1).Cells(2, ctotal + i + 2).Value = "Cell" & i
            Workbooks(FileDate).Worksheets(3).Activate
            Workbooks(FileDate).Worksheets(3).Cells(2, ctotal + i + 2).Value = "Cell" & i
            Workbooks(FileDate).Worksheets(4).Activate
            Workbooks(FileDate).Worksheets(4).Cells(2, ctotal + i + 2).Value = "Cell" & i
        Next
    ElseIf InStr(1, File, "380") <> 0 Then
        Workbooks(FileDate).Worksheets(2).Activate
        Workbooks(FileDate).Worksheets(2).Range(Cells(3, 3 + ctotal), Cells(r + 2, ctotal + c + 2)).Value = ToCopy
        Workbooks(FileDate).Worksheets(2).Range(Cells(1, 3 + ctotal), Cells(1, ctotal + c + 2)).Value = DishNumber
        For i = 1 To c
            Workbooks(FileDate).Worksheets(2).Cells(2, ctotal + i + 2).Value = "Cell" & i
        Next
        ctotal = ctotal + c + 1
    End If
    
    Workbooks(File).Close
ContinueLoop:
Next objfile

Workbooks(FileDate).Worksheets(3).Activate
Workbooks(FileDate).Worksheets(3).Range(Cells(3, 4), Cells(r + 2, ctotal + 2)).Formula = "=IF(ISBLANK('340 nm'!D3)," & Chr(34) & Chr(34) & ",'340 nm'!D3/'380 nm'!D3)"

Workbooks(FileDate).Worksheets(4).Activate
Workbooks(FileDate).Worksheets(4).Range(Cells(3, 4), Cells(r + 2, ctotal + 2)).Formula = "=IF(ISBLANK('340 nm'!D3)," & Chr(34) & Chr(34) & ",'340 div 380'!D3/AVERAGE('340 div 380'!D$3:D$13))"



Workbooks(FileDate).Activate
ActiveWorkbook.Save
MsgBox ("Job done")

End Sub
