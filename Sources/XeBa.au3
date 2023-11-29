;++++++++++++++++++++++++++++++++++++++++++++++++++
#include "dsFileName.au3"
#include "dsLog.au3"
;++++++++++++++++++++++++++++++++++++++++++++++++++
$ScriptFullName = StringTrimRight(@ScriptFullPath,3)
;++++++++++++++++++++++++++++++++++++++++++++++++++
$IniFile  = $ScriptFullName & "ini"
;++++++++++++++++++++++++++++++++++++++++++++++++++
; Globale Variablen initialisieren
Global $VM_UUID        = ""
Global $Snapshot_UUID  = ""
Global $ServerIP   	   = ""
Global $VMList     	   = ""
Global $root_PW        = ""
Global $OutputDir      = ""
Global $xe         	   = ""
Global $BackupMode     = ""
Global $TargetServerIP = ""
;++++++++++++++++++++++++++++++++++++++++++++++++++
Func ReadIni()
   $root_PW        = IniRead ($IniFile, "Common", "rootPW", "")
   $OutputDir      = IniRead ($IniFile, "Common", "OutputDir", "")
   $xe             = IniRead ($IniFile, "Common", "xe", "")
   $TargetServerIP = IniRead ($IniFile, "Common", "TargetServer", "")
EndFunc
;++++++++++++++++++++++++++++++++++++++++++++++++++
Func RunCommandAsBatch ($Commandline)
  $MyBatchfile = @ScriptDir & "\RunBatch.cmd"
  If FileExists ($MyBatchfile) Then FileDelete ($MyBatchfile)
  AddLine ($MyBatchfile, $Commandline)
  RunWait ($MyBatchfile, @ScriptDir, @SW_HIDE)
  FileDelete ($MyBatchfile)
EndFunc
;++++++++++++++++++++++++++++++++++++++++++++++++++
; Herausfinden der UUID der zu sichernden VM:
; xe -s 172.25.10.128 -u root -pw <XenPW> vm-list name-label="centos7fctest" --minimal
; Rückgabewert UUID: 87081fd7-ac28-1197-06ed-41b8bdc84228
Func Get_VM_UUID ($root_PW, $Server_IP, $VM_Name)
   $VM_UUID = ""
   $InfoFile = @ScriptDir & "\VM_UUID.txt"
   If FileExists ($InfoFile) Then FileDelete ($InfoFile)

   AddLog ("Getting UUID for VM " & $VM_Name)

   $CommandLine = Chr(34) & $xe & Chr(34) & " -s " & $Server_IP & " -u root -pw " & $root_PW & " vm-list name-label=" & Chr(34) & $VM_Name & Chr(34) & " --minimal > " & Chr(34) & $InfoFile & Chr(34)
   AddLog ("Running xe with following commandline: " & StringReplace($CommandLine, $root_PW, "<Root-Passwort>" ))
   RunCommandAsBatch ($Commandline)

   $file = FileOpen ($InfoFile, 0)

   If $file = -1 Then
     MsgBox(0, "Error", "Unable to open file " & $InfoFile & ".")
     Exit
   EndIf

  $VM_UUID = FileReadLine($file)

  FileClose($file)

  AddLog ("Output of XE command:")
  XEOutput2Log ($InfoFile)

  If FileExists ($InfoFile) Then FileDelete ($InfoFile)

  AddLog ("UUID for VM " & $VM_Name & " is " & $VM_UUID)

  Return ($VM_UUID)
EndFunc
;++++++++++++++++++++++++++++++++++++++++++++++++++
; Starten einer VM basierend auf deren UUID :
; xe -s 172.25.10.128 -u root -pw <XenPW> vm-start uuid="514b514a-bd0d-e557-4413-1f5df3daaa52"
Func Start_VM_UUID ($root_PW, $Server_IP,  $VM_UUID, $VM_Name)
   $InfoFile = @ScriptDir & "\VM_UUID.txt"
   If FileExists ($InfoFile) Then FileDelete ($InfoFile)

   AddLog ("Starting VM " & $VM_Name & " with UUID " & $VM_UUID )

   $CommandLine = Chr(34) & $xe & Chr(34) & " -s " & $Server_IP & " -u root -pw " & $root_PW & " vm-start uuid=" & Chr(34) & $VM_UUID & Chr(34) & " > " & Chr(34) & $InfoFile & Chr(34)
   AddLog ("Running xe with following commandline: " & StringReplace($CommandLine, $root_PW, "<Root-Passwort>" ))
   RunCommandAsBatch ($Commandline)

   $file = FileOpen ($InfoFile, 0)

   If $file = -1 Then
     MsgBox(0, "Error", "Unable to open file " & $InfoFile & ".")
     Exit
   EndIf

  $VM_UUID = FileReadLine($file)

  FileClose($file)

  AddLog ("Output of XE command:")
  XEOutput2Log ($InfoFile)

  If FileExists ($InfoFile) Then FileDelete ($InfoFile)
