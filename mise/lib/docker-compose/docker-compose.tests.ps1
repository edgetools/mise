# tests
# ======================================================================================================================

Describe 'Invoke-Foo' -Tag 'unit' {
  Import-Module (Join-Path $PSScriptRoot 'docker-compose') -Force

  It 'Given no arguments, prints Hello Foo' {
    $output = Invoke-Foo
    $output | Should -Be 'Hello Foo'
  }
}
