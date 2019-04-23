Attribute VB_Name = "SaveLoadData"
'//DataAqusitionSys/////////
Public DEV1_COM_PORTN As Byte  ' Power Sypply

'// Machine 2 //////////////

Public CNF_FILE_PATH As String
 
 'Объявление функций WinAPI для работы с ini файлом
Private Declare Function WritePrivateProfileString Lib "kernel32" _
Alias "WritePrivateProfileStringA" (ByVal lpApplicationName As String, _
ByVal lpKeyName As Any, ByVal lpString As Any, ByVal lpFileName As String) As Long

Private Declare Function GetPrivateProfileString Lib "kernel32" _
Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, _
ByVal lpKeyName As Any, ByVal lpDefault As String, ByVal lpReturnedString As String, _
ByVal nSize As Long, ByVal lpFileName As String) As Long

Private Declare Function GetPrivateProfileInt Lib "kernel32" _
Alias "GetPrivateProfileIntA" (ByVal lpApplicationName As String, _
ByVal lpKeyName As String, ByVal nDefault As Long, _
ByVal lpFileName As String) As Long

' Объявление "своих" функций на основе вышеописанных для упрощения работы
Public Function IniWriteString(IniName As String, SectionName As String, KeyName As String, _
ByVal Value As String) As String
  IniWriteString = WritePrivateProfileString(SectionName, KeyName, Value, IniName)
End Function
Public Function IniReadString(IniName As String, SectionName As String, KeyName As String, _
ByVal Value As String) As String
Dim Length As Byte
    'Value - input buffer!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Value = "                                                                           "
    result = GetPrivateProfileString(SectionName, KeyName, DefaultValue, Value, 255, IniName)
    
    Value = Trim(Value)
    Length = Len(Value)
    IniReadString = Left(Value, Length - 1)
End Function

Public Function IniWriteInt(IniName As String, SectionName As String, KeyName As String, _
ByVal Value As String) As Long
  IniWriteInt = WritePrivateProfileString(SectionName, KeyName, Value, IniName)
End Function

Public Function IniReadInt(IniName As String, SectionName As String, KeyName As String, _
DefaultValue As Long) As Long
  IniReadInt = GetPrivateProfileInt(SectionName, KeyName, DefaultValue, IniName)
End Function



'///////////////////////////////////  Save Config //////////////////////////////////////////////////////////////////////
Public Sub SaveConfig() 'фиксирование значений кэффициентов

result = IniWriteInt(".\DAQ.ini", "DEV#1", "DEV1_COM_PORTN", CStr(DEV1_COM_PORTN))
result = IniWriteInt(".\DAQ.ini", "DEV#1", "DEV1_COM_SPEED", CStr(DEV1_COM_SPEED))

End Sub
Public Sub LoadConfig()

    DEV1_COM_PORTN = Val(IniReadString(".\DAQ.ini", "DEV#1", "DEV1_COM_PORTN", ""))
    DEV1_COM_SPEED = Val(IniReadString(".\DAQ.ini", "DEV#1", "DEV1_COM_SPEED", ""))
    
End Sub

Public Function LoadPRESET(FileName As String, Field As String, Param As String) As String
Dim N As Byte
Dim TEM_BUF$
    TEM_BUF$ = IniReadString(FileName, Field, Param, "")
    TEM_BUF$ = Trim(TEM_BUF$)
    N = InStr(TEM_BUF$, " ")
    If N > 0 Then
        LoadPRESET = Left(TEM_BUF$, N - 1)
    Else
        LoadPRESET = TEM_BUF$
    End If
End Function

Public Function LoadString(FileName As String, Field As String, Param As String) As String
Dim BUFF$
    BUFF$ = IniReadString(FileName, Field, Param, "")
    LoadString = Trim(BUFF$)
End Function

Public Function LoadCommand(FileName As String, Field As String, Param As String) As String
Dim N As Byte
Dim BUFF$
    BUFF$ = IniReadString(FileName, Field, Param, "")
    BUFF$ = Trim(BUFF$)
    If Len(BUFF$) > 0 Then
        LoadCommand = Trim(BUFF$)
    Else
        LoadCommand = "NO"
        BUFF$ = "Attention! Command: " & Param & " was not found in the FIELD: " & Field
        MsgBox BUFF$, vbExclamation
    End If
