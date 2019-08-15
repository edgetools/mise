
# constants
# ======================================================================================================================

Set-Variable -Option Constant -Name SCRIPT_ROOT -Value (Split-Path -Parent $MyInvocation.MyCommand.Definition)

# main
# ======================================================================================================================

Import-Module (Join-Path $SCRIPT_ROOT 'lib')

Invoke-Foo
