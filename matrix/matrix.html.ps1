<#
.SYNOPSIS
    Matrix
.DESCRIPTION
    Transform Matrices in PowerShell
.NOTES
    Currently just replicating the README within the layout
#>
[OutputType('text/html')]
param()

$Title = 'Matrix'

ConvertFrom-Markdown -Path (
    $PSScriptRoot | Split-Path | Join-Path -ChildPath 'README.md'
) -ErrorAction Ignore |
    Select-Object -ExpandProperty Html
