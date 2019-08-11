function Read-HostForce ([string]$Prompt, [string]$Default, [string]$ValidatePattern) {
    do {
        $userProvidedAnswer = Read-Host -Prompt "$Prompt [$Default]"

        if ([string]::IsNullOrEmpty($userProvidedAnswer)) {
            $userProvidedAnswer = $Default
        }
    } while ($userProvidedAnswer -inotmatch $ValidatePattern)

    $userProvidedAnswer
}
