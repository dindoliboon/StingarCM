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
    Describe 'Export-Configuration' -Tags Build , Unit {
        Context 'When providing valid config data' {
            Mock Get-ConfigurationFilePath {
                Join-Path -Path $TestDrive -ChildPath 'config.json'
            }

            $Script:AppConfig = @{
                Config = @{
                    ConfigurationName = 'contoso'
                    SomeProperty      = 'public'
                }
            }

            It 'Should save config as JSON to file' {
                $configFilePath = Join-Path -Path $TestDrive -ChildPath 'config.json'
                Remove-Item -Path $configFilePath -Force -ErrorAction SilentlyContinue
                Export-Configuration
                $config = Get-Content -Path $configFilePath -Raw | ConvertFrom-Json

                $config.SomeProperty | Should Be 'public'
            }
        }

        Context 'When providing null config data' {
            Mock Get-ConfigurationFilePath {
                Join-Path -Path $TestDrive -ChildPath 'config.json'
            }

            $Script:AppConfig = @{
                Config = $null
            }

            It 'Should throw' {
                {
                    Export-Configuration
                } | Should Throw
            }
        }
    }
}
