
# joins a path using '/'
# trims any excess in the separator
# foo// /bar baz/
# -> foo/bar/baz/
function Join-UriPath {
  foreach ($arg in $args) {
    if ([string]::IsNullOrEmpty($path)) {
      [string]$path = $arg.ToString()
    } else {
      $path = $path.TrimEnd('/') + '/' + $arg.ToString().TrimStart('/')
    }
  }
  return $path
}
