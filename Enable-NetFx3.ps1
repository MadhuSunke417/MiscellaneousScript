$object = Get-WindowsOptionalFeature -Online -FeatureName "NetFx3"

if($object.State -ne 'Enabled'){
    try{
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWuServer" -Value 0
    Restart-Service wuauserv
    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -ErrorAction Stop
     }
     catch{
         Write-Host "$($_.exception.message)"
         exit 1
        }
 }else{
     Write-Output "Current State is : $($object.State)" -Verbose
     exit 0
 }

  Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWuServer" -Value 1
  Restart-Service wuauserv
