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

function Enter-MiseShell {
  if ($Global:MiseLoaded -ne $true) {
    Set-Alias -Name 'en' -Value Invoke-MiseEnCommand -Scope Global
    Set-Alias -Name 'get' -Value Invoke-MiseGetCommand -Scope Global
    Set-Alias -Name 'version' -Value Invoke-MiseVersionCommand -Scope Global
    Update-Prompt
    $Global:MiseLoaded = $true
  }
  Write-Host (Format-Header)
}
