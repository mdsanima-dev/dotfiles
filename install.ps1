# Copyright © 2023 MDSANIMA

# This is a installation script for `Oh My Posh` a prompt theme engine.
# This installer is only available for Windows on PowerShell terminal.

# Input switch parameters when the script is started.
param (
    [switch]$version = $false,
    [switch]$help = $false,
    [switch]$install = $true
)

# Initial necessary variables.
[string]$currentPath = $PWD.Path
[string]$fileName = "Microsoft.PowerShell_profile.ps1"
[string]$themeName = "mdsanima.omp.json"
[string]$getLastGitTag = git describe --tags
[string]$getLastCommit = git rev-parse HEAD
[string]$getDate = Get-Date -UFormat "%d %B %Y %A %H:%M:%S"
[string]$userDocuments = [Environment]::GetFolderPath("MyDocuments")
[string]$operatingSystem = [Environment]::OSVersion.VersionString
[string]$powerShellFolder = Join-Path $userDocuments "PowerShell"
[string]$themePath = Join-Path $currentPath ".config\omp\$themeName"
[string]$profilePath = Join-Path $powerShellFolder $fileName

# Profile content data config for auto generated file.
[string]$profileContent = @"
# This file has been auto generated by installation script.
# For more info please check the event log below.

#   [EVENT LOG]
#    Generated:  $getDate
#       System:  $operatingSystem
#      Version:  $getLastGitTag
#   Repository:  https://github.com/mdsanima-dev/dotfiles
#       Commit:  $getLastCommit
#       Script:  $currentPath\install.ps1
#        Theme:  $themePath
#      Profile:  $profilePath

# Initial setup prompt theme.
oh-my-posh init pwsh --config $themePath | Invoke-Expression

# Import necessary modules.
Import-Module -Name Terminal-Icons
Import-Module -Name PSReadLine

# Config history options.
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
"@

# Writing the event log info.
function Write-ShowInfo {
    param($BgColor, $FgColor, [string]$LogInfo)
    Write-Host ""
    Write-Host "  " -NoNewLine
    Write-Host " MDSANIMA-DEV " -ForegroundColor White -BackgroundColor $BgColor -NoNewLine
    Write-Host " $LogInfo" -ForegroundColor $FgColor
}

# Writing the version and app name.
function Write-ShowVersion {
    Write-ShowInfo DarkGray Blue "dotfiles $getLastGitTag"
    Write-Host ""
}

# Writing the help instruction.
function Write-ShowHelp {
    Write-ShowVersion
    Write-Host "  This installer is only available for Windows on PowerShell terminal." -ForegroundColor White
    Write-Host ""
    Write-Host "  Copyright © 2023 MDSANIMA" -ForegroundColor Blue
    Write-Host ""
}

# Creating the PowerShell profile for current user.
function Out-CreateProfile {
    $content = $profileContent

    # Checking if the `PowerShell` folder exists, if not, create it.
    if (-not (Test-Path -Path $powerShellFolder -PathType Container)) {
        New-Item -Path $powerShellFolder -ItemType Directory > $null
        Write-ShowInfo Green DarkGray "A 'PowerShell' folder has been successfully created in the user's Documents directory."
        Write-Host "  Path:" -ForegroundColor Green -NoNewLine; Write-Host " $powerShellFolder"
    }

    # Checking if the profile exist, if yes, create backup file.
    if (Test-Path -Path $profilePath) {
        $fileInfo = Get-Item -Path $profilePath
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $randomString = [System.Guid]::NewGuid().ToString("N").Substring(0, 8)
        $extension = $fileInfo.Extension
        $newFileName = "{0}_backup_{1}_{2}{3}" -f $fileInfo.BaseName, $timestamp, $randomString, $extension
        $newFilePath = Join-Path -Path $powerShellFolder -ChildPath $newFileName
        Copy-Item -Path $profilePath -Destination $newFilePath
        Write-ShowInfo Green DarkGray "The backup for profile has been successfully created in the 'PowerShell' folder."
        Write-Host "  Path:" -ForegroundColor Green -NoNewLine; Write-Host " $newFilePath"
    }

    # Creating new profile.
    $content | Out-File -FilePath $profilePath -Encoding UTF8
    Write-ShowInfo Green DarkGray "The new profile has been successfully created in the 'PowerShell' folder."
    Write-Host "  Path:" -ForegroundColor Green -NoNewLine; Write-Host " $profilePath"
}

# Showing the latest tag from git repo when type `-version` or `-v` options.
if ($version -like $true) {
    $install = $false
    Write-ShowVersion
}

# Showing the help instruction when type `-help` or `-h` options.
if ($help -like $true) {
    $install = $false
    Write-ShowHelp
}

# Runing the main installation script.
if ($install -like $true) {
    Write-ShowVersion

    Write-ShowInfo Blue White "Setting up a installation policy..."
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

    Write-ShowInfo Blue White "Setting up a execution policy..."
    Set-ExecutionPolicy Bypass -Scope Process -Force

    Write-ShowInfo Blue White "Downloading a 'Oh My Posh' installation script..."
    Write-Host ""; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://ohmyposh.dev/install.ps1"))

    Write-ShowInfo Blue White "Installing the 'Terminal-Icons' module..."
    Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser

    Write-ShowInfo Blue White "Installing the 'PSReadLine' module..."
    Install-Module -Name PSReadLine -Repository PSGallery -Scope CurrentUser

    Write-ShowInfo Blue White "Creating the 'PowerShell' profile..."
    Out-CreateProfile

    Write-Host ""; Write-ShowInfo DarkGray Green "Installation Done!"; Write-Host ""
}