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
    Describe 'Remove-MatchingSafeIp' -Tags Build , Unit {
        Context 'When providing an IPv4 address not in the safe list via pipeline' {
            It 'Should return original IP' {
                '2.3.4.5' | Remove-MatchingSafeIp -SafeIp @('1.2.3.4') | Should Be '2.3.4.5'
            }
        }

        Context 'When providing an IPv4 address array not in the safe list via pipeline' {
            It 'Should return original IP' {
                @('6.7.8.9', '2.3.4.5') | Remove-MatchingSafeIp -SafeIp @('1.2.3.4') | Should Be @('6.7.8.9', '2.3.4.5')
            }
        }

        Context 'When providing an IPv4 address in the safe list using IP' {
            It 'Should return null' {
                $oldWarningPreference = $WarningPreference
                $WarningPreference = 'SilentlyContinue'
                Remove-MatchingSafeIp -Data '1.2.3.4' -SafeIp @('1.2.3.4') | Should Be $null
                $WarningPreference = $oldWarningPreference
            }
        }

        Context 'When providing an IPv4 address in the safe list using regex' {
            It 'Should return null' {
                $oldWarningPreference = $WarningPreference
                $WarningPreference = 'SilentlyContinue'
                Remove-MatchingSafeIp -Data '1.2.3.4' -SafeIp @('1\.2\.\d+\.\d+') | Should Be $null
                $WarningPreference = $oldWarningPreference
            }
        }

        Context 'When providing an IPv4 address in the safe list using regex array' {
            It 'Should return null' {
                $oldWarningPreference = $WarningPreference
                $WarningPreference = 'SilentlyContinue'
                Remove-MatchingSafeIp -Data '1.2.3.4' -SafeIp @('1.2.4.5', '1\.2\.\d+\.\d+', '1.2.5.6') | Should Be $null
                $WarningPreference = $oldWarningPreference
            }
        }

        Context 'When providing an IPv4 address not in the safe list' {
            It 'Should return original IP' {
                Remove-MatchingSafeIp -Data '2.3.4.5' -SafeIp @('1.2.3.4') | Should Be '2.3.4.5'
            }
        }
    }
}
