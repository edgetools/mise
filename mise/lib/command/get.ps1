function Invoke-MiseGetCommand {
  Param(
    [Parameter(
      Mandatory=$false
    )]
    [string]$Foo,

    [Parameter(
      Mandatory=$false
    )]
    [string]$Bar,

    [Parameter(
      Mandatory=$false
    )]
    [switch]$Baz
  )

  Write-Host "Foo is: $Foo"
  Write-Host "Bar is: $Bar"
  Write-Host "Baz is: $Baz"
}

# function Invoke-MiseGetCommand {
#   Write-Host "args: $args"
#   Write-Host "args.Count: $($args.Count)"
#   Write-Host "args.Length: $($args.Length)"
#   if ($null -ne $args) {
#     Write-Host "args.Type: $($args.GetType())"
#     foreach ($item in $args) {
#       Write-Host "args item: $item"
#       Write-Host "args item.Type: $($item.GetType())"
#     }
#   } else {
#     Write-Host "args.Type: null"
#   }
# }
