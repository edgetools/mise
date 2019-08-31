# user -> ~/.config/ or $env:XDG_CONFIG_HOME
# roaming -> ~/.local/share/ or $env:XDG_DATA_HOME
# machine -> /etc/xdg/ or $env:sysconfdir/xdg/ (subdir/filename)
# cache -> ~/.cache/ or $env:XDG_CACHE_HOME

# variables
# ======================================================================================================================

New-Variable -Name MiseConfig -Value @{}

# functions
# ======================================================================================================================

function Get-MiseConfig {
  $script:MiseConfig
}

function Import-MiseConfigFile {
  if (Test-Path $args[0]) {
    $script:MiseConfig = Get-Content -LiteralPath $args[0] | ConvertFrom-Json -AsHashtable
  }
}
