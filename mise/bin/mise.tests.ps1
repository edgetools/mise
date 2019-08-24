
# cannot automatically determine script path due to https://github.com/PowerShell/PowerShell/issues/4217

$mise = Join-Path $pwd 'bin' 'mise'

Describe 'mise' -Tag 'system' {
  It 'Given -Version, prints a valid Version' {
    $output = & $mise -Version
    $output | Should -MatchExactly '\d+\.\d+\.\d+(-([A-Za-z0-9])+){0,1}'
  }
}
