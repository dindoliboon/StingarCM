function Invoke-NewBlockList {

    <#
    .SYNOPSIS
        Export attacker IP to a TXT file.

    .DESCRIPTION
        Using data collected by Invoke-ExportAttackData, this will export just
        the attacker IP address based on the config DaysToBlockIp to a text file.

        The generated text file can then be imported directly or served to your
        firewall if it supports external block lists.

    .PARAMETER Confirm
        Prompts you for confirmation before running the cmdlet.

    .PARAMETER WhatIf
        Shows what would happen if Invoke-NewBlockList runs. The cmdlet isn't run.

    .EXAMPLE
        Invoke-NewBlockList -ConfigurationName 'contoso'

        Create block list text files containing IP addresses using attacker
        data collected by Invoke-ExportAttackData. Settings will be associated
        with the configuration contoso.
    #>

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
        if ($pscmdlet.ShouldProcess('Export attacker IP only and apply safe list')) {
            try {
                Initialize-Configuration -ConfigurationName $ConfigurationName -Path $Path

                $ipToBlock = [Collections.ArrayList] @()
                Import-AttackDataCsvToIpBlockList -IpBlockList $ipToBlock

                $filteredIpToBlock = Optimize-IpBlockList -IpBlockList $ipToBlock

                Clear-IpBlockListFiles

                Export-IpBlockListFiles -IpBlockList $filteredIpToBlock
            } catch {
                Write-Error -Message ([HelperLog]::FormatLogMessage(($_ | Out-String)))
            }
        }
    }
}
