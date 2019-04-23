VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "comdlg32.ocx"
Object = "{648A5603-2C6E-101B-82B6-000000000014}#1.1#0"; "mscomm32.ocx"
Begin VB.Form Form1 
   Caption         =   "ZET BOOT LOADER V2.0 2013.06.24"
   ClientHeight    =   3645
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   6600
   LinkTopic       =   "Form1"
   ScaleHeight     =   3645
   ScaleWidth      =   6600
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   405
      Left            =   150
      TabIndex        =   17
      Top             =   2700
      Width           =   765
   End
   Begin VB.CommandButton Cmd_CLS 
      Caption         =   "CLS"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   435
      Left            =   1830
      TabIndex        =   16
      Top             =   2490
      Width           =   1395
   End
   Begin VB.TextBox Text1 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   405
      Left            =   90
      TabIndex        =   15
      Top             =   3090
      Width           =   6375
   End
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Interval        =   1
      Left            =   1200
      Top             =   2040
   End
   Begin VB.TextBox TXT_START 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   450
      Left            =   2370
      TabIndex        =   11
      Text            =   "9000"
      Top             =   660
      Width           =   885
   End
   Begin VB.CommandButton cmdReadValues 
      Caption         =   "LOAD FILE"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   150
      TabIndex        =   10
      Top             =   120
      Width           =   3135
   End
   Begin VB.CommandButton Cmd_LOAD_TEST_PROG 
      Caption         =   "LOAD TEST PROG"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   3360
      TabIndex        =   9
      Top             =   2460
      Width           =   3135
   End
   Begin VB.Frame Frame1 
      Height          =   2265
      Left            =   3360
      TabIndex        =   0
      Top             =   90
      Width           =   3135
      Begin VB.TextBox Txt_Exec_ADDR 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   13.5
            Charset         =   204
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   450
         Left            =   2130
         TabIndex        =   8
         Text            =   "E05B"
         Top             =   1680
         Width           =   885
      End
      Begin VB.TextBox Txt_NofByte 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   13.5
            Charset         =   204
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   450
         Left            =   2130
         TabIndex        =   7
         Text            =   "6F00"
         Top             =   1140
         Width           =   885
      End
      Begin VB.TextBox Txt_LoadADDR 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   13.5
            Charset         =   204
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   450
         Left            =   2130
         TabIndex        =   6
         Text            =   "9000"
         Top             =   660
         Width           =   885
      End
      Begin VB.CommandButton Cmd_SET_EXEC_ADDR 
         Caption         =   "EXEC"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   13.5
            Charset         =   204
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   495
         Left            =   90
         TabIndex        =   5
         Top             =   1710
         Width           =   1935
      End
      Begin VB.CommandButton Cmd_SET_NofB 
         Caption         =   "Nof BYTEs"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   13.5
            Charset         =   204
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   495
         Left            =   90
         TabIndex        =   4
         Top             =   1170
         Width           =   1935
      End
      Begin VB.CommandButton Cmd_SET_ADDR 
         Caption         =   "LOAD ADDR"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   13.5
            Charset         =   204
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   495
         Left            =   90
         TabIndex        =   3
         Top             =   660
         Width           =   1935
      End
      Begin VB.CommandButton Cmd_SET_SEG 
         Caption         =   "SEGMENT"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   13.5
            Charset         =   204
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   495
         Left            =   90
         TabIndex        =   2
         Top             =   150
         Width           =   1935
      End
      Begin VB.TextBox Txt_SEGADDR 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   13.5
            Charset         =   204
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   450
         Left            =   2130
         TabIndex        =   1
         Text            =   "F000"
         Top             =   180
         Width           =   885
      End
   End
   Begin MSCommLib.MSComm MSComm1 
      Left            =   30
      Top             =   2040
      _ExtentX        =   1005
      _ExtentY        =   1005
      _Version        =   393216
      DTREnable       =   -1  'True
      BaudRate        =   38400
   End
   Begin MSComDlg.CommonDialog cdFile 
      Left            =   660
      Top             =   2040
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.Label LB_INFOR 
      Caption         =   "Label2"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   120
      TabIndex        =   14
      Top             =   1590
      Width           =   3135
   End
   Begin VB.Label Lb_File_Length 
      Caption         =   "File L:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   150
      TabIndex        =   13
      Top             =   1140
      Width           =   3105
   End
   Begin VB.Label Label1 
      Caption         =   "START ADDR"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   180
      TabIndex        =   12
      Top             =   690
      Width           =   2115
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim N As Long
Dim Timer_Val As Long
Dim InpBuff As String
Dim Info$, inp$, TMP_BUFF$

