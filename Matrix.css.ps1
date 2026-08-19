param(
[string]$PaletteName = 'cyberpunk',

# The Google Font name
[Alias('FontName')][string]$Font = 'Roboto',

# The Google Code Font name
[string]$CodeFont = 'CodeFont'
)

# Know thyself
$mySelf = $MyInvocation.MyCommand

# Any environment variables
foreach ($env in Get-ChildItem env:) {
    # that are parameter names
    if ($mySelf.Parameters[$env.Name] -and (
        # and are not already bound parameters
        -not $PSBoundParameters.ContainsKey($env:Name)
    )) {
        # are mapped to the variable
        $ExecutionContext.SessionState.PSVariable.Set(
            $env:Name,
            $env:Value
        )
    }
}


$body = @"
body {
    max-width:100%;
    height:100vh;
    font-family:'$Font', sans-serif
}
"@

$header = @"
header {
    display:grid;
    position:sticky;
    grid-area:header;
    grid-template-areas:"main-menu title options";
    grid-template-columns:1fr 3fr 1fr;
    transform-style:preserve-3d;
    top:0;
    left:0;
    max-width:100%;
    height:auto;
    z-index:10;
    margin:1rem;
    gap:0.5rem;
    background:color-mix(in srgb, var(--background) 25%, transparent)
}


.title > svg {
    display:block;
    text-align:center
}

.social {
    display:flex;
    flex-direction: column;
    grid-area:social
}
.title {
    grid-area:title;
    place-self:center;
    place-items:center;
    text-align:center
}
.options-menu {
    grid-area:options;
    text-align: right;
}
.options-menu > summary {    
    list-style-type: none    
}
.logo {
    display:block;
    width: 4.2rem;
    height:4.2rem;
}
.logo-text {
    text-align: center;
}
.main-menu {    
    grid-area: main-menu;
    list-style-type: none;
    display: flex;
    flex-direction: column;
}
.main-menu > summary {
    list-style-type: none
}
"@

$footer = @"
footer {
    display:grid;
    grid-area:footer;
    position:sticky;
    grid-template-rows:auto auto;
    width:100%;
    height:1vh;
    bottom:0;
    z-index:100
}
"@

$article = @"
article {
    background:color-mix(in srgb, var(--background) 50%, transparent)
}
"@

$popOver = @"
@keyframes fadeIn {
    from { opacity: 0; }
    to   { opacity: 1; }
}

[popover] {
    opacity: 0;
    animation: fadeIn 0.5s ease-in;
}
[popover]:popover-open {
    opacity: 1;
}

[popover] {
    color: var(--foreground);
    background-color: var(--background);
    a {
        color: var(--foreground)
    }
}
"@

$anchors = @"
a, a:visited { text-decoration:none }
a:hover, a:focus { text-decoration:underline }
"@

$portrait = @"
@media (orientation: portrait) {
    .row-or-column { flex-direction:column }
    .logo { height:2.3rem }
    .page-title, .site-title {
        font-size:0.84rem;
        line-height:0.66rem
    }
}
"@

$landscape = @"
@media (orientation: landscape) {
    .row-or-column { flex-direction:row }
    .logo { height:4.2rem }
    .site-title, .page-title {
        font-size:1.23rem;
        line-height:0.75rem
    }
}
"@

$viewAskew = @"
@keyframes view-askew {
    0%,100% { transform: $(
        (Scale 0.125 0.125).CSS
    )        
    }
    50% { transform: $(
        (Scale 1 1).CSS
    ) }
    
}

.viewAskew {
    animation-name: view-askew; 
    animation-iteration-count: 
    infinite; animation-duration: 7s; 
    transform-origin: 50% 50%
}
"@

$tables = @"
table { width: 100% }
"@

@"
$body

$anchors

$header

$footer

$article

$popover

$tables

$portrait

$landscape

$viewAskew

fieldset {
    border: 1px solid var(--foreground);    
    display: grid;
    place-items: center;
}

.foreground {
    display:grid;
    grid-template-rows:auto 1fr auto;
    grid-template-areas:"header" "main" "footer"
}

.main {
    grid-area:main;
    max-width:90%;
    margin-top:10rem;
    padding-left:5%;
    padding-right:5%;
    font-size:1.23em;
    line-height:1.5rem
}

pre, code {
    font-family:'$CodeFont', monospace
}

.row-or-column {
    flex-direction:row
}
"@

$scrollProgress = @"
@keyframes grow-progress {
    from { transform:scaleX(0) scaleY(0.5) }
    to { transform:scaleX(1) scaleY(1) }
}
.scroll-progress {
    width:100%;
    height:1rem;
    margin-top:auto;
    margin-bottom:auto;
    transform-origin:0 50%;
    background:linear-gradient(to right, transparent, var(--foreground));
    animation:grow-progress auto linear;
    animation-timeline:scroll()
}
"@

$scrollProgress


$highlightJSColors = @"
.hljs {
    background:color-mix(in srgb, var(--background) 75%, transparent);
    color:var(--foreground)
}
.hljs-number { color:var(--cyan) }
.hljs-type { color:var(--purple) }
.hljs-string { color:var(--brightWhite) }
.hljs-built_in { color:var(--brightBlue); font-weight:demibold }
.hljs-variable { color:var(--green); font-weight:demibold }
.hljs-comment { color:var(--brightGreen); font-weight:demibold }
.hljs-literal { color:var(--brightWhite) }
"@

$highlightJSColors