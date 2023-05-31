@echo off
SET mypath=%~dp0
where /q pwsh
SET exitcode=1
IF ERRORLEVEL 1 (
    powershell -c %mypath%\FinalFantasyXIV-Workspace.ps1"
    SET exitcode=ERRORLEVEL
) ELSE (
    pwsh -c "%mypath%\FinalFantasyXIV-Workspace.ps1"
    SET exitcode=ERRORLEVEL
)

IF "%exitcode%"=="1" (
  EXIT /B
)