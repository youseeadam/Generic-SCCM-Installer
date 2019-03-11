# Generic-SCCM-Installer
This is a generic SCCM Installer for use with an EXE.
The notes of the script have the process, but here it is again.

<p>This script is called via a standard command batch file. The reason for doing it this way is so an errorcode can be returned to the system exit environmental variable. To call this script create a command line batch file with the following two lines</p>

<i>
PowerShell.exe -ExecutionPolicy ByPass -file AppInstaller.ps1 -InstallerApp %1 -InstallerOptions %2<br />
exit /b %errorlevel%
</i>
<p>Then call the CMD file as follows from within SCCM</p>
<i>cmd /c AppInstaller.cmd "ApplicationName" "CommandLineOptions"</i><br />
For example: cmd /c AppInstaller.cmd "LogiSyncInstaller_1.0.0.exe" "/S /RS1=Dynamic" The order of the two options is absolute. The application must be followed by the options.<br />

<p>When building the SCCM packages you will need to edit the package and add the following two exit codes  </p>
0 is a Succsefull Install<br />
2 is failed for parent app<br />


<p>A basic log file using the transcript function will also be logged in the temp directory of the account. So if installing for System in c:\windows\temp (typically), or under the users temp directory if installing it for a user. The filename is %temp%install-ApplicatioName.log for example c:\windows\temp\insatall-LogiSyncInstaller_1.0.0.exe.log</p>
    
