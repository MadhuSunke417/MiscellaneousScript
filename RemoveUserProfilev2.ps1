<#
Author : Madhu Sunke
Date   : 11/30/2021
This script will remove user profiles older than x days 
#>
 param(
    [int]$olderThan= "5" #change Value here based on your requirement
   )

cls
$excludedSids= @(".DEFAULT", "S-1-5-18", "S-1-5-19", "S-1-5-20")
$excludedUsernames = @('Administrator')
$excludedLocalUsers = Get-LocalUser | Select -ExpandProperty Name
$removeUsers  = @()

"="*45
"$(Get-Date) : Profile Cleanup"
"="*45

$userProfinfo =  Get-CimInstance -Class Win32_UserProfile | `
                 where {$_.SID -notin $excludedSids -and $($_.LocalPath.split("\")[-1]) -notin $($excludedUsernames+$excludedLocalUsers)} 
foreach($userProfile in $userProfinfo){
        Write-Output "->Processing user : $($userProfile.LocalPath.split("\")[-1])"
        "->Is that Profile $($userProfile.LocalPath.split("\")[-1]) loaded : $($userProfile.Loaded)"
        "->LastTime use : $($userProfile.LastUseTime)"
        $ProfilePathModified = Get-Item $userProfile.LocalPath -ErrorAction SilentlyContinue
    if(-not($userProfile.Loaded) -and (($userProfile.LastUseTime -lt (Get-Date).AddDays(-$olderThan)) -or ($ProfilePathModified.LastWriteTime -lt  (Get-Date).AddDays(-$olderThan)))){
        "Adding to remove list $($userProfile.LocalPath.split("\")[-1])"
        $removeUsers+=$userProfile
    }
}

if(-not([string]::IsNullOrEmpty($removeUsers))){
    "="*45
    "$(Get-Date) : Profile Cleanup start"
    "="*45
    "$($removeUsers.Count) user profiles are found to remove"
    $removeUsers | %{try{"trying Removing user $($_.LocalPath.split("\")[-1])";`
    $_ | Remove-CimInstance -Confirm:$false -ErrorAction Stop ;"Successfully removed $($_.LocalPath.split("\")[-1])"}`
    catch{"Failed to remove $($_.Exception.Message)"}}
    "$(Get-Date) : Profile Cleanup end"
    }else{
    "****No Profiles are exists older than $olderThan days"
   }

   "="*45
   "$(Get-Date) : Profile Cleanup"
   "="*45
