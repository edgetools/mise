# main
# ======================================================================================================================

Import-Module (Join-Path $PSScriptRoot 'lib' 'docker-compose')

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

 type 'exit' to exit

"@
}

function Invoke-Cli {
  [CmdletBinding()]
  Param(
    [Parameter(
      Position=0,
      Mandatory=$true,
      HelpMessage='enter a service command'
    )]
    [ValidateSet(
      'foo',
      'help',
      'shell',
      'version'
    )]
    [string]$CommandName
  )

  switch ($CommandName) {
    'shell' {
      Update-Prompt
      Write-Host (Format-Header)
    }
    'help' {
      Get-Help $MyInvocation.MyCommand.Module.Name
    }
    'version' {
      Write-Host (Get-Version)
    }
    Default {
      Write-Host "TODO: Help Text"
    }
  }
}
