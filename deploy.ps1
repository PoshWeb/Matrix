<#
.SYNOPSIS
    `deploy.ps1`
.DESCRIPTION
    `deploy.ps1` deploys a website.

    This is a simple and helpful scripting convention for site deployment.

    Just run `./deploy.ps1`

    `./deploy.ps1` can deploy any way we want.

    This `./deploy.ps1` dynamically generates a static site.

    Feel free to copy and paste this code.
    
    Please document your parameters, and add NOTES.
.NOTES
    This deploys a static site by running any `*.*.ps1`.

    The output from each file will go into a corresponding file.

    For example:  `a.css.ps1` will output `a.css`

    * `*.html.ps1` files will be piped into `layout`
    * `*.json.ps1` files will be converted to `json`

    `html`, `json`, and `xml` files will be made into `index` files
    (unless `-Ugly` links are preferred)    
#>
[CmdletBinding(SupportsShouldProcess)]
param(
# An anlytics ID
[string]$AnalyticsID,

# The list of acceptable extensions
[string[]]
$AcceptableExtensions = @(
    'css',
    'md', 
    'html',
    'js',
    'json',    
    'svg',
    'xml'
),

# If set, will make "ugly" page links
# This will make `a.html.ps1` generate `a.html`, instead of `/a/index.html`
[switch]
$Ugly,

[string[]]
$IndexExtension = @('html','xml','json'),

# The root page url
[uri]
$PageUrl,

# The site root
[string]
$SiteRoot
)

# Know thyself
$mySelf = $MyInvocation.MyCommand

if (-not $SiteRoot) {
    $SiteRoot = $PSScriptRoot
}

# If there is no script root, 
if (-not $SiteRoot) {
    # error out.
    Write-Error "`$psScriptRoot is empty, Will not deploy"
    return
}

# Push into $psScriptRoot so everything is root relative.
Push-Location $PSScriptRoot

#region Map Parameters from Environment

# Look at our environment
foreach ($env in Get-ChildItem env:) {
    # See if any environment variables map to parameter 
    # (after we remove any punctuation from the name)
    $envName = $env.Name -replace '\p{P}'
    if (        
        # If they map
        $mySelf.Parameters[$envName] -and 
        # and are not already bound
        (-not $PSBoundParameters.ContainsKey($envName))
    ) {
        # set them
        $ExecutionContext.SessionState.PSVariable.Set(
            $envName,
            $(
                # If the value looks like json
                if ($env.Value -match '^\s{0,}[\[\{]') {
                    # convert it before we set the value.
                    ConvertFrom-Json -InputObject $env.Value
                }
                # If the value is a boolean string
                elseif ($env.Value -match '^true|false$') {
                    # convert it to a boolean
                    $evn.Value -match 'true'
                } 
                # Otherwise, directly map it.
                else {
                    $env.Value
                }
            )
        )
        # After we set the variable, map it into `$psBoundParameters`
        $PSBoundParameters[$envName] = 
            $ExecutionContext.SessionState.PSVariable.Get(
                $envName
            ).Value
    }
}
#endregion Map Parameters from Environment

# Configs, Layouts, and Pages all may require modules
# Make a little filter to import and install any module a script `#requires`.
filter requireModule {
    # Our input should be a file.
    $in = $_

    # Get the script at this location
    $command = Get-Command $in.FullName -CommandType ExternalScript
    # If that somehow failed, return
    if (-not $command) { return }

    # If the script has requirements
    foreach ($requirement in 
        $command.ScriptBlock.Ast.ScriptRequirements.RequiredModules
    ) {
        # Check if they are loaded
        $requiredModule = Get-Module -ErrorAction Ignore -Name $requirement.Name

        # If they are not,
        if (-not $requiredModule) {
            # try to load the requirement
            "Importing Requirement $($requirement.Name) for $($in.FullName)" |
                Out-Host
            
            $requiredModule = Import-Module $requiredModule -Force -PassThru -ErrorAction Ignore

            # If that did not work,
            if (-not $requiredModule) {
                "Installing Requirement $($requirement.Name)" | Out-Host
                Install-Module $requirement.Name -Scope CurrentUser -Force
                Import-Module $requirement.Name -Global -Force -PassThru  | 
                    Out-Host
            }                
        }
    }
}

# Get whatever local module exists
$psd1Path =    
    Get-ChildItem -Filter *.psd1 | 
        Select-String 'ModuleVersion' |
            Select-Object -ExpandProperty Path -First 1    

# If one was found
if ($psd1Path) {
    # import it
    "Importing $psd1Path" | Out-Host
    Import-Module $psd1Path -Force -PassThru | 
        Out-Host
}

