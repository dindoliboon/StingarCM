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
    Describe 'Export-RawAttackDataToCsv' -Tags Build , Unit {
        $Script:AppConfig = @{
            Config = @{
                AttackerDataFileNameDateFormat = 'yyyyMMdd'
                AttackerDataFileNameFormat = 'cif-attack-data-{0}.csv'
                AttackerDataPath = Join-Path -Path $TestDrive -ChildPath '.stingarcm/contoso/data'
            }
        }

        Mock Get-CifIndicator {
            $reportTimeYesterday = Get-Date -Format 'yyyy-MM-ddT00:00:00Z' -Date (Get-Date).AddDays(-1)
            $reportTimeToday = Get-Date -Format 'yyyy-MM-ddT00:00:00Z'
            $data = '{"Data":[{"Itype":"ipv4","Cc":"cn","Timezone":"asia/shanghai","Protocol":null,"Message":[],"Id":1.0,"City":null,"Indicator":"1.1.1.1","Reporttime":"' + $reportTimeYesterday + '","Group":"everyone","AsnDesc":"contoso","Provider":"partner1","Latitude":"34.1","Description":null,"Tags":["honeypot","dionaea"],"Portlist":"None","Confidence":8.0,"Rdata":null,"Lasttime":"2019-07-23T01:12:57.632248Z","Asn":"24547.0","Count":2609.0,"Peers":null,"Tlp":"green","Firsttime":"2019-06-10T00:48:41.564408Z","Region":null,"Longitude":"113.1","AdditionalData":null},' +
                             '{"Itype":"ipv4","Cc":"cn","Timezone":"asia/shanghai","Protocol":null,"Message":[],"Id":1.0,"City":"shenzhen","Indicator":"2.2.2.2","Reporttime":"' + $reportTimeToday + '","Group":"everyone","AsnDesc":"contoso","Provider":"1","Latitude":"22.1","Description":null,"Tags":["honeypot","dionaea"],"Portlist":"None","Confidence":8.0,"Rdata":null,"Lasttime":"2019-07-23T01:12:57.068798Z","Asn":"4134.0","Count":102.0,"Peers":null,"Tlp":"green","Firsttime":"2019-07-22T01:09:19.329897Z","Region":"guangdong","Longitude":"114.1","AdditionalData":null}],"Status":"success"}'
            $data | ConvertFrom-Json
        }

        Context 'When retrieving indicators from yesterday and today from CIF' {
            It 'Should create data files for yesterday and today' {
                Remove-Item -Path $Script:AppConfig.Config.AttackerDataPath -Recurse -Force -ErrorAction SilentlyContinue
                New-Item -Path $Script:AppConfig.Config.AttackerDataPath -ItemType Directory -Force -ErrorAction SilentlyContinue

                Export-RawAttackDataToCsv -Path $Script:AppConfig.Config.AttackerDataPath -AttackAgeInDays 1 -MaxIndicatorReturnSize 2

                (Get-ChildItem -Path $Script:AppConfig.Config.AttackerDataPath).Count | Should Be 2
            }
        }

        Context 'When providing an invalid LastAttackerDataFetchTimestamp' {
            It 'Should throw' {
                {
                    Export-RawAttackDataToCsv -Path $Script:AppConfig.Config.AttackerDataPath -AttackAgeInDays 1 -MaxIndicatorReturnSize 2 -LastAttackerDataFetchTimestamp 'wrong'
                } | Should Throw
            }
        }

        Context 'When retrieving indicators for today from CIF' {
            Mock Get-CifIndicator {
                $reportTimeToday = Get-Date -Format 'yyyy-MM-ddT00:00:00Z'
                $data = '{"Data":[{"Itype":"ipv4","Cc":"cn","Timezone":"asia/shanghai","Protocol":null,"Message":[],"Id":1.0,"City":"shenzhen","Indicator":"2.2.2.2","Reporttime":"' + $reportTimeToday + '","Group":"everyone","AsnDesc":"contoso","Provider":"1","Latitude":"22.1","Description":null,"Tags":["honeypot","dionaea"],"Portlist":"None","Confidence":8.0,"Rdata":null,"Lasttime":"2019-07-23T01:12:57.068798Z","Asn":"4134.0","Count":102.0,"Peers":null,"Tlp":"green","Firsttime":"2019-07-22T01:09:19.329897Z","Region":"guangdong","Longitude":"114.1","AdditionalData":null}],"Status":"success"}'
                $data | ConvertFrom-Json
            }

            It 'Should create data files for today' {
                Remove-Item -Path $Script:AppConfig.Config.AttackerDataPath -Recurse -Force -ErrorAction SilentlyContinue
                New-Item -Path $Script:AppConfig.Config.AttackerDataPath -ItemType Directory -Force -ErrorAction SilentlyContinue

                Export-RawAttackDataToCsv -Path $Script:AppConfig.Config.AttackerDataPath -AttackAgeInDays 1 -MaxIndicatorReturnSize 2 -LastAttackerDataFetchTimestamp (Get-Date -Format 'yyyy-MM-ddT00:00:00Z')

                (Get-ChildItem -Path $Script:AppConfig.Config.AttackerDataPath) | Should Not Be $null
            }
        }
    }
}
