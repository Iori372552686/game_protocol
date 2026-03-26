$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
Get-ChildItem -Path (Join-Path $root "proto") -Recurse -Filter "*.proto" |
  Where-Object {
    $raw = Get-Content -LiteralPath $_.FullName -Raw
    $raw -notmatch "github.com/Iori372552686/GoOne/api/gen/"
  } |
  Sort-Object FullName |
  ForEach-Object {
    $_.FullName.Substring($root.Length + 1) -replace "\\", "/"
  }
