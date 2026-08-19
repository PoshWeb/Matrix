<#
.SYNOPSIS
    CSS Transforms
.DESCRIPTION
    We can transform any element with CSS.
.COMPONENT
    /matrix/css/
#>
param(
# The sample image
[string]$SampleImage = '/assets/dodge-matrix.gif',

# The duration of the sample image.
# This will be used as a base time for animations.
[TimeSpan]$SampleImageDuration = '00:00:01.8'
)

function markdown {
    @(
        if ($args) {
            $args
        }
        $allInput = @($input) 
        if ($allInput.Length) {
            $allInput
        }        
    ) -join [Environment]::NewLine | 
    ConvertFrom-Markdown | 
    Select-Object -ExpandProperty Html
}

markdown @"

# Matrix Transforms

## How to use Matrix transforms.

We can use Matrix transforms in two major ways:

* We can manipulate points using a Matrix
* We can use a matrix as a transform in CSS

This page demonstrates various animation transforms using Matrix.
"@


"<style>"
".grid-overlap { display: grid; grid-template-rows: 1fr; grid-template-columns: 1fr; place-items: center; }"
".left-right { display: flex; flex-direction: row; }"
".top-bottom { display: grid; grid-template-rows: auto auto;}"
"</style>"

markdown @"

### Mirroring

We can mirror two images by using a negative scale.

This can be done in CSS with the `scale()` function, which becomes a `matrix()`.

To mirror points along X, we can use:

~~~PowerShell
scale -1 1
~~~

"@

@"
<section class='grid-overlap'>
    <section class='left-right'>
        <img src='$SampleImage' style='transform:$(
            (Scale -1 1).Css
        );' />
        <img src='$SampleImage' style='transform:$(
            (Scale 1 1).Css
        );' />
    </section>
</section>
"@

"<p>This works horizontally and vertically</p>"

@"
<section class='grid-overlap'>
    <section class='top-bottom'>
        <img src='$SampleImage' style='transform:$(
            (Scale 1 1).Css
        );' />
        <img src='$SampleImage' style='transform:$(
            (Scale 1 -1).Css
        );' />
    </section>
</section>
"@


$QuadTopLeft        = ".quad-top-left     { transform: $((Scale -1 1).Css)}"
$QuadTopRight       = ".quad-top-right    { transform: $((Scale 1 1).Css)}"
$QuadBottomLeft     = ".quad-bottom-left  { transform: $((Scale -1 -1).Css)}"
$QuadBottomRight    = ".quad-bottom-right { transform: $((Scale 1 -1).Css)}"


@"
### Quad Mirror 

We can create a quad mirror effect by making four copies of an image.

~~~css
$QuadTopLeft
$QuadTopRight
$QuadBottomLeft
$QuadBottomRight
~~~
"@ |
    ConvertFrom-Markdown |
        Select-Object -ExpandProperty Html


"<style>
.quad { display: grid; grid-template-rows: auto auto; grid-template-columns: auto auto; gap: 0;}
$quadTopLeft
$quadTopRight
$quadBottomRight
$quadBottomLeft

</style>"
"<section class='grid-overlap'>"
    "<section class='top-bottom'>"
        "<section class='left-right'>"
            "<img src='$SampleImage' class='quad-top-left'></img>"
            "<img src='$SampleImage' class='quad-top-right'></img>"
        "</section>"
        "<section class='left-right'>"
            "<img src='$SampleImage' class='quad-bottom-left'></img>"
            "<img src='$SampleImage' class='quad-bottom-right'></img>"            
        "</section>"        
    "</section>"
"</section>"

"<style>"
foreach ($n in 0..3) {
    $animationName = "animatrix-rotate3d-$n"
    "@keyframes $animationName {
        0%, 100% { transform: $((ScaleZ 1).Css); opacity: 1; }
        50% { transform: $((ScaleZ -1).Css); opacity: 0.5; }
    }"
    ".$animationName {
        animation-name: $animationName;
        animation-iteration-count: infinite;
        animation-duration: $($SampleImageDuration.TotalSeconds)s;
    }"
}
"</style>"


$flipX = @"
@keyframes flip-x {
    from {
        transform: $((Scale 1 1).CSS)
    }
    to {
        transform: $((Scale -1 1).CSS)
    }
}
.flip-x {
    animation-name: flip-x;
    animation-duration: 3.6s;
    animation-iteration-count: infinite;
}
"@ 

$backFlipX = @"
@keyframes back-flip-x {
    from {
        transform: $((Scale -1 1).CSS)
    }
    to {
        transform: $((Scale 1 1).CSS)
    }
}
.back-flip-x {
    animation-name: back-flip-x;
    animation-duration: $($SampleImageDuration.TotalSeconds * 2)s;
    animation-iteration-count: infinite;
}
"@

@"
### Transform animations 

We can use transforms in CSS animations.

Just use @keyframes

~~~css
$flipX
$backFlipX
~~~
"@ | 
    ConvertFrom-Markdown | 
        Select-Object -ExpandProperty Html


"<style>"
$flipX
$backFlipX
"</style>"

"<section class='grid-overlap'>"
    
    "<section class='left-right'>"
        "<img src='$SampleImage' class='flip-x' />"    
        "<img src='$SampleImage' class='back-flip-x' />"
    "</section>"

"</section class='grid-overlap'>"

return
