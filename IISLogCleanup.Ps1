#Author : Madhu Sunke
#Date : 05/03/2022

#specify number of days
$days = 30
$div = "="*50
$date = Get-Date -Format "ddMMyyyyHHmmss"
$ScriptDir = Split-Path $($MyInvocation.MyCommand.Path) -Parent
$scriptName = (Get-Item $MyInvocation.MyCommand.Path).BaseName
$logFolder = "$ScriptDir\Logs"
if(-not(Test-Path "$logFolder")){New-Item -Path "$logFolder" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null }
$logFile = "$logFolder\$scriptName$date.log"
#specify computerName
$serverName = $env:COMPUTERNAME

function Get-Diskinfo{
$driveInfo = Get-WmiObject -Query "select * from win32_logicaldisk where DriveType=3" |Select-Object DeviceID,`
@{Name='TotalSpace(inGB)'; Expression={[math]::Round(($_.Size)/1GB)}},`
@{Name='FreeSpace(inGB)'; Expression={[math]::Round(($_.FreeSpace)/1GB)}},`
@{Name='FreeSpace%'; Expression={[math]::Round(($_.FreeSpace/$_.Size)*100)}}
return $driveInfo
}

function Write-Log ($message) {
    $logtext = "{0:MM-dd-yyyy HH:mm:ss}`t {1}" -f $(get-date),$message
    Add-Content -Path $logFile -Value $logtext
}

function Invoke-LogsCleanup([int]$days){
    Write-Log "Cleaning Up Logs Folder to remove Log Files which are older than $days days"
    $Delrequired = Get-ChildItem -Path $logFolder -Recurse -Filter "*.log" -ErrorAction SilentlyContinue |where {$_.LastWriteTime -lt (Get-Date).AddDays(-$days)} 
    if(!$Delrequired){Write-Log -message "No Log files are exists older than $days days to delete."}else{
        $Delrequired | ForEach-Object {try{Remove-Item -Path $_.FullName -Force -ErrorAction Stop}catch{}}
        Write-Log -message "Logs Cleanup task completed"
        }
}

Write-Log -message "$div"
Write-Log -message "Computer Name: $serverName"
Write-Log -message "Script Name: $scriptName"
Write-Log -message "LogFile Name: $logFile"
Write-Log -message "Drive Space info before cleanup"
Get-Diskinfo | ForEach-Object {Write-Log -message "DeviceID: $($_.DeviceID) | TotalSpace(inGB): $($_.'TotalSpace(inGB)') | FreeSpace(inGB): $($_.'FreeSpace(inGB)') | FreeSpace%: $($_.'FreeSpace%')"}
Invoke-LogsCleanup -days 30
Write-Log -message "Starting IISLogs Cleanup task"
#loop each website
try{
foreach($WebSite in $(get-website)){
#Find the logfile location from website info
$IISlogFile="$($Website.logFile.directory)\w3svc$($website.id)".replace("%SystemDrive%",$env:SystemDrive)
Write-Log -message "Website Name: $($WebSite.name) and it's IIS Log Path: $IISlogFile"
#identify log files from IIS Log Path older than $days
$IISLogstoDelete = Get-ChildItem -Path $IISlogFile -Recurse -Filter "*.log" -ErrorAction Stop | `
Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-$days)} 
if($IISLogstoDelete){
    Write-Log -message "Total no.of log files to be removed $($IISLogstoDelete.Count) older than $days days"
    $IISLogstoDelete | ForEach-Object {try{Remove-Item -Path $_.FullName -Force -ErrorAction Stop}catch{}}
    }else{
    Write-Log -message "Up-to-date. No deletion required under $IISlogFile"
    }
}}catch{Write-Log -message "IIS related config not found"}
Write-Log -message "End IISLogs Cleanup task"
Write-Log -message "Drive Space info after cleanup"
Get-Diskinfo | ForEach-Object {Write-Log -message "DeviceID: $($_.DeviceID) | TotalSpace(inGB): $($_.'TotalSpace(inGB)') | FreeSpace(inGB): $($_.'FreeSpace(inGB)') | FreeSpace%: $($_.'FreeSpace%')"}
Write-Log -message "$div"
#end
