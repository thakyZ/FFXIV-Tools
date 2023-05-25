[CmdletBinding()]
param()

class ProjectPath {
  [string]$path
}

If ($PSBoundParameters.ContainsKey("Debug")) {
  $DebugPreference = "Continue"
}

$WorkspaceFile = (Join-Path -Path $PSScriptRoot -ChildPath "FinalFantasyXIV.code-workspace");
$BaseDirectory = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath ..));

If (-not (Test-Path -LiteralPath $WorkspaceFile -PathType Leaf)) {
  Write-Error "Workspace file does not exist at: $WorkspaceFile";
}
Else {
  Write-Debug -Message "`$WorkspaceFile: $WorkspaceFile";
  $WorkspaceFile = (Get-Item -LiteralPath $WorkspaceFile);
}

If (-not (Test-Path -LiteralPath $BaseDirectory -PathType Container)) {
  Write-Error "Could not find base directory at: $BaseDirectory";
}
Else {
  Write-Debug -Message "`$BaseDirectory: $BaseDirectory";
  $BaseDirectory = (Get-Item -LiteralPath $BaseDirectory);
}

$WorkspaceJson = (Get-Content -LiteralPath $WorkspaceFile.FullName | ConvertFrom-Json -Depth 100);

$WorkspaceJson.folders = @();

$ProjectFolders = (Get-ChildItem -LiteralPath $BaseDirectory -Recurse -Depth 0 -Directory);

$ProjectFoldersArray = @();

$OldPath = $PWD;
Set-Location -LiteralPath $PSScriptRoot;

ForEach ($Folder in $ProjectFolders) {
  $RelativePath = (Resolve-Path -LiteralPath $Folder.Fullname -Relative) -Replace "`\`\", "/";
  Write-Debug -Message "`$RelativePath: $RelativePath";
  $NewObject = (New-Object -TypeName ProjectPath);
  $NewObject.path = $RelativePath
  $ProjectFoldersArray += $NewObject;
}

$WorkspaceJson.folders = $ProjectFoldersArray;

Set-Location -LiteralPath $OldPath;

$NewJson = ($WorkspaceJson | ConvertTo-Json -Depth 100);

$NewJson | Set-Content -LiteralPath $WorkspaceFile.Fullname;