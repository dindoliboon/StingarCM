function Get-ConfigurationFilePath ([string]$ConfigurationName) {
    Join-Path -Path $Script:AppConfig.AppPath -ChildPath "$ConfigurationName/config/config.json"
}
