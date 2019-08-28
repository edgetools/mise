function Invoke-MiseGetCommand {
  Write-Host 'hello from get'
}

function Invoke-MiseEnCommand {
  [CmdletBinding(PositionalBinding=$false)]
  Param(
    [Parameter(
      Mandatory=$false,
      Position=0,
      ValueFromRemainingArguments
    )]
    [string[]]$CommandLine,

    [Parameter(
      Mandatory=$true
    )]
    [psobject]$Context
  )

  Write-Host "en command line: $CommandLine"
  Write-Host "en command line count: $($CommandLine.Count)"
  Write-Host "en command line length: $($CommandLine.Length)"
  if ($null -ne $CommandLine) {
    Write-Host "en command line type: $($CommandLine.GetType())"
  } else {
    Write-Host "en command line type: null"
  }
  Write-Host "en context: $Context"

  # given no context:
  # - en PROJECT [ENV] [SERVICE]
  # given project:
  # - en ENV [SERVICE]
  # given env:
  # - en SERVICE

  switch ($CommandLine.Count) {
    0 {
      # reset context
      Reset-MiseContext
    }
    1 {
      $Context.Project = $CommandLine[0]
    }
    2 {
      $Context.Project = $CommandLine[0]
      $Context.Env = $CommandLine[1]
    }
    3 {
      $Context.Project = $CommandLine[0]
      $Context.Env = $CommandLine[1]
      $Context.Service = $CommandLine[2]
    }
  }

  # if ($null -eq $Context.Project) {
  #   # no current context
  #   # check number of args and set based on that
  # } else {

  # }

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
