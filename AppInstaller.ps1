<#
.SYNOPSIS
    Used for installing Software. This script is called via a standard command batch file. The reason for doing it this way is so an errorcode can be returned
    to the system exit environmental variable. To call this script create a command line batch file with the following line
    
    PowerShell.exe -ExecutionPolicy ByPass -file AppInstaller.ps1 -InstallerApp %1 -InstallerOptions %2
    exit /b %errorlevel%

    Then call the CMD file as follows from within SCCM
    cmd /c AppInstaller.cmd "ApplicationName" "CommandLineOptions" for example
    cmd /c AppInstaller.cmd "LogiSyncInstaller_1.0.0.exe" "/S /RS1=Dynamic"

    When building the SCCM packages you will need to edit the psackage and add the following two exit codes 
    0 is a Succsefull Install
    2 is failed for parent app

    A basic log file using the transcript function will also be logged in the temp directory of the account. So if installing for System in c:\windows\temp (typically), or under
    the users temp directory if installing it for a user. The filename is %temp%install-ApplicatioName.log for example c:\windows\temp\insatall-LogiSyncInstaller_1.0.0.exe.log
    
.DESCRIPTION
    This will install an application via SCCM and return an error code. The exit code only returns if the application actually ran or not. It will not report on if something happened
    during the install process. Think of it more like a fancy file check.

    I return the custom error codes because in PowerShell a 1 is considered a succes. So to make this work right in SCCM, I have to return non standard PowerShell errors.

.NOTES
    File Name           : Install-LogitechSync.ps1
    Author              : Adam Berns (aberns@logitech.com)
    Prerequisite        : PowerShell V2 or later
    Script posted over  : Google Files (check with author for access)

.PARAMETER InstallerApp
    Used to call the actual application to be installed, for example: "LogiSyncInstaller_1.0.0.exe"

.PARAMETER InstallOptions
    Command line switches for installing, for example to install with silent install: "/S /RS1=Dynamic"
    This is a string of options, usually found by running the installer with a /?

.EXAMPLE 
    Install-LogitechSync.ps1 -InstallerApp "LogiSyncInstaller_1.0.0.exe" -InstallOptions "/S /RS1=Dynamic"
#>

[CmdletBinding(SupportsShouldProcess)]
Param (

    [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
    [string]$InstallerApp,

    [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
    [string]$InstallOptions

)


$logfile = (get-item env:temp).Value+"\install-"+$InstallerApp+".log"
Start-Transcript -Path $logfile -IncludeInvocationHeader

$Global:InstallFilePath = Split-Path -parent $MyInvocation.MyCommand.Path 

function InstallSync  {

    $GLobal:LASTEXITCODE = 0
    $InstallFilePath = $Global:InstallFilePath + "\" + $InstallerApp
    #Install the Sync App
    try {
        Start-Process -FilePath $InstallFilePath -ArgumentList $InstallOptions -wait -ErrorAction Stop
        Return 0
    }
    catch {
        return 2
    }
}



#Install the applications
$installSync = InstallSync
if ($installSync -eq 0) {
    stop-Transcript
    [System.Environment]::Exit(0)
}
else {
    stop-Transcript
    [System.Environment]::Exit([int]$installSync)
}



