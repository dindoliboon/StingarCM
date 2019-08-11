function Get-Configuration ([string]$ConfigurationName) {
    $configFilePath = Get-ConfigurationFilePath -ConfigurationName $ConfigurationName

    if (Test-Path -Path $configFilePath) {
        Write-Verbose -Message ([HelperLog]::FormatLogMessage("Read existing config file: $configFilePath"))

        Get-Content -Path $configFilePath -Raw | ConvertFrom-Json
    } else {
        Write-Verbose -Message ([HelperLog]::FormatLogMessage("Create new config: $ConfigurationName"))

        New-Configuration -ConfigurationName $ConfigurationName
    }
}
