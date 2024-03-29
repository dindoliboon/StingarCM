function Verb-Noun {

    <#
    .SYNOPSIS
        Short description

    .DESCRIPTION
        Long description

    .EXAMPLE
        Verb-Noun

        Example of how to use this cmdlet

    .EXAMPLE
        Verb-Noun

        Another example of how to use this cmdlet

    .INPUTS
        Inputs to this cmdlet (if any)

    .OUTPUTS
        Output from this cmdlet (if any)

    .NOTES
        General notes

    .COMPONENT
        The component this cmdlet belongs to

    .ROLE
        The role this cmdlet belongs to

    .FUNCTIONALITY
        The functionality that best describes this cmdlet
    #>

    [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                  SupportsShouldProcess=$true,
                  PositionalBinding=$false,
                  HelpUri='http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [Alias('MyCoolShortcut')]
    [OutputType([string])]
    param (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(0, 5)]
        [ValidateSet('sun', 'moon', 'earth')]
        [Alias('p1')]
        $Param1,

        # Param2 help description
        [Parameter(ParameterSetName='Parameter Set 1')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [ValidateScript({$true})]
        [ValidateRange(0, 5)]
        [int]
        $Param2,

        # Param3 help description
        [Parameter(ParameterSetName='Another Parameter Set')]
        [ValidatePattern('[a-z]*')]
        [ValidateLength(0, 15)]
        [string]
        $Param3
    )

    begin {
    }

    process {
        if ($pscmdlet.ShouldProcess('Target', 'Operation')) {
        }
    }

    end {
    }
}
