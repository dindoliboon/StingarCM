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
    Describe 'Merge-ColumnDataArrayToString' -Tags Build , Unit {
        Context 'When providing column names' {
            It 'Should return the same number of columns entered' {
                $calculatedProperties = Merge-ColumnDataArrayToString -InputObject @('Column1', 'Column2')
                $calculatedProperties.Count | Should Be 2
            }
        }

        Context 'When providing no column names' {
            It 'Should return null' {
                Merge-ColumnDataArrayToString -InputObject @() | Should Be $null
            }
        }

        Context 'When providing null for column names' {
            It 'Should return null' {
                Merge-ColumnDataArrayToString -InputObject $null | Should Be $null
            }
        }

        Context 'When providing columns with an array of data' {
            It 'Should return the array of data as a single string' {
                $jsonData = '{"Data":[{"Itype":"ipv4","Cc":"cn","Timezone":"asia/shanghai","Protocol":null,"Message":[],"Id":1.0,"City":null,"Indicator":"1.1.1.1","Reporttime":"2019-07-23T01:12:58.823688Z","Group":"everyone","AsnDesc":"contoso","Provider":"partner1","Latitude":"34.1","Description":null,"Tags":["honeypot","dionaea"],"Portlist":"None","Confidence":8.0,"Rdata":null,"Lasttime":"2019-07-23T01:12:57.632248Z","Asn":"24547.0","Count":2609.0,"Peers":null,"Tlp":"green","Firsttime":"2019-06-10T00:48:41.564408Z","Region":null,"Longitude":"113.1","AdditionalData":null},{"Itype":"ipv4","Cc":"cn","Timezone":"asia/shanghai","Protocol":null,"Message":[],"Id":1.0,"City":"shenzhen","Indicator":"1.1.1.1","Reporttime":"2019-07-23T01:12:58.820123Z","Group":"everyone","AsnDesc":"contoso","Provider":"1","Latitude":"22.1","Description":null,"Tags":["honeypot","dionaea"],"Portlist":"None","Confidence":8.0,"Rdata":null,"Lasttime":"2019-07-23T01:12:57.068798Z","Asn":"4134.0","Count":102.0,"Peers":null,"Tlp":"green","Firsttime":"2019-07-22T01:09:19.329897Z","Region":"guangdong","Longitude":"114.1","AdditionalData":null}],"Status":"success"}'
                $data = ($jsonData | ConvertFrom-Json).Data

                $calculatedProperties = Merge-ColumnDataArrayToString -InputObject $data
                $newData = $data | Select-Object -Property $calculatedProperties
                $newData[0].Tags | Should Be 'honeypot;dionaea'
            }
        }
    }
}
