# environment
# ======================================================================================================================

# Set-PSDebug -Trace 2

Set-Variable -Option Constant -Name INSTALL_PATH -Value '/usr/local/bin/mise'
Set-Variable -Option Constant -Name SOURCE_BIN_PATH -Value "${PWD}/bin/mise"
Set-Variable -Option Constant -Name SOURCE_MODULE_PATH -Value "${PWD}/mise"

# functions
# ======================================================================================================================
function Get-ScriptFiles {
  $scriptFiles = [System.Collections.Generic.List[System.Object]]::new()
  # get .ps1 scripts but ignore test files
  $scriptFiles.AddRange(@(Get-ChildItem -LiteralPath $PWD -Recurse -File -Filter '*.ps1' -Exclude '*.tests.ps1'))
  # get .psm1 module files
  $scriptFiles.AddRange(@(Get-ChildItem -LiteralPath $PWD -Recurse -File -Filter '*.psm1'))
  return $scriptFiles
}

function Invoke-MakeTarget {
  switch ($args[0]) {
    # test
    'test' {
      Invoke-MakeTargets 'unit' 'systest'
    }
    # unit tests
    'unit' {
      if ((Invoke-Pester -CodeCoverage (Get-ScriptFiles) -Tag 'unit' -PassThru).FailedCount -gt 0) {
        throw "tests failed"
      }
    }
    # system tests
    'systest' {
      if ((Invoke-Pester -Tag 'system' -PassThru).FailedCount -gt 0) {
        throw "tests failed"
      }
    }
    # install
    'install' {
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
    # uninstall
    'uninstall' {
      # remove the symlink
      Remove-Item -LiteralPath $INSTALL_PATH
    }
    # load
    'load' {
      Import-Module $SOURCE_MODULE_PATH -Force -Verbose
      Set-Alias -Name 'mise' -Value 'Invoke-MiseCli' -Verbose -Scope Global
    }
    # unload
    'unload' {
      Remove-Module -Name 'mise' -Verbose
      Remove-Alias -Name 'mise' -Verbose
    }
  }
}

function Invoke-MakeTargets {
  [bool]$invocation_results = @()
  try {
    # invoke each make target
    foreach ($target in $args) {
      Invoke-MakeTarget $target
      $invocation_results += $?
    }
    # check if any of the targets failed
    if ($invocation_results -contains $false) {
      exit 64
    }
  }
  catch {
    Write-Error $_
    exit 64
  }
}

# main
# ======================================================================================================================

# make targets dispatch
if ($args.Count -eq 0) {
  Invoke-MakeTargets $DEFAULT_TARGETS
} else {
  Invoke-MakeTargets $args
}
