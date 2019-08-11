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
    Describe 'Clear-IpBlockListFiles' -Tags Build , Unit {
        Context 'When providing existing block list files' {
            $Script:AppConfig = @{
                Config = @{
                    BlockListPath           =  Join-Path -Path $TestDrive -ChildPath '.stingarcm/contoso/blocklist'
                    BlockListFileNameFormat = 'cif-attack-ip-blocklist-{0}.txt'
                }
            }

            New-Item -Path $Script:AppConfig.Config.BlockListPath -ItemType Directory -Force -ErrorAction SilentlyContinue

            for ($blockListIndex = 1; $blockListIndex -le 10; $blockListIndex++) {
                $blockListFilePath = (Join-Path -Path $Script:AppConfig.Config.BlockListPath -ChildPath ([string]::Format($Script:AppConfig.Config.BlockListFileNameFormat, $blockListIndex)))
                [Guid]::NewGuid().Guid | Out-File -FilePath $blockListFilePath -Force
            }

            It 'Should remove the content inside each block list file' {
                Clear-IpBlockListFiles

                $blockListContent = ''
                for ($blockListIndex = 1; $blockListIndex -le 10; $blockListIndex++) {
                    $blockListFilePath = (Join-Path -Path $Script:AppConfig.Config.BlockListPath -ChildPath ([string]::Format($Script:AppConfig.Config.BlockListFileNameFormat, $blockListIndex)))
                    $blockListContent += Get-Content -Path $blockListFilePath -Raw
                }

                $blockListContent | Should Be ''
            }
        }

        Context 'When providing invalid block list folder paths' {
            $Script:AppConfig = @{
                Config = @{
                    BlockListPath           =  Join-Path -Path $TestDrive -ChildPath ([Guid]::NewGuid().Guid)
                    BlockListFileNameFormat = 'cif-attack-ip-blocklist-{0}.txt'
                }
            }

            It 'Should throw' {
                {
                    Clear-IpBlockListFiles
                } | Should Throw
            }
        }

        Context 'When providing no block list files' {
            $Script:AppConfig = @{
                Config = @{
                    BlockListPath           =  Join-Path -Path $TestDrive -ChildPath '.stingarcm/contoso/blocklist'
                    BlockListFileNameFormat = 'cif-attack-ip-blocklist-{0}.txt'
                }
            }

            Remove-Item -Path $Script:AppConfig.Config.BlockListPath -Recurse -Force -ErrorAction SilentlyContinue
            New-Item -Path $Script:AppConfig.Config.BlockListPath -ItemType Directory -Force -ErrorAction SilentlyContinue

            It 'Should not throw' {
                {
                    Clear-IpBlockListFiles
                } | Should Not Throw
            }
        }
    }
}
