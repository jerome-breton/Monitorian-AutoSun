Dir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)

Dim WinScriptHost
Set WinScriptHost = CreateObject("WScript.Shell")

WinScriptHost.Run """PowerShell"" -noninteractive -NoLogo -ExecutionPolicy RemoteSigned " & Dir & "\script.ps1 6>&1 2>&1 >" & Dir & "\output.log", 0, true

Set WinScriptHost = Nothing