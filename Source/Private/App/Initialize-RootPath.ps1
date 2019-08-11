function Initialize-RootPath ([string]$ConfigurationName, [string]$Path) {
    $Script:AppConfig.AppPath = Get-RootPath -Path $Path
    Write-Verbose -Message ([HelperLog]::FormatLogMessage("Setting Script:AppConfig.AppPath to [$($Script:AppConfig.AppPath)]"))

    New-Item -Path $Script:AppConfig.AppPath -ItemType Directory -Force | Out-Null
    if (-not (Test-Path -Path $Script:AppConfig.AppPath)) {
        throw "Unable to access app path [$($Script:AppConfig.AppPath)]"
    }

    $configPath = Join-Path -Path $Script:AppConfig.AppPath -ChildPath "$ConfigurationName/config"
    New-Item -Path $configPath -ItemType Directory -Force | Out-Null
    if (-not (Test-Path -Path $configPath)) {
        throw "Unable to access config path [$configPath]"
    }

    $logPath = Join-Path -Path $Script:AppConfig.AppPath -ChildPath "$ConfigurationName/log"
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
    if (-not (Test-Path -Path $logPath)) {
        throw "Unable to access log path [$logPath]"
    }

    $dataPath = Join-Path -Path $Script:AppConfig.AppPath -ChildPath "$ConfigurationName/data"
    New-Item -Path $dataPath -ItemType Directory -Force | Out-Null
    if (-not (Test-Path -Path $dataPath)) {
        throw "Unable to access data path [$dataPath]"
    }
}
