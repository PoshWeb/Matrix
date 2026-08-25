<#
.SYNOPSIS
    CHANGELOG
.DESCRIPTION
    Matrix CHANGELOG
.NOTES
    Renders the CHANGLOG as html, with links to the repo.
#>
param(
[uri]
$RepositoryUrl = $(
    if ($env:GITHUB_REPOSITORY) {
        "https://github.com/$env:GITHUB_REPOSITORY"
    } else {
        "https://github.com/PoshWeb/Matrix"
    }
)    
)

$changelogPath = Join-Path $PSScriptRoot 'CHANGELOG.md'

$changeLog  = Get-Content $changelogPath -Raw

[Regex]::Replace(
    $changeLog,
    '#(?<n>\d+)',
    {
        param($match)
        "[$match]($(
            "$repositoryUrl" + '/issues/' + $match.Groups['n'].Value
        ))"
    }   
) | 
    ConvertFrom-Markdown | 
        Select-Object -ExpandProperty Html


