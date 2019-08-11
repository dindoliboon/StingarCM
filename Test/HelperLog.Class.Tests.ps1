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
    Describe "[HelperLog]::FormatLogMessage" -Tags Build , Unit {
        Context 'When providing a valid message' {
            It 'Should return round-trip format [caller] with message' {
                # 2019-07-19T00:25:33.8071920-04:00 [<ScriptBlock>] mymessage
                [HelperLog]::FormatLogMessage('mymessage') | Should -Match '^\d+-\d+-\d+T\d+:\d+:\d+\.\d+-\d+:\d+ \[.*\] mymessage$'
            }
        }

        Context 'When providing an empty message' {
            It 'Uses round-trip format [caller] with empty string' {
                # 2019-07-19T00:25:33.8071920-04:00 [<ScriptBlock>]
                [HelperLog]::FormatLogMessage('') | Should -Match '^\d+-\d+-\d+T\d+:\d+:\d+\.\d+-\d+:\d+ \[.*\] $'
            }
        }

        Context 'When providing a null message' {
            It 'Uses round-trip format [caller] with null' {
                # 2019-07-19T00:25:33.8071920-04:00 [<ScriptBlock>]
                [HelperLog]::FormatLogMessage($null) | Should -Match '^\d+-\d+-\d+T\d+:\d+:\d+\.\d+-\d+:\d+ \[.*\] $'
            }
        }
    }
}
