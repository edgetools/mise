# variables
# ======================================================================================================================

New-Variable -Scope Script -Name MiseContext -Value $null

# enum
# ======================================================================================================================

enum MiseContextLevel {
  Global
  Project
  Env
  Service
}

# functions
# ======================================================================================================================

# function New-MiseContext {
#   $newContext = [PSCustomObject]@{
#     Project = $null
#     Env = $null
#     Service = $null
#   }

#   # override .ToString()
#   $newContext | Add-Member -MemberType ScriptMethod -Name ToString -Force -Value {
#     $contextString = 'mise'
#     if ($null -ne $this.Project) {
#       $contextString += ": $($this.Project)"
#       if ($null -ne $this.Env) {
#         $contextString += " $($this.Env)"
#         if ($null -ne $this.Service) {
#           $contextString += " $($this.Service)"
#         }
#       }
#     }
#     $contextString
#   }

#   return $newContext
# }

function New-MiseContext {
  [CmdletBinding()]
  Param(
    [Parameter(
      Mandatory=$false,
      ValueFromPipeline
    )]
    [psobject]$Location = (New-MiseContextLocation)
  )
  $newContext = [PSCustomObject]@{
    Location = $Location
  }
  # .ToString() -> mise: foo bar baz
  $newContext | Add-Member -MemberType ScriptMethod -Force -Name ToString -Value {
    if ([string]::IsNullOrEmpty($this.Location.Name)) {
      'mise'
    } else {
      "mise: $($this.Location.Name)"
    }
  }
  return $newContext
}

function New-MiseContextLocation {
  Param(
    [string]$Name = $null,
    [MiseContextLevel]$Level = ([MiseContextLevel]::Global),
    [psobject]$Parent = $null
  )

  $newContextLocation = [PSCustomObject]@{
    Name = $Name
    Level = $Level
    Parent = $Parent
  }

  $newContextLocation | Add-Member -MemberType ScriptProperty -Name Children -Value {
    switch ($this.Level) {
      ([MiseContextLevel]::Global) {
        (Get-MiseConfig).Projects.Keys | ForEach-Object {
          New-MiseContextLocation `
            -Name $_ `
            -Level ([MiseContextLevel]::Project) `
            -Parent $this
        }
        break
      }
    }
  }

  return $newContextLocation
}

function Get-MiseContext {
  $script:MiseContext
}

function Set-MiseContext {
  [CmdletBinding()]
  Param(
    [Parameter(
      Mandatory=$true,
      ValueFromPipeline
    )]
    [psobject]$Context
  )
  $script:MiseContext = $Context
}

function Move-MiseContextLocation {
  [CmdletBinding()]
  Param(
    [Parameter(
      Mandatory=$true,
      ValueFromPipeline
    )]
    [string]$Target,

    [Parameter(
      Mandatory=$true,
      ValueFromPipeline
    )]
    [psobject]$Context
  )

  # move up for '..'
  if ($Target -ceq '..') {
    if ($null -ne $Context.Location.Parent) {
      $Context.Location = $Context.Location.Parent
    }
    return
  }

  # get children
  $children = $Context | Get-MiseContextChildren
  # throw if not a valid child
  if (($null -eq $children) -or (-not ($Context | Get-MiseContextChildren).Contains($Target))) {
    throw "$Target is not a valid target"
  }

  # get a level deeper
  switch ($Context.Location.Level) {
    ([MiseContextLevel]::Global) {
      $nextLevel = [MiseContextLevel]::Project
      break
    }
    ([MiseContextLevel]::Project) {
      $nextLevel = [MiseContextLevel]::Env
      break
    }
    ([MiseContextLevel]::Env) {
      $nextLevel = [MiseContextLevel]::Service
      break
    }
    ([MiseContextLevel]::Service) {
      throw "cannot go deeper than service level"
    }
  }

  # move context location to child
  $Context.Location = New-MiseContextLocation `
    -Name $Target `
    -Level $nextLevel `
    -Parent $Context.Location
}

function Get-MiseContextChildren {
  [CmdletBinding()]
  Param(
    [Parameter(
      Mandatory=$true,
      ValueFromPipeline
    )]
    [psobject]$Context
  )

  switch ($Context.Location.Level) {
    ([MiseContextLevel]::Global) {
      (Get-MiseConfig).Projects.Keys
      break
    }
  }
}

# function Set-MiseContextLocation {
#   [CmdletBinding()]
#   Param(
#     [Parameter(
#       Mandatory=$true,
#       ParameterSetName='Child'
#     )]
#     [string]$Child,

#     [Parameter(
#       Mandatory=$true,
#       ParameterSetName='Parent'
#     )]
#     [string]$Parent,

#     [Parameter(
#       Mandatory=$true,
#       ValueFromPipeline
#     )]
#     [psobject]$Context
#   )

#   $Context
# }

# function Update-MiseContext {
#   [CmdletBinding()]
#   Param(
#     [Parameter(
#       Mandatory=$true,
#       ParameterSetName='Project'
#     )]
#     [string]$Project,

#     [Parameter(
#       Mandatory=$true,
#       ParameterSetName='Env'
#     )]
#     [string]$Env,

#     [Parameter(
#       Mandatory=$true,
#       ParameterSetName='Service'
#     )]
#     [string]$Service,

#     [Parameter(
#       Mandatory=$true,
#       ValueFromPipeline
#     )]
#     [psobject]$Context
#   )

#   switch ($PSCmdlet.ParameterSetName) {
#     'Project' {
#       break
#     }
#     'Env' {
#       break
#     }
#     'Service' {
#       break
#     }
#   }
# }

# function Reset-MiseContext {
#   [CmdletBinding()]
#   Param(
#     [Parameter(
#       Mandatory=$true,
#       ValueFromPipeline
#     )]
#     [psobject]$Context
#   )

#   $Context.Name = $null
#   $Context.Level = [MiseContextLevel]::Global
#   $Context.Parent = $null
#   $Context.Child = $null
# }
