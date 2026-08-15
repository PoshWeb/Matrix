param(
[string]$SampleImage = '/assets/dodge-matrix.gif'
)

$Title = 'Matrix Transforms'

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

"<h3>Quad Mirror</h3>"

"<style>.quad { display: grid; grid-template-rows: auto auto; grid-template-columns: auto auto; gap: 0;}</style>"
"<section class='grid-overlap'>"
    "<section class='top-bottom'>"
        "<section class='left-right'>"
            "<img src='$SampleImage' style='transform:$(
                (Scale -1 1).Css
            );' />"
            "<img src='$SampleImage' style='transform:$(
                (Scale 1 1).Css
            );' />"
        "</section>"
        "<section class='left-right'>"
            "<img src='$SampleImage' style='transform:$(
                (Scale -1 -1).Css
            );' />"
            "<img src='$SampleImage' style='transform:$(
                (Scale 1 -1).Css
            );' />"
        "</section>"        
    "</section>"
"</section>"

"<style>"
foreach ($n in 0..7) {
    $animationName = "animatrix-rotate3d-$n"
    "@keyframes $animationName {
        0%, 100% { transform: $((Rotate3d 1 1 1 "0deg").Css); opacity: 1; }
        50% { transform: $((Rotate3d 1 1 1 "$($n * -45)deg").Css); opacity: 0.5; }
    }"
    ".$animationName {
        animation-name: $animationName;
        animation-iteration-count: infinite;
        animation-duration: 1.8s;
    }"
}
"</style>"

"<h3>Transform animations</h3>"

"<section class='grid-overlap'>"
$(
    foreach ($n in 0..7) {
        $animationName = "animatrix-rotate3d-$n"
"<img src='$SampleImage' class='$animationName' style='grid-row: 1; grid-column: 1;' />"
    }
)
"</section>"

return
