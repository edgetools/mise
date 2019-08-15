# constants
# ======================================================================================================================

Set-Variable -Option Constant -Name SCRIPT_ROOT -Value (Split-Path -Parent $MyInvocation.MyCommand.Definition)

# tests
# ======================================================================================================================

Describe 'Invoke-Foo' {
  Import-Module "$PSScriptRoot/docker-compose"

  It 'Given no arguments, prints Hello Foo' {
    $output = Invoke-Foo
    $output | Should -Be 'Hello Foo'
  }
}