Private Sub Command1_Click()
MSComm1.Output = Chr$(&H1) & Chr$(&H0)
End Sub

Private Sub Form_Load()
Dim BAUD_RATE As Long
Dim ComPortN As Byte

  CurrDir$ = App.Path ' Путь к катлогу рабочей программы
  CNF_FILE_PATH = App.Path & "\BOOT.cnf"
  Form1.cdFile.InitDir = CurrDir$
  cdFile.FileName = CurrDir$ & "\"      ' имя файла
  
  '''''''''''''' COM_PORT'''''''''''''''''''''''''''''''''''''''''''
  ComPortN = Val(LoadPRESET(CNF_FILE_PATH, "COM_PORT", "ComPortN"))
  BAUD_RATE = Val(LoadPRESET(CNF_FILE_PATH, "COM_PORT", "BAUD_RATE"))
  COMport1_Open ComPortN, BAUD_RATE
  '''''''''''''''''''''''
  Form1.Caption = Form1.Caption & " | " & CStr(ComPortN) & " | " & CStr(BAUD_RATE)
  
  Txt_SEGADDR.Text = LoadString(CNF_FILE_PATH, "BOOT", "SEGMENT")
  Txt_LoadADDR.Text = LoadString(CNF_FILE_PATH, "BOOT", "ADDRESS")
  Txt_NofByte.Text = LoadString(CNF_FILE_PATH, "BOOT", "NofBytes")
  Txt_Exec_ADDR.Text = LoadString(CNF_FILE_PATH, "BOOT", "EXEC_ADDR")
  ''''''
  TXT_START.Text = LoadString(CNF_FILE_PATH, "FILE", "START_ADR")
  
End Sub
Private Sub Cmd_CLS_Click()
    InpBuff = ""
    Text1.Text = ""
End Sub
Private Sub MSComm1_OnComm()

Dim l, R As Integer
Dim Lens As Integer
'--------------------------------
Select Case MSComm1.CommEvent
  Case comEvReceive
  inp$ = MSComm1.Input
  InpBuff = InpBuff & inp$
  Lens = Len(InpBuff)
  '----------
  Text1.Text = InpBuff
End Select
End Sub

Private Sub Cmd_LOAD_TEST_PROG_Click()
MSComm1.Output = Chr$(&HBA) & Chr$(&H2) & Chr$(&HF1) & Chr$(&HB8) & Chr$(&HF0) & Chr$(&H0) & Chr$(&HEF) & Chr$(&HF4)
End Sub

Private Sub Cmd_SET_ADDR_Click()
    TxData_int CLng("&H" & Txt_LoadADDR.Text)
End Sub

Private Sub Cmd_SET_EXEC_ADDR_Click()
    TxData_int CLng("&H" & Txt_Exec_ADDR.Text)
End Sub

Private Sub Cmd_SET_NofB_Click()
    TxData_int CLng("&H" & Txt_NofByte.Text)
End Sub

Private Sub Cmd_SET_SEG_Click()
    TxData_int CLng("&H" & Txt_SEGADDR.Text)
End Sub

Private Sub cmdReadValues_Click()
Dim file_name As String
Dim file_length As Long
Dim fnum As Integer
Dim bytes() As Byte
Dim bytes_64k() As Byte
Dim txt As String
Dim i As Long
Dim Shift As Long
Dim Portions As Long
Dim P_START As Long
Dim P_STOP As Long

LB_INFOR.Caption = ""
'======================================
  strFilter = "BIN (*.ROM)|*.ROM"
  Form1.cdFile.Filter = strFilter
  Form1.cdFile.FileName = ""
  Form1.cdFile.ShowSave
  
    file_name = Form1.cdFile.FileName
    file_length = FileLen(file_name)
    Lb_File_Length.Caption = "File L: " & CStr(file_length)
    Portions = file_length / &H10000

    fnum = FreeFile
    ReDim bytes(1 To file_length)
    P_START = CLng("&H" & TXT_START.Text)
    P_STOP = P_START + CLng("&H" & Txt_NofByte.Text)
    P_Length = CLng("&H" & Txt_NofByte.Text)

    ReDim bytes_64k(1 To P_Length)

    Open file_name For Binary As #fnum
    Get #fnum, 1, bytes
    Close fnum
    N = 0
    LB_INFOR.Caption = ""
    
    InpBuff = "1" ' For Start
    inp$ = ""
        For i = 1 To P_Length
            'Do While InpBuff = "" ' выполняется покуда True
            '    DoEvents
            'Loop
            InpBuff = ""
            inp$ = ""
            MSComm1.Output = Chr$(bytes(i + P_START))
            N = N + 1
            '
            ''''''''''''''''''''''''''''''''''''''''
            'LB_INFOR.Caption = "L/B :" & CStr(Hex(N))
            'DoEvents
        Next i
    LB_INFOR.Caption = "L/B :" & CStr(Hex(N))
