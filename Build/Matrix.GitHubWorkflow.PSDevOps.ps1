#requires -Module PSDevOps
param(
    $moduleName = $(
        $PSScriptRoot | Split-Path | Split-Path -Leaf
    )
)
Import-BuildStep -SourcePath (
    Join-Path $PSScriptRoot 'GitHub'
) -BuildSystem GitHubWorkflow


Push-Location ($PSScriptRoot | Split-Path)
New-GitHubWorkflow -Name "Build Module" -On Push,
    PullRequest, 
    Demand -Job  TestPowerShellOnLinux, 
    TagReleaseAndPublish, "Build$moduleName" -OutputPath .\.github\workflows\build.yml

Pop-Location