EndFunc
;++++++++++++++++++++++++++++++++++++++++++++++++++
; Shutdown einer VM basierend auf deren UUID :
; xe -s 172.25.10.128 -u root -pw <XenPW> vm-shutdown uuid="514b514a-bd0d-e557-4413-1f5df3daaa52"
Func Shutdown_VM_UUID ($root_PW, $Server_IP,  $VM_UUID, $VM_Name)
   $InfoFile = @ScriptDir & "\VM_UUID.txt"
   If FileExists ($InfoFile) Then FileDelete ($InfoFile)

   AddLog ("Shutting down VM " & $VM_Name & " with UUID " & $VM_UUID )

   $CommandLine = Chr(34) & $xe & Chr(34) & " -s " & $Server_IP & " -u root -pw " & $root_PW & " vm-shutdown uuid=" & Chr(34) & $VM_UUID & Chr(34) & " > " & Chr(34) & $InfoFile & Chr(34)
   AddLog ("Running xe with following commandline: " & StringReplace($CommandLine, $root_PW, "<Root-Passwort>" ))
   RunCommandAsBatch ($Commandline)

   $file = FileOpen ($InfoFile, 0)

   If $file = -1 Then
     MsgBox(0, "Error", "Unable to open file " & $InfoFile & ".")
     Exit
   EndIf

  $VM_UUID = FileReadLine($file)

  FileClose($file)

  AddLog ("Output of XE command:")
  XEOutput2Log ($InfoFile)

  If FileExists ($InfoFile) Then FileDelete ($InfoFile)
EndFunc
;++++++++++++++++++++++++++++++++++++++++++++++++++
; Erstellen eines Snapshots der zu sichernden VM:
; xe -s 172.25.10.128 -u root -pw <XenPW> vm-snapshot new-name-label=backup uuid="87081fd7-ac28-1197-06ed-41b8bdc84228"
; Rückgabewert UUID: a572f08a-77de-5441-54fe-bd8551fda5f7
Func Make_VM_Snapshot ($root_PW, $Server_IP, $VM_UUID,  $VM_Name)
   $Snapshot_UUID = ""
   $InfoFile = @ScriptDir & "\Snapshot_UUID.txt"
   If FileExists ($InfoFile) Then FileDelete ($InfoFile)

   AddLog ("Taking Snapshot for VM " & $VM_Name & " with UUID " & $VM_UUID)

   $CommandLine = Chr(34) & $xe & Chr(34) & " -s " & $Server_IP & " -u root -pw " & $root_PW & " vm-snapshot new-name-label=backup-" &  $VM_Name & " uuid=" & Chr(34) & $VM_UUID & Chr(34) & " > " & Chr(34) & $InfoFile & Chr(34)

   AddLog ("Running xe with following commandline: " & StringReplace($CommandLine, $root_PW, "<Root-Passwort>" ))
   RunCommandAsBatch ($Commandline)
   AddLog ("Output of XE command:")
   XEOutput2Log ($InfoFile)

   $file = FileOpen ($InfoFile, 0)

   If $file = -1 Then
     MsgBox(0, "Error", "Unable to open file " & $InfoFile & ".")
     Exit
   EndIf

  $Snapshot_UUID = FileReadLine($file)

  FileClose($file)

  If FileExists ($InfoFile) Then FileDelete ($InfoFile)

  AddLog ("UUID for Snapshot for VM " & $VM_Name & " is " & $Snapshot_UUID)



  Return ($Snapshot_UUID)
