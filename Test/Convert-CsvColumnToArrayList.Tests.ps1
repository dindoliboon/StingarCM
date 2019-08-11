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
    Describe 'Convert-CsvColumnToArrayList' -Tags Build , Unit{
        Context 'When providing a valid CSV file and valid ArrayList' {
            It 'Should add IPs to the ArrayList' {
                $indicators = [Collections.ArrayList] @()
                $file = Join-Path -Path $TestDrive -ChildPath 'data.csv'
                $data = @(
                    [PSCustomObject]@{ indicator = '1.2.3.4' },
                    [PSCustomObject]@{ indicator = '2.3.4.5' })
                $data | Export-Csv -Path $file -Force

                Convert-CsvColumnToArrayList -ArrayList $indicators -FilePath $file -ColumnName 'indicator'
                $indicators.Count | Should Be 2
            }
        }

        Context 'When providing a valid CSV file with duplicate data and valid ArrayList' {
            It 'Should add 1 IP to the ArrayList' {
                $indicators = [Collections.ArrayList] @()
                $file = Join-Path -Path $TestDrive -ChildPath 'data.csv'
                $data = @(
                    [PSCustomObject]@{ indicator = '1.2.3.4' },
                    [PSCustomObject]@{ indicator = '1.2.3.4' })
                $data | Export-Csv -Path $file -Force

                Convert-CsvColumnToArrayList -ArrayList $indicators -FilePath $file -ColumnName 'indicator'
                $indicators.Count | Should Be 1
            }
        }

        Context 'When providing non-existent CSV file and valid ArrayList' {
            It 'Should throw' {
                {
                    $indicators = [Collections.ArrayList] @('1.2.3.4', '2.3.4.5')
                    $file = Join-Path -Path $TestDrive -ChildPath 'not-real-data.csv'
                    Remove-Item -Path $file -Force -ErrorAction SilentlyContinue

                    Convert-CsvColumnToArrayList -ArrayList $indicators -FilePath $file -ColumnName 'indicator'
                } | Should Throw
            }
        }

        Context 'When providing a valid CSV file and invalid ArrayList' {
            It 'Should not add IPs to the ArrayList' {
                $indicators = @{}
                $file = Join-Path -Path $TestDrive -ChildPath 'data.csv'
                $data = @(
                    [PSCustomObject]@{ indicator = '1.2.3.4' },
                    [PSCustomObject]@{ indicator = '2.3.4.5' })
                $data | Export-Csv -Path $file -Force

                Convert-CsvColumnToArrayList -ArrayList $indicators -FilePath $file -ColumnName 'indicator'
                $indicators.Count | Should Be 0
            }
        }

        Context 'When providing valid CSV file with invalid column and valid ArrayList' {
            It 'Should not add any IPs' {
                $indicators = [Collections.ArrayList] @()
                $file = Join-Path -Path $TestDrive -ChildPath 'data.csv'
                $data = @(
                    [PSCustomObject]@{ indicators = '2.3.4.5' })
                $data | Export-Csv -Path $file -Force

                $currentWarningPreference = $WarningPreference
                $WarningPreference = 'SilentlyContinue'
                Convert-CsvColumnToArrayList -ArrayList $indicators -FilePath $file -ColumnName 'indicator'
                $WarningPreference = $currentWarningPreference
                $indicators.Count | Should Be 0
            }
        }
    }
}
