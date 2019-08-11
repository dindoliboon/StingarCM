function Optimize-IpBlockList ([Collections.ArrayList]$IpBlockList) {
    # Indicators and type from honeypots can be incorrect, so remove non-IPv4 addresses
    # and remove anything matching our safe lists.
    Write-Verbose -Message ([HelperLog]::FormatLogMessage('Filter out non-IPv4 or safe-list IPs'))
    $IpBlockList |
        Remove-NonIpV4Entry | Remove-MatchingSafeIp -SafeIp $Script:AppConfig.Config.SafeIpList |
            Sort-Object
}
