<#
.SYNOPSIS
    HTML Matrix
.DESCRIPTION
    Matrix in HTML.
#>
param()

@'
# HTML Matrix

Transformation Matrixes are broadly supported in HTML.

We can use Matrix to transform any element using it's style property.

We can use Matrix to write [CSS Compatible](/matrix/css/compatible) transforms.

There are numerous things we can do with SVG transforms.

For example, we can use a scale transform to give object apparent depth.

If we want an object to appear twice as far away, we can scale it down by 0.5.

If we want an object to appear four times as far away, we can scale it by 0.25.

The general formula for apparent distance scaling is:

~~~PowerShell
1/[Math]::Pow(2, `$scale - 1)
~~~

We can make any object look like it is Z away by applying a scale of that formula.

This page show some experiments with the technique.

To get things to overlap property, we need to put things into the same frame of reference.

We can do this with a little bit of css

~~~css
/* Make an overlapping grid */
.overlap {
    place-items: center; display: grid; grid-template-rows: 1fr; grid-template-columns: 1fr;        
}
/* Make every item in the grid be in row 1, column 1 */
.overlap * { 
    grid-row: 1;grid-column: 1;
}
~~~

The inner element's box helps determine how much space the grid will occupy.

Use an inline element, like ``<span>``, if we want the grid to occupy only one line of space.

'@ | ConvertFrom-Markdown | 
    Select-Object -ExpandProperty Html

@"
<style>
.overlap {
    place-items: center; display: grid; grid-template-rows: 1fr; grid-template-columns: 1fr;        
}
.overlap * { 
    grid-row: 1;grid-column: 1;
}
.clip {
    overflow: clip;
}

</style>
<div class='overlap' style='font-size: 10rem; transform-origin: 50% 50%'>       
    $(
        $scale = 1
        foreach ($scale in 1..8) {
            $scaleFactor = 1/[Math]::Pow(2,($scale - 1))
            "<span class='overlap-item' style='transform-origin:$(
                "300% 50%"
            );transform:$(
                (Scale $scaleFactor).CSS
            );'>$scale</span>"
        }                
    )    
</div>
"@


"If we want the overlapping grid to block off more space, Use a block element, like ``<h1>``" |
        ConvertFrom-Markdown | 
        Select-Object -ExpandProperty html

@"
<div class='overlap' style='font-size: 10rem; transform-origin: 50% 50%'>       
    $(
        $scale = 1
        foreach ($scale in 1..8) {
            $scaleFactor = 1/[Math]::Pow(2,($scale - 1))
            "<h1 class='overlap-item' style='transform-origin:$(
                "300% 50%"
            );transform:$(
                (Scale $scaleFactor).CSS
            );'>$scale</h1>"
        }                
    )    
</div>
"@


$lookAround = @"
@keyframes look-around {
    0%, 100% {
        transform-origin: 50% 50%;
    }
    20% {
        transform-origin: 0% 0%;
    }
    40% {
        transform-origin: 100% 0%;
    }
    60% {
        transform-origin: 0% 100%;
    }
    80% {
        transform-origin: 100% 100%;
    }    
}
.look-around {
    animation-name: look-around;
    animation-duration: 8.4s;
    animation-iteration-count: infinite;
}
"@


@"

## Looking Around

We can change where the scaling is centered by changing ``transform-origin``.

This means we can perform the same animated look around we can in [svg](/svg).

~~~css
$lookAround
~~~
"@ | ConvertFrom-Markdown | 
    Select-Object -ExpandProperty Html


"<style>$lookAround</style>"

@"

<div class='overlap' style='font-size: 20rem; transform-origin: 50% 50%'>       
    $(
        $scale = 1
        foreach ($scale in 1..8) {
            $scaleFactor = 1/[Math]::Pow(2,($scale - 1))
            "<h1 class='look-around' style='grid-row:1;grid-column:1;transform:$(
                (Scale $scaleFactor).CSS
            );opacity:$($scaleFactor)'>$scale</h1>"      
        }                
    )
    
</div>
"@


$zProp = "
@property --z {
    syntax: '<number>';
    inherits: true;
    initial-value: 1;
}
"

$zVar = @"
calc(
    1 / pow( 2,
        calc(
            var(--z) - 1
        )
    )
)
"@


@"

## z trick

Since there is a uniform method of scaling, we can simplify it in a CSS class or two.

If only there was some way for elements to let us know where they are in z space 🤔.

`z-index` will work, but it has some cannonical drawbacks:

1. `z-index` is an integer, not a number
2. A larger `z-index` is more visible, not less.

I believe a better approach is using a CSS `<number>` property to repesent z

~~~css
$zProp
~~~

With this property in hand, we can easily calculate a dynamic scale content.

~~~css
$zVar
~~~

Now we just need a class we can apply.

Let us call it `z`

~~~css
.z {
    transform: scale($zVar);
    opacity: $zVar
}
~~~

Putting it all together:

~~~css
$zProp
.z {
    transform: scale($zVar);
    opacity: $zVar
}
~~~

Let's see z trick in action:
"@ | 
    ConvertFrom-Markdown | 
    Select-Object -ExpandProperty Html

$zTrick = @"
$zProp
.z {
    transform: scale($zVar);
    opacity: $zVar
}


@keyframes z-move-down {
    from {
        transform-origin: 50% 50%;
    }
    to {
        transform-origin: 500% 500%;
    }
}

.z-move {
    animation-name: z-move-down;
    animation-iteration-count: infinite;
    animation-duration: 4.2s;        
}

$(
    foreach ($n in 1..8) {
        ".z-$n {--z: $n}"
    }
    foreach ($n in 1..8) {
        foreach ($percent in 25, 50, 75) {
            ".z-${n}-$percent {--z: $($n + $percent/100)}"
        }        
    }
)

"@

"<style>$zTrick</style>"
"<div class='overlap' style='font-size: 10rem;'>"
"<h1 class='z z-1 overlap-item' style='transform-origin:50% 50%'>1</h1>"
"<h1 class='z z-2 overlap-item' style='transform-origin:200% 50%'>2</h1>"
"<h1 class='z z-3 overlap-item' style='transform-origin:300% 50%'>3</h1>"
"<h1 class='z z-4 overlap-item' style='transform-origin:400% 50%'>4</h1>"
"</div>"
return