# main
# ======================================================================================================================

try {
  # source all lib .ps1 files, ignore tests
  Get-ChildItem `
    -LiteralPath (Join-Path $PSScriptRoot 'lib') `
    -Recurse `
    -File `
    -Filter '*.ps1' `
    -Exclude '*.tests.ps1' |
  ForEach-Object {
    Write-Verbose "Sourcing lib from path '$($_.FullName)'."
    . $_.FullName
  }

  # alias mise to the entry point
  Set-Alias -Name 'mise' -Value (Join-Path $PSScriptRoot 'bin' 'mise.ps1')

  # import config file (TODO: import from known locations)
  Import-MiseConfigFile (Join-Path $PWD '.mise.json')

  # set initial context
  New-MiseContext | Set-MiseContext
}
catch {
  throw $_
}
