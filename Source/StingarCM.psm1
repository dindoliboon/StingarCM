$ModulePath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$BuildData = Import-LocalizedData -BaseDirectory $ModulePath -FileName build.psd1

Push-Location -Path $ModulePath -StackName 'DevModuleLoader'
$Scripts = Get-ChildItem -Path $BuildData.SourceDirectories -File -Filter *.ps1 -Recurse | Select-Object -ExpandProperty FullName
if ($BuildData.ContainsKey('Prefix') -and (Test-Path -Path $BuildData.Prefix)) {
    . $BuildData.Prefix
}
foreach ($Script in $Scripts) {
    . $Script
}
if ($BuildData.ContainsKey('Suffix') -and (Test-Path -Path $BuildData.Suffix)) {
    . $BuildData.Suffix
}

$SearchRecursive = $true
$SearchRootOnly  = $false
$PublicScriptBlock = [ScriptBlock]::Create('{0}' -f (Get-ChildItem -Path $BuildData.PublicFilter -ErrorAction SilentlyContinue -Recurse | Get-Content -Raw | Out-String))
$PublicFunctions = $PublicScriptBlock.Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]},$SearchRootOnly).Name
$PublicAlias = $PublicScriptBlock.Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.ParamBlockAst] }, $SearchRecursive) | Select-Object -ExpandProperty Attributes | Where-Object { $_.TypeName.FullName -eq 'Alias' } | ForEach-Object { $_.PositionalArguments.Value }

$ExportParam = @{}
if($PublicFunctions) {
    $ExportParam.Add('Function',$PublicFunctions)
}
if($PublicAlias) {
    $ExportParam.Add('Alias',$PublicAlias)
}
if($ExportParam.Keys.Count -gt 0) {
    Export-ModuleMember @ExportParam
}

Pop-Location -StackName 'DevModuleLoader'
