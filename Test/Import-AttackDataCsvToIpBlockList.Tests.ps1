param(
    $ModuleBase = (Split-Path -Parent $MyInvocation.MyCommand.Path)
)

$script:ModuleName = 'StingarCM'

# Removes all versions of the module from the session before importing
Get-Module $ModuleName | Remove-Module

# For tests in .\Test subdirectory
if ((Split-Path $ModuleBase -Leaf) -eq 'Test') {
    $ModuleBase = Join-Path -Path (Split-Path -Path $ModuleBase -Parent) -ChildPath 'Source'
}

## This variable is for the VSTS tasks and is to be used for referencing any mock artifacts
$Env:ModuleBase = $ModuleBase

Import-Module $ModuleBase\$ModuleName.psd1 -PassThru -ErrorAction Stop | Out-Null

# InModuleScope runs the test in module scope.
# It creates all variables and functions in module scope.
# As a result, test has access to all functions, variables and aliases
# in the module even if they're not exported.
InModuleScope $script:ModuleName {
    Describe 'Import-AttackDataCsvToIpBlockList' -Tags Build , Unit {
        $Script:AppConfig = @{
            AppPath = Join-Path -Path $TestDrive -ChildPath 'stingar_data'
            Config = @{
                DaysToBlockIp = 2
                AttackerDataFileNameDateFormat = 'yyyyMMdd'
                AttackerDataPath = Join-Path -Path $TestDrive -ChildPath 'stingar_data'
                AttackerDataFileNameFormat = 'cif-attack-data-{0}.csv'
                ManualIpBlockListFilePath = Join-Path -Path $TestDrive -ChildPath 'stingar_data/manual-ip-blocklist.csv'
            }
        }

        # Make sure test directories do not exist.
        Remove-Item -Path $Script:AppConfig.AppPath -Recurse -Force -ErrorAction SilentlyContinue

        New-Item -Path $Script:AppConfig.AppPath -ItemType Directory -Force -ErrorAction SilentlyContinue

        Context 'When importing CIF and manual indicator CSV' {
            It 'Should add IPs from CIF and manual CSV to block list array' {
                $todayCsvFile = Join-Path -Path $Script:AppConfig.Config.AttackerDataPath -ChildPath ([string]::Format($Script:AppConfig.Config.AttackerDataFileNameFormat, (Get-Date -Format $Script:AppConfig.Config.AttackerDataFileNameDateFormat)))
                "indicator`n1.1.1.1" | Out-File -FilePath $todayCsvFile -Encoding ascii -Force

                "indicator`n2.2.2.2" | Out-File -FilePath $Script:AppConfig.Config.ManualIpBlockListFilePath -Encoding ascii -Force

                $ipToBlock = [Collections.ArrayList] @()
                Import-AttackDataCsvToIpBlockList -IpBlockList $ipToBlock

                $ipToBlock.Count | Should Be 2
            }
        }
    }
}
