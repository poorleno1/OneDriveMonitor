﻿

$path="c:\scripts"
if (!(Test-Path $path))
{
    New-item $path -ItemType Directory -Force -ErrorAction SilentlyContinue    
}

Start-BitsTransfer "https://raw.githubusercontent.com/poorleno1/OneDriveMonitor/main/oneDriveMonitor.ps1" -Destination $path



$path="c:\temp\pstools"
if (!(Test-Path $path))
{
    New-item $path -ItemType Directory -Force -ErrorAction SilentlyContinue    
}
Start-BitsTransfer "https://download.sysinternals.com/files/PSTools.zip" -Destination $path
Expand-Archive "$path\PSTools.zip" $path
cp $path\psexec* C:\scripts\
Remove-Item $path -Force -Confirm:$false -Recurse


$accountId = "NT AUTHORITY\SYSTEM"
$principal = New-ScheduledTaskPrincipal -UserID $accountId -LogonType ServiceAccount  -RunLevel Highest;

$taskName="task1"

$task = Get-ScheduledJob -Name $taskName  -ErrorAction SilentlyContinue
if ($task -ne $null)
{
    Unregister-ScheduledJob $task  -Confirm:$false
    Write-Host " @ The old ""$taskName"" PowerShell job has been unregistered"; Write-Host;
}

$task = Register-ScheduledJob -Name task1  `
-Trigger  (New-JobTrigger -Once -At $(get-date) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration ([TimeSpan]::MaxValue)) `
-ScheduledJobOption (New-ScheduledJobOption -RunElevated) `
-ScriptBlock {& "C:\apps\OneDriveMonitor\oneDriveMonitor.ps1"}

$psJobsPathInScheduler = "\Microsoft\Windows\PowerShell\ScheduledJobs";
Set-ScheduledTask -TaskPath $psJobsPathInScheduler -TaskName $taskName  -Principal $principal