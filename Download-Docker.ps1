cls
$build = Invoke-RestMethod -UseBasicParsing https://desktop.docker.com/win/main/amd64/appcast.xml | select -ExpandProperty title
$build = (($build.Split(" ")[-1]).trimstart("(")).trimend(")")
$url   = "https://desktop.docker.com/win/main/amd64/BUILD/Docker%20Desktop%20Installer.exe"
$url   = $url -replace "BUILD",$build
$DockerInstaller = Join-Path $Env:Temp 'Docker Desktop Installer.exe'
if(Test-Path $DockerInstaller){Remove-Item -Path $DockerInstaller -Force -ErrorAction SilentlyContinue}
Invoke-WebRequest -Uri $url -OutFile $DockerInstaller -UseBasicParsing
