<#
.SYNOPSIS
    `layout.ps1`
.DESCRIPTION
    `layout.ps1` lays out a page.

    This is a simple and helpful scripting convention for web development.

    Just pipe to `./layout.ps1`

    A layout gives pages in a site a consistent way to render content

    `./layout.ps1` can layout content any way we want.

    This `./layout.ps1` places content within a standard frame.

    Feel free to copy and paste this code.
    
    Please document your parameters, and add NOTES.
.NOTES
    This layout makes use of a few includes and a custom CSS function.

    Includes are commands that directly output content, often in `html` or `svg`.

    * `/_includes/CopyCode' includes a copy code link
    * `/_includes/FeatherIcon` includes a feather icon
    * `/_includes/Palette` includes a color palette selector    

    
    These should be initialized prior to use.    
#>
param(
[uri]
$RepositoryUrl = $(
    if ($env:GITHUB_REPOSITORY) {
        "https://github.com/$env:GITHUB_REPOSITORY"
    } else {
        "https://github.com/PoshWeb/Matrix"
    }
),

[string]
$AnalyticsId,

[string]
$PaletteName = 'cyberpunk',

# The Google Font name
[Alias('FontName')]
[string]
$Font = 'Roboto',

# The Google Code Font name
[string]
$CodeFont = 'CodeFont',

# If set, will not include highlight js
[switch]
$NoHighlight,

[psobject]
$SiteMenu = $(
    [PSCustomObject]@{
        Matrix = [PSCustomObject]@{
            CSS = [PSCustomObject]@{
                "CSS Matrix" = '/matrix/css/'
                Compatibility = '/matrix/css/compatible/'
                Transforms = '/matrix/css/transform/'
            }
            HTML = [PSCustomObject]@{
                "HTML Matrix" = '/matrix/html/'
                "MathML Matrix" = '/matrix/mathml/'
                "SVG Matrix" = '/matrix/svg/'
            }            
            PowerShell = [PSCustomObject]@{
                DotNet = '/matrix/dotnet/'
                PowerShell = '/matrix/powershell/'
            }            
        }
    }
),

[string]
$SiteName = $(
    if ($env:GITHUB_REPOSITORY) {
        @($env:GITHUB_REPOSITORY -split '/', 2)[-1]
    } else {
        'Matrix'
    }
),

# The locale for the page.
# By default, the Current UI Culture.
[Alias('Locale')]
[cultureinfo]
$Culture = [CultureInfo]::CurrentUICulture,

[uri]
$PageUrl
)

# Gather all input using `$input` for maximum efficiency.
$allInput = @($input)

# Declare a filter to turn things into HTML.
filter toHtml {
    $in = $_

    # XML lives rent-free in HTML
    if ($in.OuterXml) {return $in.OuterXml}

    # Any object with an .html property 
    $inHtml = $in.Html            
    if ($inHtml) {
        # should render that property
        return $inHtml
    }
    
    "$in"            
}


# Know thyself
$mySelf = $MyInvocation.MyCommand

# Any environment variables
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


$head = @(
    # Analytics first (per recommendations)
    if ($AnalyticsId) {
        "<!-- Google tag (gtag.js) -->
        <script async src='https://www.googletagmanager.com/gtag/js?id=$($AnalyticsID)'></script>
        <script>
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('js', new Date());
            gtag('config', '$($AnalyticsID)');
        </script>"
    }
    # Basic viewport
    "<meta charset='utf-8' />"
    "<meta name='viewport' content='width=device-width, initial-scale=1, minimum-scale=1.0' />"

    # If a title was set
    if ($title) {
        # use it
        "<title>$(
            [Web.HttpUtility]::HtmlEncode($title)
        )</title>"
    }

    # If a palette name was provided
    if ($PaletteName) { 
        # link to the stylesheet
        "<link rel='stylesheet' href='https://cdn.jsdelivr.net/gh/2bitdesigns/4bitcss@latest/css/$PaletteName.css' id='palette' />"
    }

    if (-not $NoHighlight) {
        "<link rel='stylesheet' href='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/styles/default.min.css' id='highlight' />"
        '<script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/highlight.min.js"></script>'
        foreach ($language in 'css', 'svg', 'html','powershell') {
            "<script src='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/languages/$language.min.js'></script>"
        }
    }        

    if ($ExecutionContext.SessionState.InvokeCommand.GetCommand("/$SiteName.css", 'Alias,Function')) {
        if ($PageUrl) {
            "<link rel='stylesheet' href='/$SiteName.css' />"
        } else {
            "<style>"
            . "/$SiteName.css"
            "</style>"
        }
    }        
)

$body = @(
    "<section class='foreground'>"
        "<header>"
            "<details class='main-menu'>"
                "<summary>$(
                    /_includes/FeatherIcon -Icon menu
                )</summary>"
                "<article>"
                    "<li><a href='/' aria-label='Home'>$(
                        /_includes/FeatherIcon -Icon home
                    )</a></li>"
                    "<li><a href='$RepositoryUrl' aria-label='GitHub'>$(
                        /_includes/FeatherIcon -Icon github
                    )</a></li>"
                    /_includes/Menu $SiteMenu
                "</article>"
            "</details>"
            "<section class='title'>"
                if ($ExecutionContext.SessionState.InvokeCommand.GetCommand("/$siteName.svg", 'Alias,Function')) {
                    "<div class='grid'>"
                        "<div class='logo'>"
                            . "/$SiteName.svg"
                        "</div>"                    
                    "</div>"                    
                }
                "<h1 class='logo-text'>$siteName</h1>"
            "</section>"
            "<details class='options-menu'>"
                "<summary>$(/_includes/FeatherIcon settings)</summary>"
                "<fieldset><legend>Palette</legend>$(
                    /_includes/Palette -DefaultPalette $PaletteName
                )</fieldset>"                
            "</details>"        
            
        "</header>"
        "<section class='main'>"            
            @($allInput | toHtml) -join [Environment]::NewLine                
        "</section>"
        "<footer><section class='scroll-progress'></section></footer>"
    "</section>"
    /_includes/CopyCode
)


"<!DOCTYPE html>"
"<html lang='$($Culture)'>"
    "<head>$head</head>"
    "<body>$body</body>"
"</html>"