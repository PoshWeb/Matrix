<#
.SYNOPSIS
    README.md.ps1
.DESCRIPTION
    README.md.ps1 makes README.md

    This is a simple and helpful scripting convention for writing READMEs.

    `./README.md.ps1 > ./README.md`

    Feel free to copy and paste this code.
    
    Please document your parameters, and add NOTES.
.NOTES        
    This README.md.ps1 is used to generate help for a module.

    It:

    * Outputs the name and description
    * Provides installation instructions
    * Lists commands
    * Includes aliases
    * Includes notes
    * Lists parameters
    * Lists examples
    * Lists links
.EXAMPLE
    ./README.md.ps1 > ./README.md
.EXAMPLE
    Get-Help ./README.md.ps1
#>
param(
# The name of the module     
[string]$ModuleName = $($PSScriptRoot | Split-Path -Leaf),

# The domains that serve git repositories.
# If the project uri links to this domain, 
# installation instructions will show how to import the module locally.
[string[]]
$GitDomains = @(
    'github.com', 'tangled.org', 'tangled.sh', 'codeberg.org'
),

# A list of types the module exposes
[Alias('ModuleTypeNames','ModuleTypes')]
[string[]]
$ModuleTypeName = @(),

# If set, we don't need no badges.
[switch]
$NoBadge,

# If set, will not display gallery instructions or badges
[switch]
$NotOnGallery
)

Push-Location $PSScriptRoot

# Import the module
$module = Import-Module "./$ModuleName.psd1" -PassThru

# And output a header
"# $module"

if (-not $NoBadge) {
    # If it is on the gallery, show the downloads badge.
    if (-not $NotOnGallery) {        
        @(
            "[!"
                "[$ModuleName](https://img.shields.io/powershellgallery/dt/$ModuleName)"             
            "](https://www.powershellgallery.com/packages/$ModuleName/)"
        ) -join ''
    }    
}

# Show the module description
"## $($module.Description)"

# Show any intro section defined in the manifest
$module.PrivateData.PSData.PSIntro