EndFunc
;++++++++++++++++++++++++++++++++++++++++++++++++++
; Patchen eines Snapshots als vollwertige VM und nicht als Template:
; xe template-param-set is-a-template=false ha-always-run=false uuid=${SNAPUUID}
; Rückgabewert UUID: a572f08a-77de-5441-54fe-bd8551fda5f7
Func Patch_VM_Snapshot ($root_PW, $Server_IP, $Snapshot_UUID, $VM_Name)
   $InfoFile = @ScriptDir & "\xe_result.txt"
   If FileExists ($InfoFile) Then FileDelete ($InfoFile)

   AddLog ("Patching Snapshot for VM " & $VM_Name & " with UUID " & $Snapshot_UUID)

   $CommandLine = Chr(34) & $xe & Chr(34) & " -s " & $Server_IP & " -u root -pw " & $root_PW & " template-param-set is-a-template=false ha-always-run=false name-label=" & Chr(34) & $VM_Name & Chr(34) & " uuid=" & Chr(34) & $Snapshot_UUID & Chr(34) & " > " & Chr(34) & $InfoFile & Chr(34)

   AddLog ("Running xe with following commandline: " & StringReplace($CommandLine, $root_PW, "<Root-Passwort>" ))
   RunCommandAsBatch ($Commandline)
   AddLog ("Output of XE command:")
   XEOutput2Log ($InfoFile)

   $file = FileOpen ($InfoFile, 0)

   If $file = -1 Then
     MsgBox(0, "Error", "Unable to open file " & $InfoFile & ".")
     Exit
   EndIf

  FileClose($file)

  If FileExists ($InfoFile) Then FileDelete ($InfoFile)

EndFunc
;++++++++++++++++++++++++++++++++++++++++++++++++++
; Export einer VM in eine XVE Datei:
; xe -s 172.25.10.128 -u root -pw <XenPW> vm-export filename="D:\centos7cftest_backup.xva" name-label="SomeVM"
; Export succeeded
Func Export_VM ($root_PW, $Server_IP, $VM_Name, $ExportFile)
  Local $MyTimer = 0
  $InfoFile = @ScriptDir & "\xe_result.txt"
  If FileExists ($InfoFile) Then FileDelete ($InfoFile)

  If FileExists ($Exportfile) Then
   Do
	 $ExportFile = _FileIncrementFileName ($ExportFile)
   Until not FileExists ( $ExportFile)
  EndIf

  AddLog ("Exporting VM " & $VM_Name & " with UUID " & $VM_UUID )

  $CommandLine = Chr(34) & $xe & Chr(34) & " -s " & $Server_IP & " -u root -pw " & $root_PW & " vm-export name-label=" & Chr(34) & $VM_Name & Chr(34) & " filename="  & Chr(34) &$ExportFile & Chr(34) & " > " & Chr(34) & $InfoFile & Chr(34)

  AddLog ("Running xe with following commandline: " & StringReplace($CommandLine, $root_PW, "<Root-Passwort>" ))

  $MyTimer = TimerInit()
  RunCommandAsBatch ($Commandline)
  Local $TimeDiff = TimerDiff ($MyTimer) / 1000
  AddLog ("Output of XE command:")
  XEOutput2Log ($InfoFile)

  Local $ExportFilesize = FileSizeMB ($ExportFile)

  AddLog ("Exporting for VM " & $VM_Name & " with UUID " & $VM_UUID & " finished !")
  AddLog ("Filesize of Exportfile " & $ExportFile & " is " &  $ExportFilesize  & " MB")
  AddLog ("Duration for Export " & Round ($TimeDiff) & " Seconds")

  $Throughput = $ExportFilesize / $TimeDiff

  AddLog ("Export performance " & Round ($Throughput, 2) & " MB / Seconds")

  If FileExists ($InfoFile) Then FileDelete ($InfoFile)
EndFunc
;++++++++++++++++++++++++++++++++++++++++++++++++++
; Export des Snapshots in eine XVE Datei:
; xe -s 172.25.10.128 -u root -pw <XenPW> snapshot-export-to-template-export snapshot-uuid="a572f08a-77de-5441-54fe-bd8551fda5f7" filename="D:\centos7cftest_backup.xve"
; Export succeeded
Func Export_VM_Snapshot ($root_PW, $Server_IP, $Snapshot_UUID, $VM_Name, $ExportFile)
  Local $MyTimer = 0
  $InfoFile = @ScriptDir & "\xe_result.txt"
  If FileExists ($InfoFile) Then FileDelete ($InfoFile)

  If FileExists ($Exportfile) Then
   Do
	 $ExportFile = _FileIncrementFileName ($ExportFile)
   Until not FileExists ( $ExportFile)
  EndIf

  AddLog ("Exporting Snapshot for VM " & $VM_Name & " with UUID " & $VM_UUID )

  $CommandLine = Chr(34) & $xe & Chr(34) & " -s " & $Server_IP & " -u root -pw " & $root_PW & " snapshot-export-to-template snapshot-uuid=" & Chr(34) & $Snapshot_UUID & Chr(34) & " filename="  & Chr(34) &$ExportFile & Chr(34) & " > " & Chr(34) & $InfoFile & Chr(34)

  AddLog ("Running xe with following commandline: " & StringReplace($CommandLine, $root_PW, "<Root-Passwort>" ))

  $MyTimer = TimerInit()
  RunCommandAsBatch ($Commandline)
  Local $TimeDiff = TimerDiff ($MyTimer) / 1000
  AddLog ("Output of XE command:")
  XEOutput2Log ($InfoFile)

  Local $ExportFilesize = FileSizeMB ($ExportFile)

  AddLog ("Exporting Snapshot for VM " & $VM_Name & " with UUID " & $VM_UUID & " finished !")
  AddLog ("Filesize of Exportfile " & $ExportFile & " is " &  $ExportFilesize  & " MB")
  AddLog ("Duration for Export " & Round ($TimeDiff) & " Seconds")

  $Throughput = $ExportFilesize / $TimeDiff

  AddLog ("Export performance " & Round ($Throughput, 2) & " MB / Seconds")

  If FileExists ($InfoFile) Then FileDelete ($InfoFile)
