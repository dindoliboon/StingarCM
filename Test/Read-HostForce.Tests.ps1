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
    Describe 'Read-HostForce' -Tags Build , Unit {
        Context 'When requesting a URL' {
            Mock Read-Host {
                return 'https://contoso.com'
            }

            It 'Should return a URL' {
                Read-HostForce -Prompt 'Enter a URL' -Default 'https://contoso.com' -ValidatePattern '^https?:\/\/.+$' | Should Be 'https://contoso.com'
            }
        }

        Context 'When requesting an integer' {
            Mock Read-Host {
                return '4'
            }

            It 'Should return an integer' {
                Read-HostForce -Prompt 'Enter a number' -Default '4' -ValidatePattern '^\d+$' | Should Be '4'
            }
        }

        Context 'When requesting a string' {
            Mock Read-Host {
                return 'Alex'
            }

            It 'Should return a string' {
                Read-HostForce -Prompt 'Enter a name' -Default 'Alex' -ValidatePattern '^alex$' | Should Be 'Alex'
            }
        }

        Context 'When when entering an empty string' {
            Mock Read-Host {
                return ''
            }

            It 'Should return the default string' {
                Read-HostForce -Prompt 'Enter a name' -Default 'Alex' -ValidatePattern '^alex$' | Should Be 'Alex'
            }
        }
    }
}
