;----------------------------------------------------------------------------------
; File name / path processing functions by Dark$oul71
; AutoIt sources, http://www.hiddensoft.com/AutoIt/
#include "File.au3"
;----------------------------------------------------------------------------------
Func _FileIncrementFileName ($FullPath)

  If FileExists($FullPath) Then

    ; Define local variables
    Local $tmpDrive = ""
    Local $tmpDir   = ""
    Local $tmpName  = ""
    Local $tmpExt   = ""

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
