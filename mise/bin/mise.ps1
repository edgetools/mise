<#
.SYNOPSIS
    entry point for invoking mise commands
#>

Param(
  [string]$Command
)

try {
  Import-Module (Resolve-Path (Join-Path $PSScriptRoot '..'))

  switch ($Command) {
    'version' {
      Invoke-MiseVersionCommand @args
      break
    }
    'get' {
      Invoke-MiseGetCommand @args
      break
    }
    'shell' {
      Enter-MiseShell
      break
    }
    'args' {
      Write-Host "args: $args"
      Write-Host "args.Count: $($args.Count)"
      Write-Host "args.Length: $($args.Length)"
      if ($null -ne $args) {
        Write-Host "args.Type: $($args.GetType())"
        foreach ($item in $args) {
          Write-Host "args item: $item"
          Write-Host "args item.Type: $($item.GetType())"
        }
      }
      else {
        Write-Host "args.Type: null"
      }
      break
    }
  }
} catch {
  throw $_
}
