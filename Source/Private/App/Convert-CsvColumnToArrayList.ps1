function Convert-CsvColumnToArrayList ([System.Collections.ArrayList]$ArrayList, [string]$FilePath, [string]$ColumnName) {
    Write-Verbose -Message ([HelperLog]::FormatLogMessage("Processing CSV: $FilePath"))

    Import-Csv -Path $FilePath | ForEach-Object {
        try {
            $csvColumnData = $_."$ColumnName"
            if ($ArrayList.Contains($csvColumnData) -eq $false) {
                $ArrayList.Add($csvColumnData) | Out-Null
            }
        } catch [Exception] {
            Write-Warning -Message ([HelperLog]::FormatLogMessage("Error while trying to add item from column: $ColumnName"))
        }
    }
}
