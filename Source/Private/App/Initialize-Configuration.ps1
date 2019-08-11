function Initialize-Configuration ([string]$ConfigurationName, [string]$Path) {
    $Script:AppConfig = @{
        Config               = @{}
        CifApiTokenPlainText = ''
        AppPath              = ''
    }

    Initialize-RootPath -ConfigurationName $ConfigurationName -Path $Path

    $Script:AppConfig.Config = Get-Configuration -ConfigurationName $ConfigurationName

    $Script:AppConfig.CifApiTokenPlainText = (New-Object -TypeName System.Net.NetworkCredential('', (ConvertTo-SecureString -String $Script:AppConfig.Config.CifApiToken))).Password
}
