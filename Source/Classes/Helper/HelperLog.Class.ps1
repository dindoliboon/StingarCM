class HelperLog {
    HelperLog() {
    }

    static [string] FormatLogMessage([string]$Message) {
        $timestampRoundTrip = Get-Date -Format 'o'
        $callerName         = (Get-PSCallStack)[1].Command

        return "$timestampRoundTrip [$callerName] $Message"
    }
}
