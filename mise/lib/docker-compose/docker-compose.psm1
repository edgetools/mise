
function Invoke-Foo {
  Write-Output 'Hello Foo'
}

Export-ModuleMember -Function @(
  'Invoke-Foo'
)

# service lifecyle api
# ======================================================================================================================

