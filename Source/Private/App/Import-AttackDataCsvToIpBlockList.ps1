function Import-AttackDataCsvToIpBlockList ([Collections.ArrayList]$IpBlockList) {
    # Import attack IPs from the past few days.
    for ($currentDay = 0; $currentDay -le $Script:AppConfig.Config.DaysToBlockIp; $currentDay++) {
        $indicatorReportTimeFileFormat = Get-Date -Format $Script:AppConfig.Config.AttackerDataFileNameDateFormat -Date (Get-Date).AddDays(-1 * $currentDay)
        $currentDayCsvFilePath         = Join-Path -Path $Script:AppConfig.Config.AttackerDataPath -ChildPath ([string]::Format($Script:AppConfig.Config.AttackerDataFileNameFormat, $indicatorReportTimeFileFormat))

        if (Test-Path -Path $currentDayCsvFilePath) {
            Convert-CsvColumnToArrayList -ArrayList $IpBlockList -FilePath $currentDayCsvFilePath -ColumnName 'indicator'
        }
    }

    # Import manual ban IP list.
    if (Test-Path -Path $Script:AppConfig.Config.ManualIpBlockListFilePath) {
        Convert-CsvColumnToArrayList -ArrayList $IpBlockList -FilePath $Script:AppConfig.Config.ManualIpBlockListFilePath -ColumnName 'indicator'
    }
}