End Sub

Private Sub Delay(TIC As Long)
Dim i As Long
    For i = 0 To TIC
        DoEvents
    Next
End Sub

Private Sub cmdWriteValues_Click()
Dim file_name As String
Dim file_length As Long
Dim fnum As Integer
Dim bytes() As Byte
Dim txt As String
Dim i As Integer
Dim values As Variant
Dim num_values As Integer

    ' Build the values array.
    values = Split(txtValues.Text, vbCrLf)
    For i = 0 To UBound(values)
        If Len(Trim$(values(i))) > 0 Then
            num_values = num_values + 1
            ReDim Preserve bytes(1 To num_values)
            bytes(num_values) = values(i)
        End If
    Next i

    ' Delete any existing file.
    file_name = txtFile.Text
    On Error Resume Next
    Kill file_name
    On Error GoTo 0

    ' Save the file.
    fnum = FreeFile
    Open file_name For Binary As #fnum
    Put #fnum, 1, bytes
    Close fnum

    ' Clear the results.
    txtValues.Text = ""
End Sub

'//////////////////
Private Sub COMport1_Open(ComPortN As Byte, BAUD_RATE As Long)
Dim TmpBuff$, IDN_CMD$, SFX$, IDN_RESP$
Dim Length, position, offset As Byte
Dim Message As String

On Error GoTo UnexpectedError

    If MSComm1.PortOpen = True Then
        MSComm1.PortOpen = False
    End If
    MSComm1.CommPort = ComPortN '
    TmpBuff$ = Str(BAUD_RATE) & ",N,8,1"
    TmpBuff$ = Trim(TmpBuff$)
    MSComm1.Settings = TmpBuff$
    MSComm1.InputLen = 0
    MSComm1.RThreshold = 1
    ' Open the port.
    If MSComm1.PortOpen = False Then
       MSComm1.PortOpen = True
    End If

Exit Sub
    
UnexpectedError:
    Message = "COM Port could not be open"
    MsgBox Message, vbExclamation
End Sub

'/////////////////////////////////////////////////
Sub TxData_int(Dat16 As Long)
Dim Char As Byte
  Char = LO(Dat16)
  MSComm1.Output = Chr$(Char)
  Char = HI(Dat16)
  MSComm1.Output = Chr$(Char)
End Sub

Function HI(Dat16 As Long)
  HI = Fix(Dat16 / 256)
End Function

Function LO(Dat16 As Long)
  Dat16HI = Fix(Dat16 / 256)
  Dat16MD = 256 * CSng(Dat16HI)
  LO = Dat16 - Dat16MD
End Function

Private Sub DelayT(Time As Single) ' 1-10ms

'   'Delay
    Timer_Val = Time  '1s   Time Val -1 ~ 10ms
    Timer1.Enabled = True
    ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    Do While Timer_Val > 0 ' выполняется покуда True
        DoEvents
    Loop
    Timer1.Enabled = False
End Sub


Private Sub Timer1_Timer()
   Timer_Val = Timer_Val - 1
End Sub
