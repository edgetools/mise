# constants
# ======================================================================================================================

Set-Variable -Option Constant -Name SOURCE_BIN_PATH -Value (Join-Path $PSScriptRoot 'bin' 'mise')
Set-Variable -Option Constant -Name INSTALL_PATH -Value '/usr/local/bin/mise'

# functions
# ======================================================================================================================

function Install-MiseCli {
  [bool]$shouldDeleteExisting = $false
  [bool]$shouldCreateNew = $false
  # check for existing file
  if (Test-Path -LiteralPath $INSTALL_PATH -PathType Leaf) {
    # check if file is a symlink
    $existingFile = Get-Item -LiteralPath $INSTALL_PATH
    if (($existingFile.LinkType -cne 'SymbolicLink') `
        -or ($existingFile.Target -cne $SOURCE_BIN_PATH)) {
      # if not a symlink, or if symlink not pointing to the correct path
      # delete and recreate
      $shouldDeleteExisting = $true
      $shouldCreateNew = $true
    }
  } else {
    $shouldCreateNew = $true
  }
  # remove if needed
  if ($shouldDeleteExisting -eq $true) {
    Remove-Item -LiteralPath $INSTALL_PATH -ErrorAction Stop
  }
  # create symlink
  if ($shouldCreateNew -eq $true) {
    New-Item -Path $INSTALL_PATH -ItemType SymbolicLink -Value $SOURCE_BIN_PATH -ErrorAction Stop
  }
}

function Uninstall-MiseCli {
  Remove-Item -LiteralPath $INSTALL_PATH
}

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
    Write-Host -NoNewline " [`e[33m$(Get-MiseContext)`e[0m]"
    return '> '
  }
}

function Get-MiseVersion {
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
  $version_string = "v$(Get-MiseVersion)"
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

function Enter-MiseShell {
  if ($Global:MiseLoaded -ne $true) {
    Set-Alias -Name 'get' -Value Invoke-MiseGetCommand -Scope Global
    Set-Alias -Name 'en' -Value Invoke-MiseEnCommand -Scope Global
    $Global:PSDefaultParameterValues["Invoke-MiseEnCommand:Context"]=(Get-MiseContext)
    Update-Prompt
    $Global:MiseLoaded = $true
  }
  Write-Host (Format-Header)
}

function Invoke-MiseCli {
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
    [switch]$help,

    [Parameter(
      Mandatory=$true,
      Position=0,
      ParameterSetName='Get'
    )]
    [switch]$get,

    [Parameter(
      Mandatory=$true,
      Position=0,
      ParameterSetName='En'
    )]
    [switch]$en,

    [Parameter(
      Mandatory=$false,
      Position=1,
      ValueFromRemainingArguments
    )]
    $Remainder
  )

  switch ($PSCmdlet.ParameterSetName) {
    'Version' {
      (Get-MiseVersion).ToString()
    }
    'Help' {
      Get-Help Invoke-MiseCli
    }
    'Get' {}
    'En' {
      if ($null -eq $Remainder) {
        Invoke-MiseEnCommand
      } else {
        Invoke-MiseEnCommand @Remainder
      }
    }
  }
}

# main
# ======================================================================================================================

try {
  Set-Alias -Name 'mise' -Value Invoke-MiseCli

  Import-MiseConfigFile (Join-Path $PWD '.mise.json')

  Set-MiseContext (New-MiseContext)
} catch {
  throw $_
}
