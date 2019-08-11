function New-Configuration {
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param (
        [string]$ConfigurationName
    )

    process {
        if ($pscmdlet.ShouldProcess('Create new configuration file')) {
            $defaultAttackerDataPath        = Join-Path -Path $Script:AppConfig.AppPath -ChildPath "$ConfigurationName/data"
            $defaultBlockListPath           = Join-Path -Path $Script:AppConfig.AppPath -ChildPath "$ConfigurationName/blocklist"

            $cifApiUri                      = Read-HostForce -Prompt 'What is the CIFv3 URI?' -Default 'https://v3.cif.localhost' -ValidatePattern '^https?:\/\/.+$'
            $cifApiToken                    = Read-Host -Prompt 'What is your CIFv3 read-only token?' -AsSecureString
            $daysToBlockIp                  = Read-HostForce -Prompt 'How many days do you want to block an IP?' -Default '4' -ValidatePattern '^\d+$'
            $maxIndicatorReturnSize         = Read-HostForce -Prompt 'What is the maximum number of attacker IPs to fetch?' -Default '1000' -ValidatePattern '^\d+$'
            $safeIpList                     = (Read-Host -Prompt 'What IPv4 addresses should be on your safe list? (supports regex, separate by comma)').Split(',') | ForEach-Object { $_.Trim() }
            $manualIpBlockListFilePath       = Read-Host -Prompt 'Enter a file path that contains a CSV of IPs to block'
            $maxIpPerBlockList              = Read-HostForce -Prompt 'What is the maximum number of IPs each block list can hold?' -Default '39700' -ValidatePattern '^\d+$'
            $attackerDataFileNameDateFormat = Read-HostForce -Prompt 'What date format should the attack data CSV files use?' -Default 'yyyyMMdd' -ValidatePattern '.*'
            $attackerDataFileNameFormat     = Read-HostForce -Prompt 'What file name format should the attack data CSV files use?' -Default 'cif-attack-data-{0}.csv' -ValidatePattern '.*'
            $blockListFileNameFormat        = Read-HostForce -Prompt 'What file name format should the IP block list use?' -Default 'cif-attack-ip-blocklist-{0}.txt' -ValidatePattern '.*'

            do {
                $attackerDataPath = Read-HostForce -Prompt 'What folder should raw attack data be saved to?' -Default $defaultAttackerDataPath -ValidatePattern '.*'
                New-Item -Path $attackerDataPath -ItemType Directory -Force | Out-Null
            } while ((Test-Path -Path $attackerDataPath) -eq $false)

            do {
                $blockListPath = Read-HostForce -Prompt 'What folder should block lists be saved to?' -Default $defaultBlockListPath -ValidatePattern '.*'
                New-Item -Path $blockListPath -ItemType Directory -Force | Out-Null
            } while ((Test-Path -Path $blockListPath) -eq $false)

            # Create block list template if none was specified.
            if ((Test-Path -Path $manualIpBlockListFilePath) -eq $false) {
                $manualIpBlockListFilePath = Join-Path -Path $attackerDataPath -ChildPath 'manual-ip-blocklist.csv'
                'indicator' | Out-File -FilePath $manualIpBlockListFilePath -Encoding utf8 -Force -ErrorAction SilentlyContinue
            }

            $config = @{
                'ConfigurationName'              = $ConfigurationName
                'CifApiUri'                      = $cifApiUri
                'CifApiToken'                    = ConvertFrom-SecureString -SecureString $cifApiToken
                'DaysToBlockIp'                  = [Int32]$daysToBlockIp
                'MaxIndicatorReturnSize'         = [Int32]$maxIndicatorReturnSize
                'SafeIpList'                     = [Array]$safeIpList
                'MaxIpPerBlockList'              = [Int32]$maxIpPerBlockList
                'AttackerDataPath'               = $attackerDataPath
                'BlockListPath'                  = $blockListPath
                'ManualIpBlockListFilePath'      = $manualIpBlockListFilePath
                'LastAttackerDataFetchTimestamp' = ''
                'AttackerDataFileNameDateFormat' = $attackerDataFileNameDateFormat
                'AttackerDataFileNameFormat'     = $attackerDataFileNameFormat
                'BlockListFileNameFormat'        = $blockListFileNameFormat
            }

            $json = $config | ConvertTo-Json
            $json | Out-File -FilePath (Get-ConfigurationFilePath -ConfigurationName $ConfigurationName)
            $json | ConvertFrom-Json
        }
    }
}
