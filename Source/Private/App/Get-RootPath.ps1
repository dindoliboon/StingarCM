function Get-RootPath ([string]$Path) {
    if ([string]::IsNullOrEmpty($Path)) {
        $Path = Get-EnvHome
    }

    if ([string]::IsNullOrEmpty($Path)) {
        $Path = $Env:HOMEDRIVE + $Env:HOMEPATH
    }

    if ([string]::IsNullOrEmpty($Path)) {
        $Path = $Env:USERPROFILE
    }

    if ([string]::IsNullOrEmpty($Path)) {
        throw 'The Path parameter should be set to a valid home path. By default, the environment variable $Env:HOME is used, then $Env:HOMEDRIVE + $Env:HOMEPATH, and finally $Env:USERPROFILE.'
    }

    Join-Path -Path $Path -ChildPath '.stingarcm'
}
