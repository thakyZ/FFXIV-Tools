Param()

# remote: Enumerating objects: 258, done.
# remote: Counting objects: 100% (258/258), done.
# remote: Compressing objects: 100% (126/126), done.
# remote: Total 258 (delta 170), reused 220 (delta 132), pack-reused 0
# Receiving objects: 100% (258/258), 31.85 KiB | 3.18 MiB/s, done.
# Resolving deltas: 100% (170/170), done.
# From github.com:thakyZ/MyDalamudPlugins
#    c4b1a5d..ea60efe  main       -> origin/main
# Updating c4b1a5d..ea60efe
# Fast-forward
#  pluginmaster.json | 66 +++++++++++++++++++++++++++----------------------------
#  1 file changed, 33 insertions(+), 33 deletions(-)

Begin {
  $DefaultLocation = (Get-Item -LiteralPath $PWD);
  $GitDirectories = (Get-ChildItem -LiteralPath (Get-Item -LiteralPath $PSScriptRoot).Parent -Directory | Where-Object { Return $Null -ne (Get-Item -LiteralPath (Join-Path -Path $_.FullName -ChildPath ".git") -Force -ErrorAction SilentlyContinue) })

  $Git = (Get-Command -Name "git" -ErrorAction SilentlyContinue)

  If ($Null -ne $Git) {
    $Git = $Git.Source;
  } Else {
    Write-Error "Git not found on path..."
    Exit 1;
  }

  #$env:GIT_REDIRECT_STDERR = '2>&1'
}
Process {
  ForEach ($Directory in $GitDirectories) {
    Set-Location -LiteralPath $Directory.FullName;
    $Remotes = (Use-Git "remote");

    ForEach ($Remote in $Remotes.RemoteName) {
      $Output = (Use-Git fetch $Remote --dry-run)
      $GottenUpdates = (($Output.GitOutput -Split "\n") | Select-String -Pattern "^\s+(?:\+\s+)?[0-9a-f]{8}\.\.\.?[0-9a-f]{8}\s+([^\s]+)\s+->\s+([^\s]+)");
      If ($Null -ne $GottenUpdates -and $GottenUpdates.Matches.Count -gt 0) {
        Write-Host -ForegroundColor "Blue" -Object "$($Directory.Name) has updates on:"
        ForEach ($BranchMatch in $GottenUpdates.Matches) {
          Write-Host -ForegroundColor "Yellow" -Object "$($BranchMatch.Groups[1])" -NoNewLine
          Write-Host -ForegroundColor "White" -Object "    ->    " -NoNewLine
          Write-Host -ForegroundColor "Yellow" -Object "$($BranchMatch.Groups[2])"
        }
      }
    }
  }
}
End {
  Set-Location -LiteralPath $DefaultLocation;
}