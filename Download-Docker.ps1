cls
#Method 1
$build = Invoke-RestMethod -UseBasicParsing https://desktop.docker.com/win/main/amd64/appcast.xml | select -ExpandProperty title
$Version = $build.Split(" ")[0]
$build = (($build.Split(" ")[-1]).trimstart("(")).trimend(")")
"$build and $Version"
$url   = "https://desktop.docker.com/win/main/amd64/BUILD/Docker%20Desktop%20Installer.exe"
$url   = $url -replace "BUILD",$build
"Download URL $url"
$DockerInstaller = Join-Path $Env:Temp 'Docker Desktop Installer.exe'
if(Test-Path $DockerInstaller){Remove-Item -Path $DockerInstaller -Force -ErrorAction SilentlyContinue}
Invoke-WebRequest -Uri $url -OutFile $DockerInstaller -UseBasicParsing

#Method 2 
$Dockerinfo = (irm -uri https://desktop.docker.com/win/main/amd64/appcast.xml).enclosure
$downloadURL = $Dockerinfo.url[-1]
$DockerInstaller = Join-Path $Env:Temp 'Docker Desktop Installer.exe'
if(Test-Path $DockerInstaller){Remove-Item -Path $DockerInstaller -Force -ErrorAction SilentlyContinue}
Invoke-WebRequest -Uri $downloadURL -OutFile $DockerInstaller -UseBasicParsing
