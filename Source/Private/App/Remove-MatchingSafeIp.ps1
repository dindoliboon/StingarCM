function Remove-MatchingSafeIp {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([string])]
    Param (
        # An IP to perform matching against.
        [Parameter(ValueFromPipeline = $true)]
        [string]$Data,

        # A collection of strings that should be removed from Data if found.
        [Parameter()]
        [string[]]$SafeIp
    )

    process {
        if ($pscmdlet.ShouldProcess('Pipeline', 'Remove IP')) {
            $ipToCheck = $Data.Trim()

            $SafeIp | ForEach-Object {
                if (($Data -imatch $_)) {
                    Write-Verbose -Message ([HelperLog]::FormatLogMessage("Excluding $ipToCheck, matches safe list $_"))
                    break
                }
            }

            $ipToCheck
        }
    }
}
