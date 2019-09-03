function Invoke-MiseEnCommand {
  [CmdletBinding(PositionalBinding = $false)]
  Param(
    [Parameter(
      Mandatory = $false,
      Position = 0,
      ValueFromRemainingArguments
    )]
    [ArgumentCompleter(
      {
          param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
          if ($parameterName -eq 'Locations') {
            Write-Warning ''
            Write-Warning "commandName: $commandName"
            Write-Warning "parameterName: $parameterName"
            Write-Warning "wordToComplete: $wordToComplete"
            Write-Warning "commandAst: $commandAst"
            Write-Warning "commandAst.Length: $($commandAst.Length)"
            Write-Warning "commandAst.Count: $($commandAst.Count)"
            Write-Warning "commandAst.CommandElements: $($commandAst.CommandElements)"
            Write-Warning "commandAst.CommandElements.Count: $($commandAst.CommandElements.Count)"
            Write-Warning "commandAst.Parent: $($commandAst.Parent)"
            Write-Warning "fakeBoundParameters: $fakeBoundParameters"
            # add default Context if not provided
            if (!$fakeBoundParameters.ContainsKey('Context')) {
              $fakeBoundParameters.Add('Context', (Get-MiseContext))
            }

            # get children of current Context, N levels deep
            $contextAtDepth = $Context
            for ($i=1; $i -lt $commandAst.CommandElements.Count; $i++) {
              $contextAtDepth = $contextAtDepth.Location
            }
            $children = $fakeBoundParameters.Context | Get-MiseContextChildren
            if ($commandAst.CommandElements.Count -eq 1) {
              # check if we can go up
              if ($null -ne $fakeBoundParameters.Context.Location.Parent) {
                # add option to go up
                $children += '..'
              }
            }
            # check if we're trying to complete an option
            if ($null -ne $wordToComplete) {
              # filter to only matches
              $children = $children | Where-Object { $_.StartsWith($wordToComplete) }
            }
            # return each result
            foreach ($child in $children) {
              [System.Management.Automation.CompletionResult]::new($child, $child, 'ParameterValue', $child)
            }
          }
      }
    )]
    [string[]]$Locations,

    [Parameter(
      Mandatory = $false
    )]
    [psobject]$Context = (Get-MiseContext)
  )

  if ($PSBoundParameters.Locations.Count -eq 0) {
    # list current context children
    $Context | Get-MiseContextChildren
    return
  } else {
    foreach ($TargetLocation in $PSBoundParameters.Locations) {
      # based on level, get children (and later parent for ..)
      $Context | Move-MiseContextLocation -Target $TargetLocation
    }
  }
}
