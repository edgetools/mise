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
  $version = [System.Management.Automation.SemanticVersion]::new(
    $MyInvocation.MyCommand.Module.Version.Major,
    $MyInvocation.MyCommand.Module.Version.Minor,
    $MyInvocation.MyCommand.Module.Version.Build,
    $MyInvocation.MyCommand.Module.PrivateData.PSData.Prerelease
  )
  return $version
}

function Format-Header {
  # place the version string in the exact
  # middle of the logo
  $version_line = '                            '
  $version_string = "v$(Get-Version)"
  $trim_length = $version_string.Length / 2
  $version_line = $version_line.Remove($version_line.Length - $trim_length - 1, $trim_length)
  $version_line += $version_string
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

$version_line

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
      (Get-Version).ToString()
    }
    'Help' {
      Get-Help Invoke-MiseCli
    }
  }
}
Set-Alias -Name 'mise' -Value Invoke-MiseCli -Scope Global