End Function
Public Function LoadCommand_noAttention(FileName As String, Field As String, Param As String) As String
Dim N As Byte
Dim BUFF$
    BUFF$ = IniReadString(FileName, Field, Param, "")
    BUFF$ = Trim(BUFF$)
    LoadCommand_noAttention = Trim(BUFF$)
End Function

Public Sub ApplyConfigM1()
    'M1_Poly_C0 = Form1.Txt_M1_Poly_C0.Text
    'M1_Poly_C1 = Form1.Txt_M1_Poly_C1.Text
    'M1_Poly_C2 = Form1.Txt_M1_Poly_C2.Text
    'M1_Poly_C3 = Form1.Txt_M1_Poly_C3.Text
End Sub

'////////////////////////////// Старая версия - не используется /////////////////////////////////////////////////////////

'Private Sub itmSaveConf_Click_OLD() ' СОХРАНЕНИЕ КОНФИГУРАЦИИ
'Dim StrFileName As String
'Dim strText As String
'Dim strFilter As String
'Dim strBuffer As String
'Dim FileHandle%
'-----------------------
'strFilter = "Text (*.cnf)|*.cnf|All Files (*.*)|*.*"
'cdFile.Filter = strFilter
'cdFile.ShowSave
'If cdFile.FileName <> "" Then
' StrFileName = cdFile.FileName
' FileHandle% = FreeFile
' Open StrFileName For Output As FileHandle%
' MousePointer = vbHourglass
' Print #FileHandle%, " Uref   ", Ref, "    "
' Print #FileHandle%, " FB_Kp  ", FB_Kp, "  "
' Print #FileHandle%, " FB_Ki  ", FB_Ki, "  "
' Print #FileHandle%, " FB_Kd  ", FB_Kd, "  "
' Print #FileHandle%, " Heater ", Heater, " "
' Print #FileHandle%, " T/hour ", T_hour, " "
' Print #FileHandle%, " Heat_Ki", Heat_Ki, ""
' MousePointer = vbDefault
' Close #FileHandle%
'End If
'End Sub

'Private Sub itmLoadConf_Click_OLD()   '  Загрузка конфигурационногофайла
'Dim N As Long
'Dim StrFileName As String
'Dim strText As String
'Dim strFilter As String
'Dim strBuffer As String
'Dim FileHandle%
'-----------------------
'strFilter = "Text (*.cnf)|*.cnf|All Files (*.*)|*.*"
'cdFile.Filter = strFilter
'cdFile.ShowOpen
'If cdFile.FileName <> "" Then
' StrFileName = cdFile.FileName
' FileHandle% = FreeFile
' Open StrFileName For Input As FileHandle%
' MousePointer = vbHourglass
'------------------------------------------------------
' Line Input #FileHandle%, strBuffer 'read string Ref
' strText = strBuffer '
' Ref = ConfLoad(strText)
' Line Input #FileHandle%, strBuffer 'read string FB_Kp
' strText = strBuffer '
' FB_Kp = ConfLoad(strText)
' Line Input #FileHandle%, strBuffer 'read string FB_Ki
' strText = strBuffer '
' FB_Ki = ConfLoad(strText)
' Line Input #FileHandle%, strBuffer 'read string FB_Kd
' strText = strBuffer '
' FB_Kd = ConfLoad(strText)
' Line Input #FileHandle%, strBuffer 'read string FB_Kd
' strText = strBuffer '
' Heater = ConfLoad(strText)
' Line Input #FileHandle%, strBuffer 'read string T_hour
' strText = strBuffer '
' T_hour = ConfLoad(strText)
' Line Input #FileHandle%, strBuffer 'read string Heat_Ki
' strText = strBuffer '
' Heat_Ki = ConfLoad(strText)
' '------------------------------------------------------
' MousePointer = vbDefault
' Close #FileHandle%
'End If
'End Sub

