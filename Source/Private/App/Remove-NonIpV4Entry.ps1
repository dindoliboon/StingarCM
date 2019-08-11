function Remove-NonIpV4Entry {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([string])]
    Param (
        # String to check IPv4 address format against.
        [Parameter(ValueFromPipeline = $true)]
        [string]$Data
    )
    Process {
        if ($pscmdlet.ShouldProcess('Pipeline', 'Remove IP')) {
            $ipToCheck = $Data.Trim()
            $isIpV4 = $ipToCheck -match '^\d+\.\d+\.\d+\.\d+$'

            if ($isIpV4 -and $Matches.Count -eq 1) {
                $ipToCheck
            } else {
                Write-Verbose -Message ([HelperLog]::FormatLogMessage("Excluding $ipToCheck, not IPv4"))
            }
        }
    }
}
