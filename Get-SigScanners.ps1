[CmdletBinding()]
param()

$SigScannerDataFile = (Join-Path -Path $PSScriptRoot -ChildPath "SigScanners.json");
$BaseDirectory = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath ..));

If (Test-Path -LiteralPath $SigScannerDataFile -PathType Leaf) {
  Remove-Item -LiteralPath $SigScannerDataFile;
}

class SigScannerDataFile {
  [System.Collections.Hashtable]$Projects;
}

$ProjectFolders = (Get-ChildItem -LiteralPath $BaseDirectory -Recurse -Depth 0 -Directory);

$SigScannerData = (New-Object -TypeName SigScannerDataFile);
$TempProjectHashMap = [ordered]@{};

Function ConvertTo-RelativeBaseDirectory() {
  param(
    # Specifies a path to one or more locations.
    [Parameter(Mandatory = $true,
      Position = 0,
      ParameterSetName = "Path",
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      HelpMessage = "Path to one or more locations.")]
    [Alias("PSPath", "LiteralPath")]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Path
  )

  $TempPathString = (Resolve-Path -LiteralPath $Path -Relative);

  Return ($TempPathString -Replace "^..\\", "")
}

ForEach ($Project in $ProjectFolders) {
  $TempProjectArray = @();

  $CSFiles = (Get-ChildItem -LiteralPath $Project.FullName -Recurse -File -Filter "*.cs");

  ForEach ($CSFile in $CSFiles) {
    If ($Null -ne ((Get-Content -LiteralPath $CSFile.FullName) | Select-String "SigScanner")) {
      $TempProjectArray += (ConvertTo-RelativeBaseDirectory -Path $CSFile.FullName);
    }
    ElseIf ($Null -ne ((Get-Content -LiteralPath $CSFile.FullName) | Select-String "Scan")) {
      $TempProjectArray += (ConvertTo-RelativeBaseDirectory -Path $CSFile.FullName);
    }
    ElseIf ($Null -ne ((Get-Content -LiteralPath $CSFile.FullName) | Select-String "GetStaticAddressFromSig")) {
      $TempProjectArray += (ConvertTo-RelativeBaseDirectory -Path $CSFile.FullName);
    }
    ElseIf ($Null -ne ((Get-Content -LiteralPath $CSFile.FullName) | Select-String "ScanData")) {
      $TempProjectArray += (ConvertTo-RelativeBaseDirectory -Path $CSFile.FullName);
    }
    ElseIf ($Null -ne ((Get-Content -LiteralPath $CSFile.FullName) | Select-String "ResolveRelativeAddress")) {
      $TempProjectArray += (ConvertTo-RelativeBaseDirectory -Path $CSFile.FullName);
    }
    ElseIf ($Null -ne ((Get-Content -LiteralPath $CSFile.FullName) | Select-String "ScanText")) {
      $TempProjectArray += (ConvertTo-RelativeBaseDirectory -Path $CSFile.FullName);
    }
  }

  If ($TempProjectArray.Count -eq 0) {
    continue;
  }
  Else {
    $TempProjectHashMap[$Project.Name] = $TempProjectArray;
  }
}

If ($TempProjectHashMap.Keys.Count -gt 0) {
  $SigScannerData.Projects = $TempProjectHashMap;
  ($SigScannerData | ConvertTo-Json) | Out-File $SigScannerDataFile;
}

