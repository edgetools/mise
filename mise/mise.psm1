# main
# ======================================================================================================================

Import-Module (Join-Path $PSScriptRoot 'lib' 'docker-compose')

function Invoke-Cli {
  Write-Output 'Foo'
}
