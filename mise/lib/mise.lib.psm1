
try {
  # source all lib .ps1 files, ignore tests
  Get-ChildItem -LiteralPath $PSScriptRoot -Recurse -File -Filter '*.ps1' -Exclude '*.tests.ps1' | ForEach-Object {
    Write-Verbose "Sourcing lib from path '$($_.FullName)'."
    . $_.FullName
  }
} catch {
  throw $_
}

# these will be available to mise.psm1
# TODO: restrict this list
# Export-ModuleMember `
# -Function @(
#   'Get-MiseConfigValue',
#   'Get-MiseConfig',
#   'Get-MiseProject',
#   'Import-MiseConfigFile',
#   'Set-MiseConfigValue',
#   'Get-MiseSSMParameter'
# )
