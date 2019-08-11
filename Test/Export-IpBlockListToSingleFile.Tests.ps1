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
    Describe 'Export-IpBlockListToSingleFile' -Tags Build , Unit {
        Context 'When providing multiple IPs' {
            $Script:AppConfig = @{
                Config = @{
                    ConfigurationName = 'contoso'
                    BlockListPath     = Join-Path -Path $TestDrive -ChildPath 'blocklist'
                    BlockListFileNameFormat = 'bl-{0}.txt'
                }
            }

            Remove-Item -Path $Script:AppConfig.Config.BlockListPath -Recurse -Force -ErrorAction SilentlyContinue
            New-Item -Path $Script:AppConfig.Config.BlockListPath -ItemType Directory -Force -ErrorAction SilentlyContinue

            It 'Should save the IPs to a single block list file' {
                Export-IpBlockListToSingleFile -IpBlockList @('1.1.1.1', '2.2.2.2', '3.3.3.3')
                (Get-ChildItem -Path $Script:AppConfig.Config.BlockListPath).Length | Should BeGreaterThan 0
            }
        }

        Context 'When providing an empty block list' {
            $Script:AppConfig = @{
                Config = @{
                    ConfigurationName = 'contoso'
                    BlockListPath     = Join-Path -Path $TestDrive -ChildPath 'blocklist'
                    BlockListFileNameFormat = 'bl-{0}.txt'
                }
            }

            Remove-Item -Path $Script:AppConfig.Config.BlockListPath -Recurse -Force -ErrorAction SilentlyContinue
            New-Item -Path $Script:AppConfig.Config.BlockListPath -ItemType Directory -Force -ErrorAction SilentlyContinue

            It 'Should create an empty block list file' {
                Export-IpBlockListToSingleFile -IpBlockList @()
                (Get-ChildItem -Path $Script:AppConfig.Config.BlockListPath).Length | Should Be 0
            }
        }

        Context 'When providing a null block list' {
            $Script:AppConfig = @{
                Config = @{
                    ConfigurationName = 'contoso'
                    BlockListPath     = Join-Path -Path $TestDrive -ChildPath 'blocklist'
                    BlockListFileNameFormat = 'bl-{0}.txt'
                }
            }

            Remove-Item -Path $Script:AppConfig.Config.BlockListPath -Recurse -Force -ErrorAction SilentlyContinue
            New-Item -Path $Script:AppConfig.Config.BlockListPath -ItemType Directory -Force -ErrorAction SilentlyContinue

            It 'Should create an empty block list file' {
                Export-IpBlockListToSingleFile -IpBlockList $null
                (Get-ChildItem -Path $Script:AppConfig.Config.BlockListPath).Length | Should Be 0
            }
        }
    }
}
