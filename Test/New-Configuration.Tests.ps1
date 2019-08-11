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
    Describe 'New-Configuration' -Tags Build , Unit {
        $Script:AppConfig = @{
            AppPath = Join-Path -Path $TestDrive -ChildPath 'stingar_data'
        }

        Mock Get-RootPath {
            Join-Path -Path $TestDrive -ChildPath 'users/alex/.stingarcm'
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What is the CIFv3 URI?' } {
            'https://v3.cif.localhost'
        }

        Mock Read-Host -ParameterFilter { $Prompt -eq 'What is your CIFv3 read-only token?' } {
            ConvertTo-SecureString -String '0123456789' -AsPlainText -Force
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'How many days do you want to block an IP?' } {
            4
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What is the maximum number of attacker IPs to fetch?' } {
            1000
        }

        Mock Read-Host -ParameterFilter { $Prompt -eq 'What IPv4 addresses should be on your safe list? (supports regex, separate by comma)' } {
            '^127\.\d+\.\d+\.\d+$, ^10\.\d+\.\d+\.\d+$, ^169\.254\.\d+\.\d+$'
        }

        Mock Read-Host -ParameterFilter { $Prompt -eq 'Enter a file path that contains a CSV of IPs to block' } {
            Join-Path -Path (Get-RootPath) -ChildPath 'contoso/mydata2/manual-ip-blocklist.csv'
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What is the maximum number of IPs each block list can hold?' } {
            39700
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What folder should raw attack data be saved to?' } {
            Join-Path -Path (Get-RootPath) -ChildPath 'contoso/mydata2'
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What folder should block lists be saved to?' } {
            Join-Path -Path (Get-RootPath) -ChildPath 'contoso/mylog2'
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What date format should the attack data CSV files use?' } {
            'yyyyMMdd'
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What file name format should the attack data CSV files use?' } {
            'cif-attack-data-{0}.csv'
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What file name format should the IP block list use?' } {
            'cif-attack-ip-blocklist-{0}.txt'
        }

        # Make sure test directories do not exist.
        Remove-Item -Path (Get-RootPath) -Recurse -Force -ErrorAction SilentlyContinue

        $configurationName = 'contoso'
        Initialize-Configuration -ConfigurationName $configurationName
        $config = New-Configuration -ConfigurationName $configurationName

        Context 'When providing valid configuration data' {
            It 'Should create a new configuration' {
                $config | Should BeOfType PSCustomObject
            }

            It 'Should set ConfigurationName' {
                $config.ConfigurationName | Should Be 'contoso'
            }

            It 'Should set CifApiUri' {
                $config.CifApiUri | Should Be 'https://v3.cif.localhost'
            }

            It 'Should set CifApiToken' {
                $config.CifApiToken.Length | Should BeGreaterThan 0
            }

            It 'Should set DaysToBlockIp' {
                $config.DaysToBlockIp | Should Be '4'
            }

            It 'Should set MaxIndicatorReturnSize' {
                $config.MaxIndicatorReturnSize | Should Be '1000'
            }

            It 'Should set SafeIpList' {
                $config.SafeIpList.Count | Should BeGreaterThan 0
            }

            It 'Should set MaxIpPerBlockList' {
                $config.MaxIpPerBlockList | Should Be '39700'
            }

            It 'Should set AttackerDataPath' {
                Test-Path -Path $config.AttackerDataPath | Should Be $true
            }

            It 'Should set BlockListPath' {
                Test-Path -Path $config.BlockListPath | Should Be $true
            }

            It 'Should set ManualIpBlockListFilePath' {
                $config.ManualIpBlockListFilePath | Should Be "$($config.AttackerDataPath)/manual-ip-blocklist.csv"
            }

            It 'Should set AttackerDataFileNameDateFormat' {
                $config.AttackerDataFileNameDateFormat | Should Be 'yyyyMMdd'
            }

            It 'Should set AttackerDataFileNameFormat' {
                $config.AttackerDataFileNameFormat | Should Be 'cif-attack-data-{0}.csv'
            }

            It 'Should set BlockListFileNameFormat' {
                $config.BlockListFileNameFormat | Should Be 'cif-attack-ip-blocklist-{0}.txt'
            }
        }

        Context 'When providing an invalid configuration name' {
            It 'Should throw an error' {
                { New-Configuration -ConfigurationName 'bad $  !@#$%^&*( name' } | Should Throw
            }
        }
    }
}
