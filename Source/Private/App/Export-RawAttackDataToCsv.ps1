function Export-RawAttackDataToCsv {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
    [CmdletBinding()]
    param (
        [string]$Path,
        [Int32]$MaxIndicatorReturnSize,
        [Int32]$AttackAgeInDays,
        [bool]$Append=$false,
        [string]$LastAttackerDataFetchTimestamp
    )

    process {
        # Determine how old the attack data should be.
        $reportTimeRange = (Get-Date).AddDays(-1 * $AttackAgeInDays).ToUniversalTime()

        if ([string]::IsNullOrEmpty($LastAttackerDataFetchTimestamp) -eq $false) {
            $reportTimeRange = $LastAttackerDataFetchTimestamp
        }

        $reportTime = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ' -Date $reportTimeRange
        Write-Verbose -Message ([HelperLog]::FormatLogMessage("Get attacks from $reportTime"))
        $indicatorRaw = Get-CifIndicator -limit $MaxIndicatorReturnSize -reporttime $reportTime
        if ($null -ne $indicatorRaw -and $null -ne $indicatorRaw.Data -and $null -ne $indicatorRaw.Data.Count -and $indicatorRaw.Data.Count -gt 0) {
            # Determine the oldest attack and how many days have passed.
            $indicatorSortByOldest = $indicatorRaw.Data | Sort-Object -Property reporttime
            $oldestIndicator = $indicatorSortByOldest | Select-Object -First 1 -ExpandProperty reporttime
            $newestIndicator = $indicatorSortByOldest | Select-Object -Last 1 -ExpandProperty reporttime
            $firstAttackAgeInDays = [Math]::Ceiling(((Get-Date) - (Get-Date -Date $oldestIndicator)).TotalDays)

            # Build columns to convert everything to joined strings otherwise
            # output will list arrays as Object[] instead of actual data.
            $mergedColumnDataProperty = Merge-ColumnDataArrayToString -InputObject $indicatorSortByOldest[0]

            # Export all attack data based on the time it occurred.
            for ($dayIndex = 0; $dayIndex -le $firstAttackAgeInDays; $dayIndex++) {
                $currentIndicatorTimestamp = (Get-Date).AddDays(-1 * $dayIndex)
                $indicatorReportTime = Get-Date -Format 'yyyyMMdd' -Date $currentIndicatorTimestamp
                $indicatorReportTimeFileFormat = Get-Date -Format $Script:AppConfig.Config.AttackerDataFileNameDateFormat -Date $currentIndicatorTimestamp
                $csvFilePath         = Join-Path -Path $Path -ChildPath ([string]::Format($Script:AppConfig.Config.AttackerDataFileNameFormat, $indicatorReportTimeFileFormat))

                if (((Test-Path -Path $csvFilePath) -eq $false) -or $PSBoundParameters.ContainsKey('Force') -or $Append -eq $true) {
                    $currentIndicator = $indicatorSortByOldest | Where-Object { (Get-Date -Format 'yyyyMMdd' -Date $_.reporttime) -eq $indicatorReportTime }

                    if ($currentIndicator) {
                        $paramExport = @{
                            Path   = $csvFilePath
                            Append = $Append
                        }
                        $currentIndicator | Select-Object -Property $mergedColumnDataProperty | Export-Csv @paramExport
                        Write-Verbose -Message ([HelperLog]::FormatLogMessage("Export attacker IP data to CSV: $csvFilePath"))
                        Write-Verbose -Message ([HelperLog]::FormatLogMessage("Attacker IP count: $($currentIndicator.Count)"))

                        $Script:AppConfig.Config.LastAttackerDataFetchTimestamp = $newestIndicator
                    }
                }
            }
        }
    }
}
