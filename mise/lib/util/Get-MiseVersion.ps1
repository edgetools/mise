function Get-MiseVersion {
  $version = [System.Management.Automation.SemanticVersion]::new(
    $MyInvocation.MyCommand.Module.Version.Major,
    $MyInvocation.MyCommand.Module.Version.Minor,
    $MyInvocation.MyCommand.Module.Version.Build,
    $MyInvocation.MyCommand.Module.PrivateData.PSData.Prerelease
  )
  return $version
}
