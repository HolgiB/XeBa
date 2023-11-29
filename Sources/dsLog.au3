; Functions for extended logging within AutoIt script
; Add text and ini files to logfiles with timestamp and so on.
; AutoIt sources, http://www.hiddensoft.com/AutoIt/
#include "file.au3"
; ----------------------------------------------------------------------------
Global $LogFile = ""
; ----------------------------------------------------------------------------
Func LogLine ($LineChar)
  $Line = ""
  For $i = 0 To 79
   $Line = $Line & $LineChar
  Next
  AddLog ($Line)
EndFunc
; ----------------------------------------------------------------------------
Func AddFile2Log ($Source)
  LogLine ("#")
  AddLog ("Adding file " & $Source & " to logfile")
  $File = FileOpen($Source, 0)

  If ($file = -1) Then
    AddLog ("Error: Unable to open file " & $Source)
    Exit
  EndIf

  ; Read in lines of text until the EOF is reached
  While 1
    $line = FileReadLine($file)
    If @error = -1 Then ExitLoop
    AddLog ($line)
  Wend

  FileClose($file)

  LogLine ("#")
EndFunc
; ----------------------------------------------------------------------------
Func XEOutput2Log ($Source)
  $File = FileOpen($Source, 0)

  If ($file = -1) Then
    AddLog ("Error: Unable to open file " & $Source)
    Exit
  EndIf

  ; Read in lines of text until the EOF is reached
  While 1
    $line = FileReadLine($file)
    If @error = -1 Then ExitLoop
    AddLog ("  " & $line)
  Wend

  FileClose($file)
EndFunc
; ----------------------------------------------------------------------------
Func AddLog ($Message)
  $TimeStamp = @MDAY & "/" & @MON & "/" & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC & " >>"
  AddLine ($LogFile, $TimeStamp & $Message)
EndFunc
; ----------------------------------------------------------------------------
Func AddLine ($TextFile, $Line)
  $file = FileOpen($TextFile, 1)

  ; Check if file opened for reading OK
  If $file = -1 Then
    MsgBox(0, "Error", "Function AddLine: " & @CRLF &  " Unable to open file: " & $TextFile)
    Exit
  EndIf

  FileWriteLine($file, $Line)

  FileClose($file)
EndFunc
; ----------------------------------------------------------------------------