EndFunc
;++++++++++++++++++++++++++++++++++++++++++++++++++
; Löschen des Snapshots:
; xe -s 172.25.10.128 -u root -pw <XenPW> template-uninstall template-uuid="a572f08a-77de-5441-54fe-bd8551fda5f7" --force
;The following items are about to be destroyed
; VM : a572f08a-77de-5441-54fe-bd8551fda5f7 (backup)
;VDI: 7248a1dc-2c17-421a-a816-412a1d072aac (centos7fctest.system)
; All objects destroyed
Func Del_VM_Snapshot ($root_PW, $Server_IP, $Snapshot_UUID)
  $InfoFile = @ScriptDir & "\xe_result.txt"

  AddLog ("Deleting Snapshot for VM " & $VM_Name & " with Snapshot UUID " & $Snapshot_UUID )

  $CommandLine = Chr(34) & $xe & Chr(34) & " -s " & $Server_IP & " -u root -pw " & $root_PW & " template-uninstall template-uuid=" & Chr(34) & $Snapshot_UUID & Chr(34) & " --force > " & Chr(34) & $InfoFile & Chr(34)

  AddLog ("Running xe with following commandline: " & StringReplace($CommandLine, $root_PW, "<Root-Passwort>" ))

  RunCommandAsBatch ($Commandline)

  AddLog ("Output of XE command:")
  XEOutput2Log ($InfoFile)

  AddLog ("Deleting Snapshot for VM " & $VM_Name & " with Snapshot UUID " & $VM_UUID & " finished !")

  If FileExists ($InfoFile) Then FileDelete ($InfoFile)
  EndFunc
  ;++++++++++++++++++++++++++++++++++++++++++++++++++
; Import einer VM als XVE Datei auf einem Xen-Server:
; xe -s 172.25.10.128 -u root -pw <XenPW> vm-import filename="D:\centos7cftest_backup.xva"
Func Import_VM ($root_PW, $TargetServerIP, $ImportFile)
  Local $MyTimer = 0
  $InfoFile = @ScriptDir & "\xe_result.txt"
  If FileExists ($InfoFile) Then FileDelete ($InfoFile)

  AddLog ("Importing VM Image from " & $ImportFile & " to XenServer " & $TargetServerIP )

  $CommandLine = Chr(34) & $xe & Chr(34) & " -s " & $TargetServerIP & " -u root -pw " & $root_PW & " vm-import name-label=" & Chr(34) & $VM_Name & Chr(34) & " filename="  & Chr(34) &$ImportFile & Chr(34) & " > " & Chr(34) & $InfoFile & Chr(34)

  AddLog ("Running xe with following commandline: " & StringReplace($CommandLine, $root_PW, "<Root-Passwort>" ))

  $MyTimer = TimerInit()
  RunCommandAsBatch ($Commandline)
  Local $TimeDiff = TimerDiff ($MyTimer) / 1000
  AddLog ("Output of XE command:")
  XEOutput2Log ($InfoFile)

  Local $ImportFilesize = FileSizeMB ($ImportFile)

  AddLog ("Importing for VM " & $VM_Name & " with UUID " & $VM_UUID & " finished !")
  AddLog ("Filesize of Importfile " & $ImportFile & " is " &  $ImportFilesize  & " MB")
  AddLog ("Duration for Import " & Round ($TimeDiff) & " Seconds")

  $Throughput = $ImportFilesize / $TimeDiff

  AddLog ("Import performance " & Round ($Throughput, 2) & " MB / Seconds")

  If FileExists ($InfoFile) Then FileDelete ($InfoFile)
EndFunc
;++++++++++++++++++++++++++++++++++++++++++++++++++
; Returns filesize of given file in MB
Func FileSizeMB ($FileName)
  $FSize = FileGetSize($FileName) / 1044576
  Return (Round($FSize,2))