# Check for a layout script.
$layout = Get-Command ./layout.ps1 -ErrorAction Ignore
if ($layout) {
    # Import any requirements it might have
    if ($layout.ScriptBlock.Ast.ScriptRequirements) {
        [IO.FileInfo]$layout.Source | . requireModule
    }
    # And alias it to `layout`.
    Set-Alias layout $layout.Source
}

# Any `$site` metadata can be stored in a dictionary
# Any of our parameters should be site wide metadata
$site = [Ordered]@{} + $PSBoundParameters
$Pages = [Ordered]@{}
$PagesByUrl = [Ordered]@{}

# A `config.ps1` file may do anything it wants to configure the site.

# If there is a `.config.ps1`
$configPs1 = Get-Command ./config.ps1 -ErrorAction Ignore
if ($configPs1) {
    # Import any requirements it might have
    if ($configPs1.ScriptBlock.Ast.ScriptRequirements) {
        [IO.FileInfo]$configPs1.Source | . requireModule
    }    
    . ./config.ps1 # and run it.
}

# We will be run any `*.*.ps1`(with an acceptable extension).

# The output from each script will go to the corresponding file.

# Declare some patterns we will use:
# * `$matchExtension` will tell us which extension
$matchExtension = '\.(?<x>[^\.]+)\.ps1$'
# * `$acceptablePattern` will ensure we only build file types we accept
$acceptablePattern = "\.(?>$($acceptableExtensions -join '|'))\.ps1$"
# * `$indexPattern` indicates which file types will become indeces.
$indexPattern = "\.(?>$($IndexExtension -join '|'))\.ps1$"

# Get all files that match our pattern
$files = @(
    Get-ChildItem -Path *.ps1 -File -Recurse |
        Where-Object Name -match $acceptablePattern
) |
    Sort-Object @{
        # We want to generate Markdown files first
        # because html files may include their result inline.
        Expression = {
            # So sort on any md files first
            $_.Name -match '\.md'
        }
        Descending = $true # in descending order
        # (so they are at the top of the pile)
    }, Fullname

# Prepare our progress bars
$progress = @{ID=Get-Random;Activity="Building Pages"}
$total = @($files).Length
$counter = 0

# Walk over each of our files
foreach ($in in $files) {
    $progress.PercentComplete = ++$counter * 100 / $total
    $progress.Status = $in.Name
    Write-Progress @progress    

    # import any requirements
    $in | . requireModule

    $inScript =
        $ExecutionContext.SessionState.InvokeCommand.GetCommand($in.FullName, 'ExternalScript')        

    # Make sure we can map the output extension
    $outputExtension = 
        if ($in -match $matchExtension) {
            $matches.x
        } else {
            # otherwise, warn and continue.            
            Write-Warning "Will not output $in without an extension"
            continue
        }

    # Default the title to the file name
    $FileName = $in.Name -replace $matchExtension
    $title = $FileName -replace '-', ' '
    $help = Get-Help $in.FullName -ErrorAction Ignore

    $meta = [Ordered]@{}
    foreach ($attr in $inScript.ScriptBlock.Attributes) {
        if ($attr.Key -and $attr.Value) {
            $meta[$attr.Key] = $attr.Value
        }
    }

    # and initialize any page metadata
    $page = [Ordered]@{
        Title = $title
        Command = $inScript
        File = $in
        FileName = $FileName
        Source = $inScript.ScriptBlock 
        Help = $help
        Meta = $meta
    }

    # Generate a file date by:
    $fileDate = $fileName -replace 
        # * Remove any non-digit (except colon, dash, and underscore, and Z)
        '[^\d:-_Z]' -replace
            # * Trim leading punctuation, and trailing punctuation (and Z), 
            '^\p{P}+' -replace '[-Z]+$' -replace
            # * replace underscores with colons, and try to cast to `[DateTime]`
            '_',':' -as [DateTime]
    
    # If we have a file date,
    if ($fileDate) {
        $page.Date = $fileDate #  set the `$Page.Date`
    } else {
        # otherwise, we'll try to get the date from git.
        $gitCommand = $ExecutionContext.SessionState.InvokeCommand.GetCommand('git', 'Application')
        if ($gitCommand) {
            $gitDates = 
                try {
                    # we can use `git log --follow --format=%ci` to get the dates in order
                    (& $gitCommand log --follow --format=%ci --date default $in.FullName *>&1) -as [datetime[]]
                } catch {
                    $null
                }
            # Because the file might not be in git, we want to always set the `$LASTEXITCODE` to 0
            $LASTEXITCODE = 0
            # Set the date to the last date we find.
            if ($gitDates) {
                $page.Date = $gitDates[-1]                
            }
        }
    }

    # If we map the output path _before_ we run our script
    # we can know what URL we will be publishing to.

    # Our output file path starts by replacing the .ps1
    $outputPath = $in.FullName -replace '\.ps1$'

    # If we do not care about "pretty" url format
    # or are not an extension that we can make into an index,
    # we do not need to change the file path
    if ((-not $Ugly) -and ($in.Name -match $indexPattern)) {
        # If we do, things get a little more complicated
        # We will want to special case some extensions we want to use as an index.        

        # If the name of the file matches the name of the directory
        if ($in.Name -match 
            "^$([Regex]::Escape($in.Directory.Name))$matchExtension"
        ) {
            # it will become an index of that directory.
            $outputPath = Join-Path $in.Directory "index.$outputExtension"
        } else {
            # otherwise, make it an index of it's own directory
            $outputPath =
                ($in.FullName -replace $matchExtension) +
                    "/index.$outputExtension" -replace
                        'index/index', 'index'
        }
    }

    # Now that we know our output path,
    # we can predict our url
    $page.Url = $outputPath -replace "^$(
        [Regex]::Escape($siteRoot) # just remove the site root
    )" -replace # replace any index with a slash
        '[\\/]index\.[^\.]+?$','/' -replace 
        '[\\/]', '/' # and fix any slashes.
            
    $page.OutputPath = $outputPath

    $page.Extension = $outputExtension
    # Get our page output
    $output = @(. $in.FullName)
    
    $page.Title = $title

    # Store our output in the page
    $page.Output = $output    

    # And put our page in two collections

    # One by output path (we will use this output)
    $Pages[$outputPath] = $page
    # and one by url
    $PagesByUrl[$page.Url] = $page
}

