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
            # add default Context if not provided
            if (!$fakeBoundParameters.ContainsKey('Context')) {
              $fakeBoundParameters.Add('Context', (Get-MiseContext))
            }
            # get children of current Context
            $children = $fakeBoundParameters.Context | Get-MiseContextChildren
            # check if we can go up
            if ($null -ne $fakeBoundParameters.Context.Location.Parent) {
              # add option to go up
              $children += '..'
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
