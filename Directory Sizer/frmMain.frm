VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form frmMain 
   Caption         =   "Directory Sizing"
   ClientHeight    =   5670
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   5250
   LinkTopic       =   "Form1"
   ScaleHeight     =   5670
   ScaleWidth      =   5250
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton cmdClose 
      Caption         =   "&Close"
      Height          =   375
      Left            =   4200
      TabIndex        =   3
      Top             =   5160
      Width           =   975
   End
   Begin VB.CommandButton cmdProcess 
      Caption         =   "&Process"
      Height          =   375
      Left            =   3120
      TabIndex        =   2
      Top             =   5160
      Width           =   975
   End
   Begin VB.DriveListBox drvChoose 
      Height          =   315
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   5055
   End
   Begin MSComctlLib.TreeView trvDriveView 
      Height          =   4335
      Left            =   120
      TabIndex        =   1
      Top             =   600
      Width           =   5055
      _ExtentX        =   8916
      _ExtentY        =   7646
      _Version        =   393217
      Indentation     =   295
      LineStyle       =   1
      Style           =   7
      Appearance      =   1
   End
   Begin VB.Label lblStatus 
      Caption         =   "Idle."
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   5280
      Width           =   2055
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Dim iarray(2000, 2) As Variant

Private Sub cmdClose_Click()

    Unload Me

End Sub

Private Sub cmdProcess_Click()

    lblStatus.Caption = "Processing folders...."
    lblStatus.Refresh
    If Len(frmMain.drvChoose.Drive) > 2 Then
    
        MsgBox "This is not a local drive and consequently could slow down your network while I analyise it!", vbCritical, "Warning!!!"
        
    End If
    
    'Clear Tree from previous entries
    frmMain.trvDriveView.Nodes.Clear
    
    'Create Parent for new view
    trvDriveView.Nodes.Add , , "main", "Contents of drive " & frmMain.drvChoose.Drive & "\"
    
    'Get root folder list...
    trvDriveView.Nodes(1).Expanded = True
    trvDriveView.Refresh
    ShowFolderList Left(frmMain.drvChoose.Drive, 2) & "\", ""
        
    lblStatus.Caption = "Idle."
    lblStatus.Refresh
End Sub

Sub ShowFolderList(ByVal mvDrive As String, ByVal mvPath As String)

    'On Error GoTo mvHell

    If Right(mvPath, 10) <> "|NONE|HERE" Then
    
        Dim fs, f, f1, fc, s
        Dim mvFound As Boolean
        Dim mvArrayCount As Integer
        
        'Clear and initialise array...
        For mvArrayCount = 1 To 2000
            iarray(mvArrayCount, 1) = ""
            iarray(mvArrayCount, 2) = ""
        Next mvArrayCount
        
        mvArrayCount = 1
        
        mvFound = False
        Set fs = CreateObject("Scripting.FileSystemObject")
        If mvPath = "main" Then
            mvPath = ""
        End If
        Set f = fs.GetFolder(mvDrive & mvPath)
        Set fc = f.SubFolders
        
        For Each f1 In fc
        
            iarray(mvArrayCount, 1) = f1.Size
            iarray(mvArrayCount, 2) = f1.Name
            
            mvArrayCount = mvArrayCount + 1
                    
        Next
                
        'Perform bubble sort...
        
        lblStatus.Caption = "Sorting folders...."
        lblStatus.Refresh
        Call BubbleSort
            
        'No folders found in current path, add a no folders message!
        mvFound = False
        For mvArrayCount = 1 To 2000
        
            If iarray(mvArrayCount, 1) <> "" Then
                mvFound = True
                If mvPath = "" Then
                    trvDriveView.Nodes.Add "main", tvwChild, iarray(mvArrayCount, 2), iarray(mvArrayCount, 2) & " (" & Format((iarray(mvArrayCount, 1) / 1024) / 1024, "#0.00") & " MB)"
                Else
                    trvDriveView.Nodes.Add mvPath, tvwChild, mvPath & "\" & iarray(mvArrayCount, 2), iarray(mvArrayCount, 2) & " (" & Format((iarray(mvArrayCount, 1) / 1024) / 1024, "#0.00") & " MB)"
                End If
                trvDriveView.Refresh
            Else
                Exit For
            End If
        Next mvArrayCount
        
        If mvFound = False Then
        
            If mvPath = "" Then
                trvDriveView.Nodes.Add "main", tvwChild, "|NONE|HERE", "No folders under this path!"
            Else
                trvDriveView.Nodes.Add mvPath, tvwChild, mvPath & "\|NONE|HERE", "No folders under this path!"
            End If
            
        End If
    End If
    
mvHell:
End Sub

Private Sub trvDriveView_NodeClick(ByVal Node As MSComctlLib.Node)

    'Simple to check to see if directory has already been processed...
    If Node.Children = 0 Then
        lblStatus.Caption = "Processing...."
        lblStatus.Refresh
        
        ShowFolderList Left(frmMain.drvChoose.Drive, 2) & "\", Node.Key
        
        lblStatus.Caption = "Idle."
        lblStatus.Refresh
    End If
    
End Sub

Public Sub BubbleSort()
    Dim lLoop1 As Double
    Dim lLoop2 As Double
    Dim lTemp As Double
    Dim sTemp As String
    
    For lLoop1 = UBound(iarray, 1) To LBound(iarray, 1) Step -1
      For lLoop2 = LBound(iarray, 1) + 1 To lLoop1
        If iarray(lLoop2 - 1, 1) > iarray(lLoop2, 1) Then
          lTemp = iarray(lLoop2 - 1, 1)
          sTemp = iarray(lLoop2 - 1, 2)
          iarray(lLoop2 - 1, 1) = iarray(lLoop2, 1)
          iarray(lLoop2 - 1, 2) = iarray(lLoop2, 2)
          iarray(lLoop2, 1) = lTemp
          iarray(lLoop2, 2) = sTemp
        End If
      Next lLoop2
    Next lLoop1
End Sub

