function Invoke-ExportAttackData {

    <#
    .SYNOPSIS
        Export recent attack data to one or more CSV files.

    .DESCRIPTION
        Connects to a CIF server to save recent attack data to one or more CSV
        files using settings stored in a configuration file.

    .PARAMETER Confirm
        Prompts you for confirmation before running the cmdlet.

    .PARAMETER WhatIf
        Shows what would happen if Invoke-ExportAttackData runs. The cmdlet isn't run.

    .EXAMPLE
        Invoke-ExportAttackData -ConfigurationName 'contoso'

        This will export attacker data to CSV files using the config associated
        with contoso. File names are based on the date an attack occurred, such
        as: cif-attack-data-20190131.csv.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([string])]
    param (
        # A short name to identify your configuration. Used in file and path names.
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]
        $ConfigurationName,

        # The root path that will contain .stingarcm configuration and data files.
        [Parameter()]
        [string]
        $Path
    )

    begin {
        if ($ConfigurationName -cnotmatch '^[A-Za-z0-9\-_]+$') {
            throw 'ConfigurationName can only contain the following characters: A-Z, a-z, 0-9, -, _'
        }
    }

    process {
        if ($pscmdlet.ShouldProcess('CIF server', 'Export attacker IP data')) {
            try {
                Initialize-Configuration -ConfigurationName $ConfigurationName -Path $Path

                Connect-CifService -ApiUri $Script:AppConfig.Config.CifApiUri -ApiToken $Script:AppConfig.CifApiTokenPlainText

                Export-RawAttackDataToCsv -Path $Script:AppConfig.Config.AttackerDataPath -AttackAgeInDays $Script:AppConfig.Config.DaysToBlockIp -MaxIndicatorReturnSize $Script:AppConfig.Config.MaxIndicatorReturnSize -LastAttackerDataFetchTimestamp $Script:AppConfig.Config.LastAttackerDataFetchTimestamp -Append $true

                Export-Configuration
            } catch {
                Write-Error -Message ([HelperLog]::FormatLogMessage(($_ | Out-String)))
            }
        }
    }
}
