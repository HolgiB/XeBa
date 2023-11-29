;----------------------------------------------------------------------------------
; File name / path processing functions by Dark$oul71
; AutoIt sources, http://www.hiddensoft.com/AutoIt/
#include "File.au3"
;----------------------------------------------------------------------------------
Func _FileGetDrive ($FullPath)
  ; Define local variables
  Local $tmpDrive = ""
  Local $tmpDir   = ""
  Local $tmpName  = ""
  Local $tmpExt   = ""
  Local $tmpDrive = ""

  _PathSplit($FullPath, $tmpDrive, $tmpDir, $tmpName, $tmpExt)

  Return ($tmpDrive)

EndFunc
;----------------------------------------------------------------------------------
Func _FileGetPath ($FullPath)
  ; Define local variables
  Local $tmpDrive = ""
  Local $tmpDir   = ""
  Local $tmpName  = ""
  Local $tmpExt   = ""
  Local $tmpDrive = ""

  _PathSplit($FullPath, $tmpDrive, $tmpDir, $tmpName, $tmpExt)

  Return ($tmpDrive & $tmpDir)

EndFunc
;----------------------------------------------------------------------------------
Func _FileGetFilename ($FullPath)
  ; Define local variables
  Local $tmpDrive = ""
  Local $tmpDir   = ""
  Local $tmpName  = ""
  Local $tmpExt   = ""
  Local $tmpDrive = ""

  _PathSplit($FullPath, $tmpDrive, $tmpDir, $tmpName, $tmpExt)

  Return ($tmpName & $tmpExt)
EndFunc
;----------------------------------------------------------------------------------
Func _FileGetExt ($FullPath)
  ; Define local variables
  Local $tmpDrive = ""
  Local $tmpDir   = ""
  Local $tmpName  = ""
  Local $tmpExt   = ""
  Local $tmpDrive = ""

  _PathSplit($FullPath, $tmpDrive, $tmpDir, $tmpName, $tmpExt)

  Return ($tmpExt)
EndFunc
;----------------------------------------------------------------------------------
Func _FileChangeExt ($FullPath, $Extension)

  If (StringLeft ($Extension, 1) <> ".") Then $Extension = "." & $Extension

  ; Define local variables
  Local $tmpDrive = ""
  Local $tmpDir   = ""
  Local $tmpName  = ""
  Local $tmpExt   = ""
  Local $tmpDrive = ""

  _PathSplit($FullPath, $tmpDrive, $tmpDir, $tmpName, $tmpExt)

  Return (StringReplace ($FullPath, $tmpExt,$Extension))
EndFunc
;----------------------------------------------------------------------------------
Func _FileStripExt ($FullPath)
 ; Define local variables
  Local $tmpDrive = ""
  Local $tmpDir   = ""
  Local $tmpName  = ""
  Local $tmpExt   = ""
  Local $tmpDrive = ""

  _PathSplit($FullPath, $tmpDrive, $tmpDir, $tmpName, $tmpExt)

  Return ($tmpDrive & $tmpDir & $tmpName)
EndFunc
;----------------------------------------------------------------------------------
Func _FileAppendTextfile ($ToAppend, $FromAppend)

  $ToFile = FileOpen($ToAppend, 1)

  ; Check if file opened for appending OK
  If $ToFile = -1 Then
    MsgBox(0, "Error", "Unable to open file " & $ToAppend)
    Exit
  EndIf

  $FromFile = FileOpen($FromAppend, 0)

  ; Check if file opened for reading OK
  If $FromFile = -1 Then
    MsgBox(0, "Error", "Unable to open file " & $FromAppend)
    Exit
  EndIf

  While 1
    $line = FileReadLine($FromFile)
    If @error = -1 Then ExitLoop
    FileWriteLine($ToFile, $Line)
  Wend

  FileClose($FromFile)
  FileClose($ToFile)
EndFunc
;----------------------------------------------------------------------------------
Func _FileSearchAndReplaceText ($SearchFile, $SearchString, $ReplaceString, $CaseSensitive)

  $LineCount = _FileCountLines( $SearchFile )

  If ($LineCount = 0) Then
    Exit
  Else
    Dim $myArray[$LineCount]
  EndIf

  If (_FileReadToArray( $SearchFile, $myArray ) = 0) Then Exit

  For $i = 0 To $LineCount - 1
    $myArray[$i] = StringReplace ($myArray[$i], $SearchString, $ReplaceString, -1, $CaseSensitive)
  Next

  _FileWriteFromArray($SearchFile, $myArray)
