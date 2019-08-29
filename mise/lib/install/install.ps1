# constants
# ======================================================================================================================

Set-Variable -Option Constant -Name SOURCE_BIN_PATH -Value (Resolve-Path (Join-Path $PSScriptRoot '..' '..' 'bin' 'mise'))
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
  }
  else {
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
