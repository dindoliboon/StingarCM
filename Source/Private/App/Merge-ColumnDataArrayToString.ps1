function Merge-ColumnDataArrayToString {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '')]
    [CmdletBinding()]
    Param (
        $InputObject
    )

    $newColumnCollection = [System.Collections.ArrayList]@()
    $InputObject | Get-Member -MemberType Property,NoteProperty -ErrorAction SilentlyContinue | ForEach-Object {
        $originalColumnName  = $_.Name
        $newColumnExpression = Invoke-Expression -Command "@{Name='$originalColumnName'; Expression={`$_.$originalColumnName -join ';'}}"
        $newColumnCollection.Add($newColumnExpression) | Out-Null
    }

    return $newColumnCollection
}
