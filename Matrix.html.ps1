<#
.SYNOPSIS
    Matrix Website
.DESCRIPTION
    Root of the Matrix Website
.NOTES
    Currently just replicating the README within the layout
#>
[OutputType('text/html')]
param()

$Title = 'Matrix'

ConvertFrom-Markdown -Path ./README.md -ErrorAction Ignore |
    Select-Object -ExpandProperty Html
