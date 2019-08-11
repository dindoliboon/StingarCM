function Export-Configuration {
    $jsonConfig = $Script:AppConfig.Config | ConvertTo-Json
    $jsonConfig | Out-File -FilePath (Get-ConfigurationFilePath -ConfigurationName $Script:AppConfig.Config.ConfigurationName)
}
