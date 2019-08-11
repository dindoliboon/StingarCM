function Export-IpBlockListToMultipleFiles ([Collections.ArrayList]$IpBlockList) {
    $blockListFileIndex = 0

    for ($ipBlockListIndex = 0; $ipBlockListIndex -lt $IpBlockList.Count; $ipBlockListIndex++) {
        if ($ipBlockListIndex % $Script:AppConfig.Config.MaxIpPerBlockList -eq 0) {
            $blockListFileIndex = $blockListFileIndex + 1
            $blockListFilePath  = Join-Path -Path $Script:AppConfig.Config.BlockListPath -ChildPath ([string]::Format($Script:AppConfig.Config.BlockListFileNameFormat, $blockListFileIndex))

            Write-Verbose -Message ([HelperLog]::FormatLogMessage("Creating multiple external block list file: $blockListFilePath"))
            $IpBlockList[$ipBlockListIndex] | Out-File -FilePath $blockListFilePath -Encoding ascii
        } else {
            $IpBlockList[$ipBlockListIndex] | Out-File -FilePath $blockListFilePath -Encoding ascii -Append
        }
    }
}