EndFunc
;----------------------------------------------------------------------------------
Func _FileSearchForText ($SearchFile, $SearchString, $CaseSensitive)

  $StringFound = 0

  $File = FileOpen($SearchFile, 0)

  ; Check if file opened for appending OK
  If $File = -1 Then
    MsgBox(0, "Error", "Unable to open file " & $SearchFile)
    Exit
  EndIf

  While (1) And ($StringFound = 0)
    $line = FileReadLine($File)
    If @error = -1 Then ExitLoop
    If (StringInStr ( $line, $SearchString, $CaseSensitive) <> 0) Then $StringFound = 1
  Wend

  FileClose ($File)

  Return ($StringFound)
EndFunc
;----------------------------------------------------------------------------------
Func _FileIncrementFileName ($FullPath)

  If FileExists($FullPath) Then

    ; Define local variables
    Local $tmpDrive = ""
    Local $tmpDir   = ""
    Local $tmpName  = ""
    Local $tmpExt   = ""
    Local $tmpDrive = ""

    _PathSplit($FullPath, $tmpDrive, $tmpDir, $tmpName, $tmpExt)

    $Count = 1

    $ReturnName =  $tmpDrive & $tmpDir & $tmpName & " (" & $Count & ")" & $tmpExt

    While FileExists ($ReturnName)
      $Count = $Count + 1
      $ReturnName =  $tmpDrive & $tmpDir & $tmpName & " (" & $Count & ")" & $tmpExt
    Wend

    Return ($ReturnName)
  Else
    Return ($FullPath)
  EndIf
EndFunc
;----------------------------------------------------------------------------------
Func _GenerateIncrementedFileNames ($FullPath, $Count, byRef $myArray)
  If (UBound($myArray) = 1 And @error = 1) Then Dim $myArray[$Count]

  ; Define local variables
  Local $tmpDrive = ""
  Local $tmpDir   = ""
  Local $tmpName  = ""
  Local $tmpExt   = ""
  Local $tmpDrive = ""

  _PathSplit($FullPath, $tmpDrive, $tmpDir, $tmpName, $tmpExt)

  $myArray [0] = $FullPath

  For $i = 1 To $Count - 1
    $myArray[$i] =  $tmpDrive & $tmpDir & $tmpName & " (" & $i & ")" & $tmpExt
  Next

EndFunc
;----------------------------------------------------------------------------------
Func _DrivePercentFree ($FullPath)
  ; Define local variables
  Local $tmpDrive = ""
  Local $tmpDir   = ""
  Local $tmpName  = ""
  Local $tmpExt   = ""
  Local $tmpDrive = ""

  _PathSplit($FullPath, $tmpDrive, $tmpDir, $tmpName, $tmpExt)

  If (DriveStatus ($tmpDrive) <> "READY") Then Return (-1)

  $SizeTotal = DriveSpaceTotal ($tmpDrive)
  $SizeFree  = DriveSpaceFree  ($tmpDrive)

  Return (Round ($SizeFree / ($SizeTotal*0.01),2))
EndFunc
;----------------------------------------------------------------------------------
Func _IsSearchedType ($FullPath, $Types)

  $SearchedTypes = StringSplit ( $Types, "|,;:" )

  $SearchCount = $SearchedTypes[0]

  For $i = 1 To $SearchCount
    $SearchedTypes[$i] = StringUpper($SearchedTypes[$i])
    If (StringLeft ($SearchedTypes[$i], 1) <> ".") Then $SearchedTypes[$i] = "." & $SearchedTypes[$i]
  Next

  ; Define local variables
  Local $tmpDrive = ""
  Local $tmpDir   = ""
  Local $tmpName  = ""
  Local $tmpExt   = ""
  Local $tmpDrive = ""

  _PathSplit($FullPath, $tmpDrive, $tmpDir, $tmpName, $tmpExt)

  For $i = 1 To $SearchCount
    If ($SearchedTypes[$i] = StringUpper($tmpExt)) Then Return (1)
  Next

  Return (0)
EndFunc
;----------------------------------------------------------------------------------

