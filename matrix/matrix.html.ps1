<#
.SYNOPSIS
    Matrix
.DESCRIPTION
    Matrix Transforms
.NOTES
    Currently just replicating the README within the layout
#>
[OutputType('text/html')]
param()

ConvertFrom-Markdown -Path (
    $PSScriptRoot | Split-Path | Join-Path -ChildPath 'README.md'
) -ErrorAction Ignore |
    Select-Object -ExpandProperty Html
