param()

$VSCode = (Get-Command -Name "code" -ErrorAction SilentlyContinue);

If ($Null -eq $VSCode) {
  Throw "VS Code not found on path.";
} Else {
  $VSC_Version = ((& "$($VSCode.Source)" "--version") -Split "\n");
  $VSC_VersionClass = [Version]::Parse($VSC_Version[0]);
  If ($VSC_Version[2] -notmatch "x[63][42]" -and $VSC_VersionClass.Major -lt 1 -and $VSC_VersionClass.Minor -lt 70) {
    Throw "Version does not match x64/x32 and not greater than 1.70.0";
  }
}

Invoke-Expression -Command "& `"$($VSCode.Source)`" --profile `"FFXIV Mods`" --new-window `"$(Join-Path -Path $PSScriptRoot -ChildPath "FinalFantasyXIV.code-workspace")`"";

Exit 0;