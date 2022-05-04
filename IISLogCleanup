#Author : Madhu Sunke
#Date : 05/03/2022

#specify computerName
$serverName = $env:COMPUTERNAME 
#specify number of days
$days = 30
#identify IIS Admin service installed or not. Returns True if IIS role installed
$iisPresent = $null -ne (Get-WmiObject Win32_Service -ComputerName $serverName -Filter "name='IISADMIN'" -ErrorAction SilentlyContinue)

if($iisPresent){
    try{
    #find IIS setup related info from registry
    $Inetstp = Get-ItemProperty -Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\InetStp\ -ErrorAction Stop
    #Save WWWRoot info into variable 
    $PathWWWRoot = $Inetstp.PathWWWRoot
    #Genarate IIS logPath variable from WWWRoot
    $iisLogPath = $PathWWWRoot.trimend("\wwwroot") + "\logs\LogFiles"
    #verify SCCM DP installed
if(Test-Path "HKLM:\SOFTWARE\Microsoft\SMS\DP"){$iisLogPath2 = (Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\SMS\DP" -Name UsageLogLocation -ErrorAction SilentlyContinue)}
    #identify log files from IIS Log Path older than $days
    Get-ChildItem -Path $iisLogPath,$iisLogPath2 -Filter "*.log" -Recurse -ErrorAction Stop |Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-$days)} | Remove-Item -Force -WhatIf -ErrorAction Stop
    }catch{
        #Generate/Catch an Error if something goes wrong 
        Write-Host "Error occured $($_.exception.message)"
        }

}else{
    #this part executes only if there no IIS Admin Service exists
    Write-Host "IIS Admin Service not exists"
}