#region Boilerplate installation instructions
if (-not $NotOnGallery) {
@"

## Installing and Importing

You can install $ModuleName from the [PowerShell gallery](https://powershellgallery.com/)

~~~PowerShell
Install-Module $($ModuleName) -Scope CurrentUser -Force
~~~

Once installed, you can import the module with:

~~~PowerShell
Import-Module $ModuleName -PassThru
~~~

"@
}
#endregion Gallery installation instructions

#region Git installation instructions
$projectUri = $module.PrivateData.PSData.ProjectURI -as [uri]

if ($projectUri.DnsSafeHost -in $GitDomains) {
@"

You can also clone the repo and import the module locally:

~~~PowerShell
git clone $projectUri
cd ./$ModuleName
Import-Module ./ -PassThru
~~~

"@
}
#endregion Git installation instructions

#region Exported Functions
$exportedFunctions = $module.ExportedFunctions

$uniqueFunctions = @()
$uniqueNames = @(foreach ($function in $exportedFunctions.GetEnumerator()) {    
    if ($uniqueFunctions -contains $function.Value.ScriptBlock) {
        continue         
    } else {
        $uniqueFunctions += $function.Value.ScriptBlock
    }
    $function.Key
})


if ($uniqueNames) {

    "## Functions"

    "$($ModuleName) has $($uniqueNames.Count) function$(
        if ($uniqueNames.Count -gt 1) { "s"}
    )"

    $duplicate = @()
    foreach ($export in $uniqueNames) {
        $exportedFunction = $exportedFunctions[$export]
        if ($duplicate -contains $exportedFunction.ScriptBlock) {
            continue
        } else {
            $duplicate += $exportedFunction.ScriptBlock
        }
        # Get help if it there is help to get
        $help = Get-Help $export
        # If the help is a string, 
        if ($help -is [string]) {
            # make it preformatted text
            "~~~"
            "$export"
            "~~~"
        } else {
            # Otherwise, add list the export
            "### $($export)"

            # And make it's synopsis a header
            "#### $($help.SYNOPSIS)"

            ""
            # put the description below that
            "$($help.Description.text -join [Environment]::NewLine)"
            ""

            $commandAliases = foreach ($aliasName in $module.ExportedAliases.Keys) {
                if ($module.ExportedAliases[$aliasName].ResolvedCommand.ScriptBlock -eq 
                    $exportedFunction.ScriptBlock) {
                    $aliasName
                }
            }

            $notes = $help.alertSet.alert.text

            if ($notes) {
                "<details>"
                "<summary>Notes</summary>"
                ""
                $notes -join [Environment]::NewLine
                ""
                "</details>"
            }
            
            if ($commandAliases) {
                ""
                "<details open>"
                "<summary>Aliases</summary>"
                ""
                foreach ($commandAlias in $commandAliases) {
                    "- $commandAlias"
                }
                "</details>"
                ""
                ""
                
            }            
            
            # Show our examples
            if ($help.examples.example) {
                "<details open>"
                "<summary>Examples</summary>"                                        

                $exampleNumber = 0
                foreach ($example in $help.examples.example) {
                    $markdownLines = @()
                    $exampleNumber++
                    $nonCommentLine = $false
                    ""
                    "#### Example $exampleNumber"
                    ""
                    
                    # Combine the code and remarks
                    $exampleLines = 
                        @(
                            $example.Code
                            foreach ($remark in $example.Remarks.text) {
                                if (-not $remark) { continue }
                                $remark
                            }
                        ) -join ([Environment]::NewLine) -split '(?>\r\n|\n)' # and split into lines

                    # Go thru each line in the example as part of a loop
                    $codeBlock = @(foreach ($exampleLine in $exampleLines) {
                        # Any comments until the first uncommentedLine are markdown
                        if ($exampleLine -match '^\#' -and -not $nonCommentLine) {
                            $markdownLines += $exampleLine -replace '^\#\s{0,1}'
                        } else {
                            $nonCommentLine = $true
                            $exampleLine
                        }
                    }) -join [Environment]::NewLine

                    $markdownLines
                    "~~~PowerShell"
                    $CodeBlock
                    "~~~"
                    ""
                }
                "</details>"
            }

            # Make a table of parameters
            if ($help.parameters.parameter) {
                "<details open>"
                
                "<summary>Parameters</summary>"

                ""                

                "|Name|Type|Description|"
                "|-|:-:|-|"
                foreach ($parameter in $help.Parameters.Parameter) {
                    "|$($parameter.Name)|$($parameter.type.name)|$(
                        $parameter.description.text -replace '(?>\r\n|\n)', '<br/>'
                    )|"
                }

                "</details>"
                ""
            }

            $relatedUris = foreach ($link in $help.relatedLinks.navigationLink) {
                if ($link.uri) {
                    $link.uri
                }
            }
            if ($relatedUris) {
                "<details open>"
                "<summary>Links</summary>"
                ""
                foreach ($related in $relatedUris) {
                    $relatedUri = $related -as [uri]
                    if ($relatedUri.DnsSafeHost -eq 'learn.microsoft.com' -and 
                        $relatedUri.LocalPath -match '/dotnet/api') {
                        "* [$($relatedUri.segments[-1] -replace '/') (Learn DotNet)]($related)"
                    } 
                    elseif ($relatedUri.DnsSafeHost -eq 'developer.mozilla.org' -and 
                        $relatedUri.LocalPath -match '/(?<ref>[^/]+)/reference') {
                        "* [$($matches.ref) $($relatedUri.segments[-1] -replace '/') (MDN)]($related)"
                    }
                    elseif ($relatedUri.DnsSafeHost -eq 'github.com') {
                        "* [$($relatedUri.Segments -replace '/', ' ') (GitHub)]($related)"
                    }
                    elseif ($relatedUri.DnsSafeHost) {
                        "* [$($relatedUri.DnsSafeHost)$($relatedUri.LocalPath)]($related)"
                    } else {
                        "* [$related]($related)"
                    }                    
                }
                ""
                "</details>"
            }
        }
    }
}
#endregion Exported Functions

Pop-Location