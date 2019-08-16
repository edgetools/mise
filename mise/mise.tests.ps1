# tests
# ======================================================================================================================
Import-Module (Join-Path $PSScriptRoot 'mise') -Force

Describe 'Invoke-MiseCli' -Tag 'unit' {
  It 'Given no arguments, Foo' {
    Invoke-MiseCli | Should -Be 'Foo'
  }
}
