function Export-IpBlockListFiles ([Collections.ArrayList]$IpBlockList) {
    if ($null -eq $IpBlockList -or ($null -ne $IpBlockList -and $null -ne $IpBlockList.Count -and $IpBlockList.Count -eq 0)) {
        Write-Verbose -Message ([HelperLog]::FormatLogMessage('No attack IPs to import.'))
        return
    }

    Write-Verbose -Message ([HelperLog]::FormatLogMessage("IPs added: $($IpBlockList.Count)"))

    if ($IpBlockList.Count -le $Script:AppConfig.Config.MaxIpPerBlockList) {
        Export-IpBlockListToSingleFile -IpBlockList $IpBlockList
    } else {
        Export-IpBlockListToMultipleFiles -IpBlockList $IpBlockList
    }
}
