@{
    Path = "StingarCM.psd1"
    OutputDirectory = "..\bin\StingarCM"
    Prefix = '.\_PrefixCode.ps1'
    Suffix = '.\_SuffixCode.ps1'
    SourceDirectories = 'Classes','Private','Public'
    PublicFilter = 'Public\*.ps1'
    VersionedOutputDirectory = $true
}
