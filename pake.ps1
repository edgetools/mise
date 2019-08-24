#Requires -Version 6.2

# environment
# ======================================================================================================================

# Set-PSDebug -Trace 2

Set-Variable -Option Constant -Name INSTALL_PATH -Value '/usr/local/bin/mise'
Set-Variable -Option Constant -Name SOURCE_BIN_PATH -Value (Join-Path $PSScriptRoot 'bin' 'mise')
Set-Variable -Option Constant -Name SOURCE_MODULE_PATH -Value (Join-Path $PSScriptRoot 'mise')
Set-Variable -Option Constant -Name VERSION_FILE_PATH -Value (Join-Path $PSScriptRoot '.VERSION')
Set-Variable -Option Constant -Name PRERELEASE_FILE_PATH -Value (Join-Path $PSScriptRoot '.PRERELEASE')
Set-Variable -Option Constant -Name CHANGELOG_FILE_PATH -Value (Join-Path $PSScriptRoot 'CHANGELOG')

# functions
# ======================================================================================================================
function Get-FilesForTestCoverage {
  $scriptFiles = [System.Collections.Generic.List[System.Object]]::new()
  # get .ps1 scripts but ignore test and pake files
  $scriptFiles.AddRange(
    @(Get-ChildItem -LiteralPath $PWD -Recurse -File -Filter '*.ps1' -Exclude '*.tests.ps1','pake.ps1'))
  # get .psm1 module files
  $scriptFiles.AddRange(@(Get-ChildItem -LiteralPath $PWD -Recurse -File -Filter '*.psm1'))
  return $scriptFiles
}

function Update-ModuleManifestForRelease {
  # initial args
  $manifest_args = @{
    AliasesToExport = 'mise'
    CmdletsToExport = @()
    FunctionsToExport = @(
      'Enter-MiseShell',
      'Get-MiseVersion',
      'Invoke-MiseCli'
    )
    Path = (Join-Path $SOURCE_MODULE_PATH 'mise.psd1')
  }

  # get version file
  if (Test-Path -LiteralPath $VERSION_FILE_PATH) {
    $manifest_args['ModuleVersion'] = Get-Content -LiteralPath $VERSION_FILE_PATH -ErrorAction Stop
    # get prerelease file, if present
    if (Test-Path -LiteralPath $PRERELEASE_FILE_PATH) {
      $prerelease = Get-Content -LiteralPath $PRERELEASE_FILE_PATH -ErrorAction Stop
      $prerelease += ${env:TRAVIS_BUILD_NUMBER}
      $manifest_args['Prerelease'] = $prerelease
    } else {
      # as of the time this line was written
      # setting to single space ' ' will remove the prerelease in PSData, if present
      # using just '' or $none, will not
      $manifest_args['Prerelease'] = ' '
    }
  } else {
    throw [System.IO.FileNotFoundException] "$VERSION_FILE_PATH not found."
  }

  # get changelog
  if (Test-Path -LiteralPath $CHANGELOG_FILE_PATH) {
    $manifest_args['ReleaseNotes'] = Get-Content -LiteralPath $CHANGELOG_FILE_PATH -ErrorAction Stop
  } else {
    throw [System.IO.FileNotFoundException] "$CHANGELOG_FILE_PATH not found."
  }

  Update-ModuleManifest @manifest_args -ErrorAction Stop
}

function Install-DevDependencies {
  $devDependencies = @(
    'Pester'
  )
  Write-Host "checking dependencies ..."
  foreach ($devDependency in $devDependencies) {
    # list all available modules
    # to see if the target is already installed
    if (Get-Module -ListAvailable -Name $devDependency) {
      Write-Host " - '$devDependency' found"
    } else {
      Write-Host " - '$devDependency' installing ..."
      # disable the progress bar while installing
      $_progressPreference = $ProgressPreference
      $Global:ProgressPreference = 'SilentlyContinue'
      Install-Module -Name $devDependency -AcceptLicense -Force -Verbose -ErrorAction Stop
      $Global:ProgressPreference = $_progressPreference
    }
  }
  Write-Host "done"
}

function Invoke-MakeTarget {
  switch ($args[0]) {
    # test
    'test' {
      Invoke-MakeTargets 'unit' 'systest'
    }
    # unit tests
    'unit' {
      if ((Invoke-Pester -CodeCoverage (Get-FilesForTestCoverage) -Tag 'unit' -PassThru).FailedCount -gt 0) {
        throw "unit tests failed"
      }
    }
    # system tests
    'systest' {
      if ((Invoke-Pester -Tag 'system' -PassThru).FailedCount -gt 0) {
        throw "system tests failed"
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
      Import-Module $SOURCE_MODULE_PATH -Force -Verbose -ErrorAction Stop
    }
    # unload
    'unload' {
      Remove-Module -Name 'mise' -Verbose -ErrorAction Stop
    }
    # dep
    'dep' {
      Install-DevDependencies
    }
    # prepare-release
    'prepare-release' {
      Update-ModuleManifestForRelease
    }
    # publish-release
    'publish-release' {
      Write-Host 'Publishing Release...'
      Publish-Module `
        -ErrorAction Stop `
        -Force `
        -NuGetApiKey ${env:NUGET_API_KEY} `
        -Path $SOURCE_MODULE_PATH
      Write-Host -ForegroundColor Green 'Release Published!'
    }
    # push-release-tag
    'push-release-tag' {
      Invoke-MakeTarget 'load'
      $env:GIT_TAG = Invoke-MiseCli -Version -ErrorAction Stop
      Invoke-MakeTarget 'unload'
      Write-Host "Pushing Release Tag $env:GIT_TAG ..."
      & /usr/bin/env bash -c `
@'
      set -e
      test -n "${GIT_TAG}"
      test -n "${GIT_DEPLOY_KEY}"
      eval "$(ssh-agent -s)"
      echo "${GIT_DEPLOY_KEY}" > /tmp/deploy_rsa
      chmod 0600 /tmp/deploy_rsa
      ssh-add /tmp/deploy_rsa
      export GIT_COMMITTER_NAME='Travis CI'
      export GIT_COMMITTER_EMAIL='builds@travis-ci.com'
      git tag "${GIT_TAG}" -a -m "mise v${GIT_TAG}"
      git push origin "${GIT_TAG}"
      rm /tmp/deploy_rsa
'@
      if ($LASTEXITCODE -ne 0) {
        throw 'script exited with non-zero exit code'
      }
      Write-Host -ForegroundColor Green 'Release Tag Pushed!'
    }
  }
}

function Invoke-MakeTargets {
  try {
    [bool]$invocation_results = @()
    # invoke each make target
    foreach ($target in $args) {
      Invoke-MakeTarget $target
      $invocation_results += $?
    }
    # check if any of the targets failed
    if ($invocation_results -contains $false) {
      throw 'make target failed'
    }
  }
  catch {
    throw $_
  }
}

# main
# ======================================================================================================================

# make targets dispatch

try {
  Invoke-MakeTargets @args
} catch {
  throw $_
}
