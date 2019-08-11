function Clear-IpBlockListFiles {
    $blockListWildCardFilePath = Join-Path -Path $Script:AppConfig.Config.BlockListPath -ChildPath ([string]::Format($Script:AppConfig.Config.BlockListFileNameFormat, '*'))
    Get-ChildItem -Path $blockListWildCardFilePath -ErrorAction Stop | ForEach-Object {
        '' | Out-File -Path $_.FullName -NoNewline -Encoding ascii
    }
}
