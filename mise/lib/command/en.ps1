function Invoke-MiseEnCommand {
  [CmdletBinding(PositionalBinding = $false)]
  Param(
    [Parameter(
      Mandatory = $false,
      Position = 0,
      ValueFromRemainingArguments
    )]
    [string[]]$CommandLine,

    [Parameter(
      Mandatory = $false
    )]
    [psobject]$Context = (Get-MiseContext)
  )

  # Write-Host "en command line: $CommandLine"
  # Write-Host "en command line count: $($CommandLine.Count)"
  # Write-Host "en command line length: $($CommandLine.Length)"
  # if ($null -ne $CommandLine) {
  #   Write-Host "en command line type: $($CommandLine.GetType())"
  # }
  # else {
  #   Write-Host "en command line type: null"
  # }
  # Write-Host "en context: $($Context.Location)"

  # given no context:
  # - en PROJECT [ENV] [SERVICE]
  # given project:
  # - en ENV [SERVICE]
  # given env:
  # - en SERVICE

  if ($CommandLine.Count -eq 0) {
    # list current context children
    $Context | Get-MiseContextChildren
    return
  } else {
    foreach ($item in $CommandLine) {
      # based on level, get children (and later parent for ..)
      $Context | Move-MiseContextLocation -Target $item
    }
  }

  # switch ($CommandLine.Count) {
  #   0 {
  #     # list current context
  #     $Context | Get-MiseContextChildren
  #     # reset context
  #     # New-MiseContext | Set-MiseContext
  #   }
  #   1 {
  #     # change context to child of current context
  #     # eventually we should check if it's actually a child
  #     # right now we'll just force it
  #     # - get current context level (Global, Etc)
  #     # - based on current context, get children of config
  #     # - check if requested child is a real child
  #     # - switch to child
  #     $Context.Location = New-MiseContextLocation `
  #       -Name $CommandLine[0] `
  #       -Parent $Context.Location
  #   }
  #   2 {
  #     $Context.Location = New-MiseContextLocation `
  #       -Name $CommandLine[0] `
  #       -Parent $Context.Location
  #       $Context.Location = New-MiseContextLocation `
  #       -Name $CommandLine[1] `
  #       -Parent $Context.Location
  #   }
  # }

  # switch ($CommandLine.Count) {
  #   0 {
  #     # reset context
  #     $Context | Reset-MiseContext
  #   }
  #   1 {
  #     # 1 arg
  #     # - check if we're currently at Project level, Env level, or Service level
  #     if ($null -eq $Context.Project) {
  #       # no current context
  #       # reset and set project
  #       $Context | Reset-MiseContext
  #       $Context.Project = $CommandLine[0]
  #     } else {
  #       # there is a project
  #       # is there an environment?
  #       if ($null -eq $Context.Env) {
  #         # no environment
  #         # set environment
  #         $Context.Env = $CommandLine[0]
  #       } else {
  #         # there is an environment
  #         # set service
  #         $Context.Service = $CommandLine[0]
  #       }
  #     }
  #   }
  #   2 {
  #     $Context.Project = $CommandLine[0]
  #     $Context.Env = $CommandLine[1]
  #   }
  #   3 {
  #     $Context.Project = $CommandLine[0]
  #     $Context.Env = $CommandLine[1]
  #     $Context.Service = $CommandLine[2]
  #   }
  # }

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
