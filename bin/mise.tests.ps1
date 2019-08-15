
# cannot automatically determine script path due to https://github.com/PowerShell/PowerShell/issues/4217

$mise = Join-Path $pwd 'bin' 'mise'

# Describe 'mise' {
#   It 'Given no arguments, prints Foo' {
#     $output = & $mise
#     $output | Should -Be 'Foo'
#   }
# }
