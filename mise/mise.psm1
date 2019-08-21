# main
# ======================================================================================================================

# Import-Module (Join-Path $PSScriptRoot 'lib' 'docker-compose')

function Update-Prompt {
  function script:_original_prompt {}
  ${function:_original_prompt} = $function:prompt
  function global:prompt {
    [string]$prompt = (& $function:_original_prompt)
    if ($prompt.EndsWith('> ')) {
      Write-Host -NoNewline $prompt.TrimEnd('> ')
    } else {
      Write-Host -NoNewline $prompt
    }
    Write-Host -NoNewline " [`e[33mmise`e[0m]"
    return '> '
  }
}

function Get-Version {
  Write-Output $MyInvocation.MyCommand.Module.Version
}

function Format-Header {
@"

       ___                       ___           ___
      /__/\        ___          /  /\         /  /\
     |  |::\      /  /\        /  /:/_       /  /:/_
     |  |:|:\    /  /:/       /  /:/ /\     /  /:/ /\
   __|__|:|\:\  /__/::\      /  /:/ /::\   /  /:/ /:/_
  /__/::::| \:\ \__\/\:\__  /__/:/ /:/\:\ /__/:/ /:/ /\
  \  \:\~~\__\/    \  \:\/\ \  \:\/:/~/:/ \  \:\/:/ /:/
   \  \:\           \__\::/  \  \::/ /:/   \  \::/ /:/
    \  \:\          /__/:/    \__\/ /:/     \  \:\/:/
     \  \:\         \__\/       /__/:/       \  \::/
      \__\/                     \__\/         \__\/

                          v$(Get-Version)

   type 'exit' to quit

"@
}

function Enter-Shell {
  if ($Global:MiseLoaded -ne $true) {
    Update-Prompt
    $Global:MiseLoaded = $true
  }
  Write-Host (Format-Header)
}

function Invoke-Cli {
  [CmdletBinding()]
  Param(
    [Parameter(
      Mandatory=$true,
      Position=0,
      ParameterSetName='Version'
    )]
    [switch]$version,

    [Parameter(
      Mandatory=$true,
      Position=0,
      ParameterSetName='Help'
    )]
    [switch]$help
  )

  switch ($PSCmdlet.ParameterSetName) {
    'Version' {
      Write-Host (Get-Version)
    }
    'Help' {
      Get-Help Invoke-MiseCli
    }
  }
}
Set-Alias -Name 'mise' -Value Invoke-MiseCli -Scope Global
