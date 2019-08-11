function Export-IpBlockListToSingleFile ([Collections.ArrayList]$IpBlockList) {
    $blockListFilePath = Join-Path -Path $Script:AppConfig.Config.BlockListPath -ChildPath ([string]::Format($Script:AppConfig.Config.BlockListFileNameFormat, '1'))

    Write-Verbose -Message ([HelperLog]::FormatLogMessage("Creating single external block list file: $blockListFilePath"))

    $IpBlockList | Out-File -FilePath $blockListFilePath -Encoding ascii
}
