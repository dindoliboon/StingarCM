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
    Describe 'Get-RootPath' -Tags Build , Unit {
        Context 'When environment HOME is defined' {
            It 'Should return the leaf .stingarcm' {
                Get-RootPath | Split-Path -Leaf | Should Be '.stingarcm'
            }

            It 'Should have a parent path' {
                (Get-RootPath | Split-Path -Parent).Length | Should BeGreaterThan 0
            }
        }

        Context 'When Path is defined' {
            It 'Should return the leaf .stingarcm' {
                Get-RootPath -Path '/tmp/users/user' | Split-Path -Leaf | Should Be '.stingarcm'
            }

            It 'Should have a parent path' {
                (Get-RootPath '/tmp/users/user' | Split-Path -Parent).Length | Should BeGreaterThan 0
            }
        }

        Context 'When Path is not defined' {
            Mock Get-EnvHome {
                $null
            }

            It 'Should throw an error' {
                {
                    Get-RootPath -Path ''
                } | Should Throw
            }
        }
    }
}