EndFunc
;++++++++++++++++++++++++++++++++++++++++++++++++++
; Initialize log filename
$LogFile  = $ScriptFullName & "log"

LogLine ("=")
AddLog ("XeBa - The Xen Backup Tool -  Beginning new VM export")
LogLine ("=")

$ParamCount = $CmdLine[0]

; Get Filelist from Commandline if available
If ($ParamCount > 0) Then
	AddLog ("Called via CLI with the following commandline: " & $CmdLineRaw )
	$ServerIP   = $CmdLine[1]
	$VMList     = $CmdLine[2]
	$BackupMode = $CmdLine[3]
Else
  MsgBox (64, "Use the Commandline",  "The Xen-Server VM Backup-Tool" & @CRLF  & @CRLF & "Syntax:" & @CRLF & "XeBa.exe <IP-Adress XenServer> <Serverlist.txt> <Backupmode>" &  @CRLF & @CRLF & "Backupmode = SNAPSHOT will create a snapshot and export it" & @CRLF & "Backupmode = SHUTDOWN will shutdown the VM prior export" & @CRLF & "Backupmode = NOPOWERON will shutdown the VM prior export and                                  not restart it"  & @CRLF & "Backupmode = MIGRATE will shutdown the VM prior export and import                             on target server")
  Exit
EndIf

ReadIni()

AddLog ("OutputDir from Ini file is " & $OutputDir)
AddLog ("XE from Ini file is " & $xe)
AddLog ("XenServer IP from CLI is " & $ServerIP)
AddLog ("Xen VM List from CLI is " & $VMList)
AddLog ("Backup Mode from CLI is " & $BackupMode)


If ProcessExists("xe.exe") Then
   AddLog ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
   AddLog ("!!! Found another running instance of XE !!!")
   AddLog ("!!!            Exiting now               !!!")
   AddLog ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
   Exit
EndIf

$VM_file = FileOpen ($VMList, 0)

While 1
  $line = FileReadLine($VM_file)

  If @error = -1 Then ExitLoop

  $VM_Name = StringStripWS($line, 3)

  if StringCompare(StringLeft($VM_Name, 1), "#") > 0 Then
    LogLine ("=")
    AddLog ("Processing VM " &$VM_Name)

    $VM_UUID = Get_VM_UUID ($root_PW, $ServerIP, $VM_Name)

	If StringCompare ($BackupMode, "SNAPSHOT") = 0 Then
      $Snapshot_UUID = Make_VM_Snapshot ($root_PW, $ServerIP, $VM_UUID, $VM_Name)
      $ExportFile = $OutputDir & "\" & $VM_Name & "_" & @YEAR&@MON&@MDAY & ".xva"
	  ; Snapshot als vollwertigen VM Export kennzeichnen
	  Patch_VM_Snapshot ($root_PW, $ServerIP, $Snapshot_UUID, $VM_Name)
      Export_VM_Snapshot ($root_PW, $ServerIP, $Snapshot_UUID, $VM_Name, $ExportFile)
      Del_VM_Snapshot ($root_PW, $ServerIP, $Snapshot_UUID)
    EndIf

	If StringCompare ($BackupMode, "SHUTDOWN") = 0 or StringCompare ($BackupMode, "NOPOWERON") = 0 or StringCompare ($BackupMode, "MIGRATE") = 0 or StringCompare ($BackupMode, "EXPORTONLY") = 0 Then
      $ExportFile = $OutputDir & "\" & $VM_Name & "_" & @YEAR&@MON&@MDAY & ".xva"

	  # Fahre VM nur runter, wenn nicht EXPORTONLY gewählt ist
	  If StringCompare ($BackupMode, "EXPORTONLY") = 1 Then Shutdown_VM_UUID ($root_PW, $ServerIP,  $VM_UUID, $VM_Name)
      Export_VM ($root_PW, $ServerIP, $VM_Name, $ExportFile)

	  # Starte VM wieder wenn nur Backup mit Shutdown gewählt war
      If StringCompare ($BackupMode, "SHUTDOWN") = 0 Then Start_VM_UUID ($root_PW, $ServerIP,  $VM_UUID, $VM_Name)

	  # Starte Import der exportierten VM auf neuen Server, falls MIGRATE gewählt war
	  If StringCompare ($BackupMode, "MIGRATE")  = 0 Then Import_VM ($root_PW, $TargetServerIP, $ExportFile)
	EndIf

	LogLine ("=")
  EndIf
WEnd

FileClose($VM_file)

Exit


