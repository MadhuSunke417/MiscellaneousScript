<#
Author : Madhu Sunke
Date Created : 12/2/2021
Retrieve Battery related info and it's Health
#>

param(
[string]$compName = $env:COMPUTERNAME
)

$DesignedCapacity = (Get-WmiObject -Class "BatteryStaticData" -Namespace "ROOT\WMI" -ComputerName $compName)
$outArr = @()
foreach($entry in $DesignedCapacity){
        [hashtable]$objectProperty = @{}
        $FullChargedCapacity = Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI" -ComputerName $compName | where {$_.InstanceName -EQ $entry.InstanceName} | select -ExpandProperty FullChargedCapacity
        $objectProperty.Add('DeviceName',$entry.DeviceName)
        $objectProperty.Add('SerialNumber',$(($entry.SerialNumber).TrimStart()))
        $objectProperty.Add('UniqueID',$(($entry.UniqueID).TrimStart()))
        $objectProperty.Add('DesignedCapacity',$entry.DesignedCapacity)
        $objectProperty.Add('FullChargedCapacity',$FullChargedCapacity)
        $objectProperty.Add('BatteryHealth',$([math]::Round(100*$FullChargedCapacity/$entry.DesignedCapacity)))
        $ourObject = New-Object -TypeName psobject -Property $objectProperty
        $outArr+=$ourObject
  }

$outArr