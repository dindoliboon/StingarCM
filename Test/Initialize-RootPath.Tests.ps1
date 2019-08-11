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
    Describe 'Initialize-RootPath' -Tags Build , Unit {
        $Script:AppConfig = @{
            AppPath = Join-Path -Path $TestDrive -ChildPath 'stingar_data'
        }

        Context 'When providing a valid configuration name' {
            Mock Get-RootPath {
                Join-Path -Path $TestDrive -ChildPath 'users/alex/.stingarcm'
            }

            $configurationName = 'contoso'

            It 'Should create a root path' {
                Initialize-RootPath -ConfigurationName $configurationName
                Test-Path -Path (Get-RootPath) | Should Be $true
            }

            It 'Should create a config path' {
                Initialize-RootPath -ConfigurationName $configurationName
                Test-Path -Path (Join-Path -Path (Get-RootPath) -ChildPath "$configurationName/config") | Should Be $true
            }

            It 'Should create a log path' {
                Initialize-RootPath -ConfigurationName $configurationName
                Test-Path -Path (Join-Path -Path (Get-RootPath) -ChildPath "$configurationName/log") | Should Be $true
            }

            It 'Should create a data path' {
                Initialize-RootPath -ConfigurationName $configurationName
                Test-Path -Path (Join-Path -Path (Get-RootPath) -ChildPath "$configurationName/data") | Should Be $true
            }

            It 'Should not have an invalid subfolder path' {
                Initialize-RootPath -ConfigurationName $configurationName
                Test-Path -Path (Join-Path -Path (Get-RootPath) -ChildPath "$configurationName/_not_real_") | Should Be $false
            }
        }

        Context 'When unable to create root path' {
            $rootPath = Join-Path -Path $TestDrive -ChildPath 'users/alex/.stingarcm'
            Mock Test-Path -ParameterFilter {$Path -eq $Script:AppConfig.AppPath} {
                $false
            }

            It 'Should throw an error' {
                { Initialize-RootPath -ConfigurationName 'contoso' } | Should Throw
            }
        }

        Context 'When unable to create config path' {
            $rootPath = Join-Path -Path $TestDrive -ChildPath 'users/alex/.stingarcm'
            $configPath = Join-Path -Path $TestDrive -ChildPath 'users/alex/.stingarcm/config'

            Mock Get-RootPath {
                $rootPath
            }

            Mock Test-Path -ParameterFilter {$Path -eq $configPath} {
                $false
            }

            It 'Should throw an error' {
                { Initialize-RootPath -ConfigurationName 'contoso' } | Should Throw
            }
        }

        Context 'When unable to create log path' {
            $rootPath = Join-Path -Path $TestDrive -ChildPath 'users/alex/.stingarcm'
            $logPath = Join-Path -Path $TestDrive -ChildPath 'users/alex/.stingarcm/log'

            Mock Get-RootPath {
                $rootPath
            }

            Mock Test-Path -ParameterFilter {$Path -eq $logPath} {
                $false
            }

            It 'Should throw an error' {
                { Initialize-RootPath -ConfigurationName 'contoso' } | Should Throw
            }
        }

        Context 'When unable to create data path' {
            $rootPath = Join-Path -Path $TestDrive -ChildPath 'users/alex/.stingarcm'
            $dataPath = Join-Path -Path $TestDrive -ChildPath 'users/alex/.stingarcm/data'

            Mock Get-RootPath {
                $rootPath
            }

            Mock Test-Path -ParameterFilter {$Path -eq $dataPath} {
                $false
            }

            It 'Should throw an error' {
                { Initialize-RootPath -ConfigurationName 'contoso' } | Should Throw
            }
        }
    }
}
