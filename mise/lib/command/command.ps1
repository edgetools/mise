function Invoke-MiseGetCommand {
  Write-Host 'hello from get'
}

function Invoke-MiseEnCommand {
  [CmdletBinding()]
  Param(
    [Parameter(
      Mandatory=$true,
      Position=0
    )]
    [string[]]$Target,

    [Parameter(
      Mandatory=$true,
      Position=1,
      ValueFromRemainingArguments
    )]
    [string[]]$Remainder,

    [Parameter(
      Mandatory=$true
    )]
    [psobject]$Context
  )

  # Write-Host "en args: $Remainder"
  Write-Host "en target: $Target"
  Write-Host "en remainder: $Remainder"
  Write-Host "en context: $Context"

  # if ($null -eq $Context.Project) {
  #   # no current context
  #   # check number of args and set based on that
  # }

  # given no context:
  # - en PROJECT [ENV] [SERVICE]
  # given project:
  # - en ENV [SERVICE]
  # given env:
  # - en SERVICE

  # $currentContext = Get-MiseContext
  # Write-Host "got context: $currentContext"
  # Write-Host "args: $args"
  # Write-Host "args type: $($args.GetType())"
  # Write-Host "args count: $($args.Count)"
  # Write-Host "args length: $($args.Length)"
  # Write-Host "args is null: $($null -eq $args)"
  # Write-Host "args[0] is null: $($null -eq $args[0])"
  # if ($null -eq $args) {
  #   Write-Host "resetting context"
  #   $currentContext.Project = $null
  # } elseif ($null -eq $currentContext.Project) {
  #   Write-Host "setting context"
  #   if ($null -ne $args[0]) {
  #     $currentContext.Project = $args[0].ToString()
  #   }
  # }
}