$progress.Activity = "Deploying Pages"
$total = $pages.Count
$counter = 0

foreach ($outputPath in $pages.Keys) {

    $progress.PercentComplete = ++$counter * 100 / $total
    $progress.Status = "$($page.Title) "
    Write-Progress @progress

    $page = $pages[$outputPath]
    $outputExtension = $page.Extension
    $output = $page.Output
    $outputFiles = @()
    $output = @(foreach ($out in $output) {
        if ($out -is [IO.FileInfo]) {
            $outputFiles += $out
        } else {
            $out
        }
    })    
    
    # If the output was a list of files
    if ($outputFiles -and -not $output) {
        # then do not write anything to disk
        $outputFiles
        continue
    }
    
    # If we have a layout file and are outputting html
    if ($layout -and (
        $page.File.FullName -replace '\.ps1$' -match '\.html$'
    )) {
        # Pipe our output to the layout script.
        # By doing this in a second pass,
        # our layout script can have much more context.
        $output = $output | layout
    }
    # Otherwise, if our output extension is xml
    # and we have only that one xml 
    elseif (($outputExtension -eq 'xml') -and
        ($output.Length -eq 1) -and 
        ($output[0] -is [xml])
    ) {
        # set our output to the outerXML.
        $output = $output.OuterXml
    }
    # Otherwise, if our output extension is json
    # and the output is not already a string
    elseif (($outputExtension -eq 'json') -and (
        $output[0] -isnot [string]
    )) {
        # convert it into json.
        # If there is one more than one item,
        if ($output.Length -gt 1) {
            # make it a list
            $output = $output | ConvertTo-Json -Depth (
                $FormatEnumerationLimit
            )
        } else {
            # If there is only one item, make it an object.
            $output = ConvertTo-Json -InputObject $output -Depth (
                $FormatEnumerationLimit
            )
        }
    }
    
    $outputFile = [Ordered]@{
        ItemType = 'File';Force = $true
        Value = $output -join [Environment]::NewLine
        Path = $outputPath
    }

    if ($WhatIfPreference) {
        $outputFile 
    } elseif ($PSCmdlet.ShouldProcess("Output $($outputPath)")) {
        New-Item @outputFile
    }
}

if ($PageUrl) {
    $sitemap = /_includes/sitemap -Url $pageUrl -Pages $PagesByUrl
    if ($sitemap) {
        $sitemap.Save((
            Join-Path $SiteRoot "sitemap.xml"
        ))
        Get-Item (Join-Path $SiteRoot "sitemap.xml")
    }
}

$progress.Remove('PercentComplete')
$progress.Completed = $true
Write-Progress @progress

Pop-Location