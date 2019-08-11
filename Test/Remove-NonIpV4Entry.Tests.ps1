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
    Describe 'Remove-NonIpV4Entry' -Tags Build , Unit {
        Context 'When providing valid IPv4 address via pipeline' {
            It 'Should return provided address' {
                '1.2.3.4' | Remove-NonIpV4Entry | Should Be '1.2.3.4'
            }
        }

        Context 'When providing valid IPv4 address array via pipeline' {
            It 'Should return provided address' {
                @('1.2.3.4', '2.3.4.5') | Remove-NonIpV4Entry | Should Be @('1.2.3.4', '2.3.4.5')
            }
        }

        Context 'When providing an IPv4 address' {
            It 'Should return provided address' {
                Remove-NonIpV4Entry -Data '1.2.3.4' | Should Be '1.2.3.4'
            }
        }

        Context 'When providing an IPv4 address with spaces' {
            It 'Should return provided address' {
                Remove-NonIpV4Entry -Data ' 1.2.3.4 ' | Should Be '1.2.3.4'
            }
        }

        Context 'When providing a URI string' {
            It 'Should return null' {
                $oldWarningPreference = $WarningPreference
                $WarningPreference = 'SilentlyContinue'
                Remove-NonIpV4Entry -Data 'https://contoso.com' | Should Be $null
                $WarningPreference = $oldWarningPreference
            }
        }

        Context 'When providing an SHA1 string' {
            It 'Should return null' {
                $oldWarningPreference = $WarningPreference
                $WarningPreference = 'SilentlyContinue'
                Remove-NonIpV4Entry -Data '0feca720e2c29dafb2c900713ba560e03b758711' | Should Be $null
                $WarningPreference = $oldWarningPreference
            }

            It 'Should not return [string]::empty' {
                $oldWarningPreference = $WarningPreference
                $WarningPreference = 'SilentlyContinue'
                Remove-NonIpV4Entry -Data '0feca720e2c29dafb2c900713ba560e03b758711' | Should Not Be [string]::empty
                $WarningPreference = $oldWarningPreference
            }

            It 'Should not return an empty string' {
                $oldWarningPreference = $WarningPreference
                $WarningPreference = 'SilentlyContinue'
                Remove-NonIpV4Entry -Data '0feca720e2c29dafb2c900713ba560e03b758711' | Should Not Be ''
                $WarningPreference = $oldWarningPreference
            }
        }
    }
}
