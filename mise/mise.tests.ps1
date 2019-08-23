# tests
# ======================================================================================================================
Import-Module (Join-Path $PSScriptRoot 'mise') -Force

Describe 'Invoke-MiseCli' -Tag 'unit' {
  It 'Given -Version, Prints Version' {
    # this is not a good test
    # it's just a placeholder
    # we should test the cli externally with bin/mise.tests.ps1
    # and this cli should just be tested with mock calls
    Invoke-MiseCli -Version | Should -Be (Get-MiseVersion).ToString()
  }
}
