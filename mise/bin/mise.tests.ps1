
$mise = Join-Path $PSScriptRoot 'mise'

Describe 'mise' -Tag 'system' {
  It 'Given -Version, prints a valid Version' {
    $output = & $mise -Version
    $output | Should -MatchExactly '\d+\.\d+\.\d+(-([A-Za-z0-9])+){0,1}'
  }
}
