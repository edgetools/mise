# variables
# ======================================================================================================================

New-Variable -Scope Script -Name MiseContext -Value $null

# functions
# ======================================================================================================================

function New-MiseContext {
  $newContext = [PSCustomObject]@{
    Project = $null
    Env = $null
    Service = $null
  }

  # override .ToString()
  $newContext | Add-Member -MemberType ScriptMethod -Name ToString -Force -Value {
    $contextString = 'mise'
    if ($null -ne $this.Project) {
      $contextString += ": $($this.Project)"
      if ($null -ne $this.Env) {
        $contextString += " $($this.Env)"
        if ($null -ne $this.Service) {
          $contextString += " $($this.Service)"
        }
      }
    }
    $contextString
  }

  return $newContext
}

function Get-MiseContext {
  $script:MiseContext
}

function Set-MiseContext {
  $script:MiseContext = $args[0]
}

function Update-MiseContext {
  [CmdletBinding()]
  Param(
    [Parameter(
      Mandatory=$true,
      ParameterSetName='Project'
    )]
    [string]$Project,

    [Parameter(
      Mandatory=$true,
      ParameterSetName='Env'
    )]
    [string]$Env,

    [Parameter(
      Mandatory=$true,
      ParameterSetName='Service'
    )]
    [string]$Service,

    [Parameter(
      Mandatory=$true,
      ValueFromPipeline
    )]
    [psobject]$Context
  )

  switch ($PSCmdlet.ParameterSetName) {
    'Project' {
      break
    }
    'Env' {
      break
    }
    'Service' {
      break
    }
  }
}

function Reset-MiseContext {
  [CmdletBinding()]
  Param(
    [Parameter(
      Mandatory=$true,
      ValueFromPipeline
    )]
    [psobject]$Context
  )

  $Context.Project = $null
  $Context.Env = $null
  $Context.Service = $null
}
