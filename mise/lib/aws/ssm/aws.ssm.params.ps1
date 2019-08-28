

function Get-MiseSSMParameter {
  Import-Module AWS.Tools.SimpleSystemsManagement

  if ($args.Count -gt 0) {
    if ($args.Count -eq 1) {
      $paramPath = $args[0]
      $paramfilter = @{Key='Path'; Option='Recursive'; Values=$paramPath;}
    } elseif ($args.Count -gt 1) {
      $paramPath = Join-UriPath @args
      $paramfilter = @{Key='Path'; Option='OneLevel'; Values=$paramPath;}
    }
    Write-Verbose "get $paramPath"
    Get-SSMParameterList -ParameterFilter $paramfilter
  }
}
