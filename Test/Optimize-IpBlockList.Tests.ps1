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
    Describe 'Optimize-IpBlockList' -Tags Build , Unit {
        $Script:AppConfig = @{
            Config = @{
                SafeIpList = @('^127\.\d+\.\d+\.\d+$',
                    '^10\.\d+\.\d+\.\d+$',
                    '^169\.254\.\d+\.\d+$',
                    '^172\.((1[6-9])|(2[0-9])|(3[0-1]))\.\d+\.\d+$',
                    '^192\.168\.\d+\.\d+$')
            }
        }

        Context 'When providing IPs that do not match the safe list' {
            It 'Should not remove those IPs from the block list' {
                (Optimize-IpBlockList -IpBlockList @('1.1.1.1', '2.2.2.2', '3.3.3.3')).Count | Should Be 3
            }
        }

        Context 'When providing some IPs that match the safe list' {
            It 'Should remove those IPs from the block list' {
                (Optimize-IpBlockList -IpBlockList @('1.1.1.1', '10.2.2.2', '3.3.3.3')).Count | Should Be 2
            }
        }

        Context 'When providing no IPs in the block list' {
            It 'Should return null' {
                Optimize-IpBlockList -IpBlockList @() | Should Be $null
            }
        }

        Context 'When providing null for the block list' {
            It 'Should return null' {
                Optimize-IpBlockList -IpBlockList $null | Should Be $null
            }
        }

        Context 'When providing IPs that do not match the safe list' {
            $Script:AppConfig = @{
                Config = @{
                    SafeIpList = @()
                }
            }

            It 'Should not remove those IPs from the block list' {
                (Optimize-IpBlockList -IpBlockList @('1.1.1.1', '2.2.2.2', '3.3.3.3')).Count | Should Be 3
            }
        }

        Context 'When missing the config safe list' {
            $Script:AppConfig = @{
                Config = @{
                }
            }

            It 'Should throw' {
                {
                    Optimize-IpBlockList -IpBlockList @()
                } | Should Throw
            }
        }
    }
}
