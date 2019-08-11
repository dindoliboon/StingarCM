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
    Describe 'Invoke-NewBlockList' -Tags Build , Unit {
        Mock Get-RootPath {
            Join-Path -Path $TestDrive -ChildPath 'users/alex/.stingarcm'
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What is the CIFv3 URI?' } {
            'https://v3.cif.localhost'
        }

        Mock Read-Host -ParameterFilter { $Prompt -eq 'What is your CIFv3 read-only token?' } {
            ConvertTo-SecureString -String '0123456789' -AsPlainText -Force
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'How many days do you want to block an IP?' } {
            4
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What is the maximum number of attacker IPs to fetch?' } {
            1000
        }

        Mock Read-Host -ParameterFilter { $Prompt -eq 'What IPv4 addresses should be on your safe list? (supports regex, separate by comma)' } {
            '^127\.\d+\.\d+\.\d+$, ^10\.\d+\.\d+\.\d+$, ^169\.254\.\d+\.\d+$'
        }

        Mock Read-Host -ParameterFilter { $Prompt -eq 'Enter a file path that contains a CSV of IPs to block' } {
            Join-Path -Path (Get-RootPath) -ChildPath 'contoso/mydata2/manual-ip-blocklist.csv'
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What is the maximum number of IPs each block list can hold?' } {
            4
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What folder should raw attack data be saved to?' } {
            Join-Path -Path (Get-RootPath) -ChildPath 'contoso/mydata2'
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What folder should block lists be saved to?' } {
            Join-Path -Path (Get-RootPath) -ChildPath 'contoso/mylog2'
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What date format should the attack data CSV files use?' } {
            'yyyyMMdd'
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What file name format should the attack data CSV files use?' } {
            'cif-attack-data-{0}.csv'
        }

        Mock Read-HostForce -ParameterFilter { $Prompt -eq 'What file name format should the IP block list use?' } {
            'cif-attack-ip-blocklist-{0}.txt'
        }

        Mock Get-CifIndicator {
            $reportTimeYesterday = Get-Date -Format 'yyyy-MM-ddT00:00:00Z' -Date (Get-Date).AddDays(-1)
            $reportTimeToday = Get-Date -Format 'yyyy-MM-ddT00:00:00Z'
            $data = '{"Data":['
            $data = $data + '{"Itype":"ipv4","Cc":"cn","Timezone":"asia/shanghai","Protocol":null,"Message":[],"Id":1.0,"City":null,"Indicator":"1.1.1.1","Reporttime":"' + $reportTimeYesterday + '","Group":"everyone","AsnDesc":"contoso","Provider":"partner1","Latitude":"34.1","Description":null,"Tags":["honeypot","dionaea"],"Portlist":"None","Confidence":8.0,"Rdata":null,"Lasttime":"2019-07-23T01:12:57.632248Z","Asn":"24547.0","Count":2609.0,"Peers":null,"Tlp":"green","Firsttime":"2019-06-10T00:48:41.564408Z","Region":null,"Longitude":"113.1","AdditionalData":null}'
            $data = $data + ',{"Itype":"ipv4","Cc":"cn","Timezone":"asia/shanghai","Protocol":null,"Message":[],"Id":1.0,"City":"shenzhen","Indicator":"2.2.2.2","Reporttime":"' + $reportTimeYesterday + '","Group":"everyone","AsnDesc":"contoso","Provider":"1","Latitude":"22.1","Description":null,"Tags":["honeypot","dionaea"],"Portlist":"None","Confidence":8.0,"Rdata":null,"Lasttime":"2019-07-23T01:12:57.068798Z","Asn":"4134.0","Count":102.0,"Peers":null,"Tlp":"green","Firsttime":"2019-07-22T01:09:19.329897Z","Region":"guangdong","Longitude":"114.1","AdditionalData":null}'
            $data = $data + ',{"Itype":"ipv4","Cc":"cn","Timezone":"asia/shanghai","Protocol":null,"Message":[],"Id":1.0,"City":"shenzhen","Indicator":"2.2.2.3","Reporttime":"' + $reportTimeYesterday + '","Group":"everyone","AsnDesc":"contoso","Provider":"1","Latitude":"22.1","Description":null,"Tags":["honeypot","dionaea"],"Portlist":"None","Confidence":8.0,"Rdata":null,"Lasttime":"2019-07-23T01:12:57.068798Z","Asn":"4134.0","Count":102.0,"Peers":null,"Tlp":"green","Firsttime":"2019-07-22T01:09:19.329897Z","Region":"guangdong","Longitude":"114.1","AdditionalData":null}'
            $data = $data + ',{"Itype":"ipv4","Cc":"cn","Timezone":"asia/shanghai","Protocol":null,"Message":[],"Id":1.0,"City":"shenzhen","Indicator":"2.2.2.4","Reporttime":"' + $reportTimeToday + '","Group":"everyone","AsnDesc":"contoso","Provider":"1","Latitude":"22.1","Description":null,"Tags":["honeypot","dionaea"],"Portlist":"None","Confidence":8.0,"Rdata":null,"Lasttime":"2019-07-23T01:12:57.068798Z","Asn":"4134.0","Count":102.0,"Peers":null,"Tlp":"green","Firsttime":"2019-07-22T01:09:19.329897Z","Region":"guangdong","Longitude":"114.1","AdditionalData":null}'
            $data = $data + ',{"Itype":"ipv4","Cc":"cn","Timezone":"asia/shanghai","Protocol":null,"Message":[],"Id":1.0,"City":"shenzhen","Indicator":"2.2.2.5","Reporttime":"' + $reportTimeToday + '","Group":"everyone","AsnDesc":"contoso","Provider":"1","Latitude":"22.1","Description":null,"Tags":["honeypot","dionaea"],"Portlist":"None","Confidence":8.0,"Rdata":null,"Lasttime":"2019-07-23T01:12:57.068798Z","Asn":"4134.0","Count":102.0,"Peers":null,"Tlp":"green","Firsttime":"2019-07-22T01:09:19.329897Z","Region":"guangdong","Longitude":"114.1","AdditionalData":null}'
            $data = $data + ',{"Itype":"ipv4","Cc":"cn","Timezone":"asia/shanghai","Protocol":null,"Message":[],"Id":1.0,"City":"shenzhen","Indicator":"2.2.2.6","Reporttime":"' + $reportTimeToday + '","Group":"everyone","AsnDesc":"contoso","Provider":"1","Latitude":"22.1","Description":null,"Tags":["honeypot","dionaea"],"Portlist":"None","Confidence":8.0,"Rdata":null,"Lasttime":"2019-07-23T01:12:57.068798Z","Asn":"4134.0","Count":102.0,"Peers":null,"Tlp":"green","Firsttime":"2019-07-22T01:09:19.329897Z","Region":"guangdong","Longitude":"114.1","AdditionalData":null}'
            $data = $data + ',{"Itype":"ipv4","Cc":"cn","Timezone":"asia/shanghai","Protocol":null,"Message":[],"Id":1.0,"City":"shenzhen","Indicator":"2.2.2.7","Reporttime":"' + $reportTimeToday + '","Group":"everyone","AsnDesc":"contoso","Provider":"1","Latitude":"22.1","Description":null,"Tags":["honeypot","dionaea"],"Portlist":"None","Confidence":8.0,"Rdata":null,"Lasttime":"2019-07-23T01:12:57.068798Z","Asn":"4134.0","Count":102.0,"Peers":null,"Tlp":"green","Firsttime":"2019-07-22T01:09:19.329897Z","Region":"guangdong","Longitude":"114.1","AdditionalData":null}'
            $data = $data + '],"Status":"success"}'
            $data | ConvertFrom-Json
        }

        # Make sure test directories do not exist.
        Remove-Item -Path (Get-RootPath) -Recurse -Force -ErrorAction SilentlyContinue

        $configurationName = 'contoso'
        Initialize-Configuration -ConfigurationName $configurationName
        $config = New-Configuration -ConfigurationName $configurationName

        Context 'When providing an invalid configuration name' {
            It 'Should throw an error' {
                {
                    Invoke-NewBlockList -ConfigurationName 'bad $  !@#$%^&*( name'
                } | Should Throw
            }
        }

        Context 'When unable to contact server' {
            Mock Initialize-Configuration {
                throw 'Unable to create folders.'
            }

            It 'Should catch the exception' {
                {
                    $csvFilePath = Join-Path -Path (Get-RootPath) -ChildPath 'contoso/data/cif-attack-ip-today.csv'

                    Remove-Item -Path $csvFilePath -Force -ErrorAction SilentlyContinue

                    $currentErrorActionPreference = $ErrorActionPreference
                    $ErrorActionPreference = 'SilentlyContinue'
                    Invoke-NewBlockList -ConfigurationName 'contoso'
                    $ErrorActionPreference = $currentErrorActionPreference
                } | Should Not Throw
            }
        }

        Context 'When providing an IP limit of 4' {
            It 'Should return a block list 1 with 4 indicators' {
                $csvFilePath = Join-Path -Path $config.BlockListPath -ChildPath 'cif-attack-ip-blocklist-1.txt'

                Remove-Item -Path $csvFilePath -Force -ErrorAction SilentlyContinue

                Invoke-ExportAttackData -ConfigurationName 'contoso'

                Invoke-NewBlockList -ConfigurationName 'contoso'

                $data = Get-Content -Path $csvFilePath
                $data | Should Be @('1.1.1.1', '2.2.2.2', '2.2.2.3', '2.2.2.4')
            }

            It 'Should return a block list 2 with 3 indicators' {
                $csvFilePath = Join-Path -Path $config.BlockListPath -ChildPath 'cif-attack-ip-blocklist-2.txt'

                Remove-Item -Path $csvFilePath -Force -ErrorAction SilentlyContinue

                Invoke-ExportAttackData -ConfigurationName 'contoso'

                Invoke-NewBlockList -ConfigurationName 'contoso'

                $data = Get-Content -Path $csvFilePath
                $data | Should Be @('2.2.2.5', '2.2.2.6', '2.2.2.7')
            }
        }

        Context 'When providing a small amount of indicators' {
            Mock Get-CifIndicator {
                $reportTimeToday = Get-Date -Format 'yyyy-MM-ddT00:00:00Z'
                $data = '{"Data":['
                $data = $data + '{"Itype":"ipv4","Cc":"cn","Timezone":"asia/shanghai","Protocol":null,"Message":[],"Id":1.0,"City":"shenzhen","Indicator":"2.2.2.5","Reporttime":"' + $reportTimeToday + '","Group":"everyone","AsnDesc":"contoso","Provider":"1","Latitude":"22.1","Description":null,"Tags":["honeypot","dionaea"],"Portlist":"None","Confidence":8.0,"Rdata":null,"Lasttime":"2019-07-23T01:12:57.068798Z","Asn":"4134.0","Count":102.0,"Peers":null,"Tlp":"green","Firsttime":"2019-07-22T01:09:19.329897Z","Region":"guangdong","Longitude":"114.1","AdditionalData":null}'
                $data = $data + ',{"Itype":"ipv4","Cc":"cn","Timezone":"asia/shanghai","Protocol":null,"Message":[],"Id":1.0,"City":"shenzhen","Indicator":"2.2.2.6","Reporttime":"' + $reportTimeToday + '","Group":"everyone","AsnDesc":"contoso","Provider":"1","Latitude":"22.1","Description":null,"Tags":["honeypot","dionaea"],"Portlist":"None","Confidence":8.0,"Rdata":null,"Lasttime":"2019-07-23T01:12:57.068798Z","Asn":"4134.0","Count":102.0,"Peers":null,"Tlp":"green","Firsttime":"2019-07-22T01:09:19.329897Z","Region":"guangdong","Longitude":"114.1","AdditionalData":null}'
                $data = $data + ',{"Itype":"ipv4","Cc":"cn","Timezone":"asia/shanghai","Protocol":null,"Message":[],"Id":1.0,"City":"shenzhen","Indicator":"2.2.2.7","Reporttime":"' + $reportTimeToday + '","Group":"everyone","AsnDesc":"contoso","Provider":"1","Latitude":"22.1","Description":null,"Tags":["honeypot","dionaea"],"Portlist":"None","Confidence":8.0,"Rdata":null,"Lasttime":"2019-07-23T01:12:57.068798Z","Asn":"4134.0","Count":102.0,"Peers":null,"Tlp":"green","Firsttime":"2019-07-22T01:09:19.329897Z","Region":"guangdong","Longitude":"114.1","AdditionalData":null}'
                $data = $data + '],"Status":"success"}'
                $data | ConvertFrom-Json
            }

            It 'Should save todays indicators to a CSV file' {
                $csvFilePath1 = Join-Path -Path $config.BlockListPath -ChildPath 'cif-attack-ip-blocklist-1.txt'
                Remove-Item -Path $csvFilePath1 -Force -ErrorAction SilentlyContinue

                $yesterdayTimestamp   = Get-Date -Format 'yyyyMMdd' -Date (Get-Date).AddDays(-1)
                $yesterdayCsvFilePath = Join-Path -Path $config.AttackerDataPath -ChildPath "cif-attack-data-$yesterdayTimestamp.csv"
                $todayTimestamp       = Get-Date -Format 'yyyyMMdd'
                $todayCsvFilePath     = Join-Path -Path $config.AttackerDataPath -ChildPath "cif-attack-data-$todayTimestamp.csv"

                Remove-Item -Path $yesterdayCsvFilePath -Force -ErrorAction SilentlyContinue
                Remove-Item -Path $todayCsvFilePath -Force -ErrorAction SilentlyContinue

                Invoke-ExportAttackData -ConfigurationName 'contoso'
                Invoke-NewBlockList -ConfigurationName 'contoso'

                $data = Get-Content -Path $csvFilePath1
                $data | Should Be @('2.2.2.5', '2.2.2.6', '2.2.2.7')
            }

            It 'Should not create a second CSV file' {
                $csvFilePath1 = Join-Path -Path $config.BlockListPath -ChildPath 'cif-attack-ip-blocklist-1.txt'
                $csvFilePath2 = Join-Path -Path $config.BlockListPath -ChildPath 'cif-attack-ip-blocklist-2.txt'

                Remove-Item -Path $csvFilePath1 -Force -ErrorAction SilentlyContinue
                Remove-Item -Path $csvFilePath2 -Force -ErrorAction SilentlyContinue

                Invoke-ExportAttackData -ConfigurationName 'contoso'

                Invoke-NewBlockList -ConfigurationName 'contoso'

                Test-Path -Path $csvFilePath2 | Should Be $false
            }
        }

        Context 'When providing no indicators' {
            Mock Get-CifIndicator {
                $data = '{"Data":[],"Status":"success"}'
                $data | ConvertFrom-Json
            }

            It 'Should not create any block lists' {
                $blockList1 = Join-Path -Path $config.BlockListPath -ChildPath 'cif-attack-ip-blocklist-1.txt'
                Remove-Item -Path $blockList1 -Force -ErrorAction SilentlyContinue

                $yesterdayTimestamp   = Get-Date -Format 'yyyyMMdd' -Date (Get-Date).AddDays(-1)
                $yesterdayCsvFilePath = Join-Path -Path $config.AttackerDataPath -ChildPath "cif-attack-data-$yesterdayTimestamp.csv"
                $todayTimestamp       = Get-Date -Format 'yyyyMMdd'
                $todayCsvFilePath     = Join-Path -Path $config.AttackerDataPath -ChildPath "cif-attack-data-$todayTimestamp.csv"

                Remove-Item -Path $yesterdayCsvFilePath -Force -ErrorAction SilentlyContinue
                Remove-Item -Path $todayCsvFilePath -Force -ErrorAction SilentlyContinue

                Invoke-ExportAttackData -ConfigurationName 'contoso'

                Invoke-NewBlockList -ConfigurationName 'contoso'

                Test-Path -Path $blockList1 | Should Be $false
            }
        }
    }
}
