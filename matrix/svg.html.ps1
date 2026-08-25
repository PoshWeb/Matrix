<#
.SYNOPSIS
    SVG Matrix 
.DESCRIPTION
    Using Matrix in SVG.
#>
function copyz {
    param(
    [int]
    $StepCount = 4,

    [double]
    $InitialScale = 1,

    [double]
    $FinalScale = 9,

    [string]
    $Element = 'rect',

    [string[]]
    $Attribute,

    [string[]]
    $Children
    )

    if (-not $StepCount) {
        $stepCount = 1
    }

    $attribute += @(
        "fill='transparent'"
        "stroke='currentColor' class='foreground-stroke'"
        "x='0%' y='0%'"
        "width='100%' height='100%'"
        "transform-origin='50% 50%'"
    )
    
    $scaleStep = ($FinalScale - $InitialScale)/$StepCount    
    for ($scale = $InitialScale; [Math]::Abs($scale) -lt [Math]::Abs($FinalScale); $scale += $scaleStep) {
        $scaleFactor = 1/[Math]::Pow(2,($scale - 1))

        "<$element$(
            if ($Attribute) {
                " $attribute"
            }    
        )$(
            " transform='$((Scale $scaleFactor).CSS)'"
        )>$($Children -join [Environment]::Newline)</$element>"
    }    
}

# copyz

# return 

@"

# SVG Matrix

SVG is a web native standard for scalable vector graphics.

We can use Matrix to make transforms embedded in an SVG.

SVG transforms can be applied a few ways:

* [Transform Attribute](https://developer.mozilla.org/en-US/docs/Web/SVG/Reference/Attribute/transform)
* [GradientTransform Attribute](https://developer.mozilla.org/en-US/docs/Web/SVG/Reference/Attribute/gradientTransform)
* [PatternTransform Attribute](https://developer.mozilla.org/en-US/docs/Web/SVG/Reference/Attribute/patternTransform)

These transforms tend to be limited to a 3x2 matrix (though technically should support both).

We can always set use the [style attribute](https://developer.mozilla.org/en-US/docs/Web/SVG/Reference/Attribute/style) to provide a custom style,
or use the [class](https://developer.mozilla.org/en-US/docs/Web/SVG/Reference/Attribute/style) attribute to style our SVG using CSS.

There are numerous things we can do with SVG transforms.

For example, we can use a scale transform to give object apparent depth.

If we want an object to appear twice as far away, we can scale it down by 0.5.

If we want an object to appear four times as far away, we can scale it by 0.25.

The general formula for apparent distance scaling is:

~~~PowerShell
1/[Math]::Pow(2, `$scale - 1)
~~~

We can think of this a step function.

~~~PowerShell
function copyz {$(
    (Get-Command copyz).ScriptBlock    
)}
~~~

"@ | ConvertFrom-Markdown | 
    Select-Object -ExpandProperty Html

"<style>"
".svg-sample-grid { 
    display: grid; place-items: center; grid-template-columns: repeat(auto-fit, 1fr);
}"
".demo-svg { width: 64rem; height: 64rem; }"
"</style>"

"<section class='svg-sample-grid'>"

"<h3>4 steps</h3>"
@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>       
    $(copyz 4)    
</svg>
"@

"<h3>8 steps</h3>"
@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>       
    $(copyz 8)
</svg>
"@

"<h3>16 steps</h3>"

@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>
    $(copyz 16)       
</svg>
"@
    

"<h3>32 steps</h3>"

@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>       
    $(copyz 32)    
</svg>
"@

"<h3>64 steps</h3>"

@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>       
    $(copyz 64)
</svg>
"@
    
"<h3>128 steps</h3>"

$128Steps = @"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>       
    $(copyz 128)
</svg>
"@

$128Steps


"<h3>As the steps increase, the object seems deeper</h3>"

"<p>Drawing diagonals might help understand what is happenning</p>"

"<p>The center of the X is the center of our perpsective</p>"

@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>       
    <line stroke='currentColor' x1='0%' y1='0%' x2='100%' y2='100%' />
    <line stroke='currentColor' x1='0%' y1='100%' x2='100%' y2='0%' />
    $(copyz 64)    
</svg>
"@

"<h3>transform-origin</h3>"

"<p>Changing our <pre>transform-origin</pre> changes the center of the effect</p>"        

foreach ($origin in '0% 0%', '100% 0%', '0% 100%', '100% 100%') {
@"

<p><pre>transform-origin:$origin</pre></p>

<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>    
$(if ($origin -eq '50% 50%') {
    "<line stroke='currentColor' x1='0%' y1='0%' x2='100%' y2='100%' />
    <line stroke='currentColor' x1='0%' y1='100%' x2='100%' y2='0%' />"
})
    
    $(
        $scale = 1
        foreach ($scale in 1..8) {
            $scaleFactor = 1/[Math]::Pow(2,($scale - 1))
            "<rect stroke='currentColor' fill='transparent' x='0%' y='0%' width='100%' height='100%' transform-origin='$origin' transform='$(
                (Scale $scaleFactor).CSS
            )' />"
        }
    )    
</svg>
"@
}

"<h3>Transform Origin Animation</h3>"

"<p>We can animate our transform origin with CSS keyframes</p>"

$lookUpAndDown = @"
@keyframes look-up-and-down {
    0%, 100% {
        transform-origin: 50% 50%;
    }
    33% {
        transform-origin: 50% 25%;
    }
    66% {
        transform-origin: 50% 75%;
    }    
}
.look-up-and-down {
    animation-name: look-up-and-down;
    animation-duration: 4.2s;
    animation-iteration-count: infinite;
}
"@

"<pre><code class='language-css'>
$lookUpAnddown
</code></pre>"

@"
<style>
$lookUpAndDown
</style>
"@

@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>       
    $(
        copyz -Attribute "class='look-up-and-down'" -StepCount 64
    )    
</svg>
"@

"<p>We can look left and right</p>"

$lookLeftAndRight = @"
@keyframes look-left-and-right {
    0%, 100% {
        transform-origin: 50% 50%;
    }
    33% {
        transform-origin: 25% 50%;
    }
    66% {
        transform-origin: 75% 50%;
    }    
}
.look-left-and-right {
    animation-name: look-left-and-right;
    animation-duration: 4.2s;
    animation-iteration-count: infinite;
}
"@

"<pre><code class='language-css'>
$lookLeftAndRight
</code></pre>"

@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>       
    $(
        copyz -Attribute "class='look-left-and-right'" -StepCount 64        
    )    
</svg>
"@

"<p>We can look around</p>"

$lookAround = @"
@keyframes look-around {
    0%, 100% {
        transform-origin: 50% 50%;
    }
    $([Math]::Round(1/5,4) * 100)% {
        transform-origin: 25% 25%;
    }
    $([Math]::Round(2/5,4) * 100)% {
        transform-origin: 75% 25%;
    }
    $([Math]::Round(3/5,4) * 100)% {
        transform-origin: 25% 75%;
    }
    $([Math]::Round(4/5,4) * 100)% {
        transform-origin: 75% 75%;
    }    
}
.look-around {
    animation-name: look-around;
    animation-duration: 8.4s;
    animation-iteration-count: infinite;
}
"@

"<style>$lookAround</style>"

"<pre><code class='language-css'>
$lookAround
</code></pre>"

@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>       
    $(
        copyz -Attribute "class='look-around'" -StepCount 64        
    )    
</svg>
"@


"<h3>Motion</h3>"

"<p>We can animate the transform to give us motion</p>"

@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>       
    $(
        $scale = 1
        for ($scale = 1; $scale -lt 9; $scale += 0.125) {
            $scaleFactor = 1/[Math]::Pow(2,($scale - 1))
            "<rect stroke='currentColor' fill='transparent' x='0%' y='0%' width='100%' height='100%' transform-origin='50% 50%'>"
            "<animateTransform attributeName='transform' type='scale' values='1;$scaleFactor;1' dur='4.2s' repeatCount='indefinite' />"
            "</rect>"
        }                        
    )    
</svg>
"@

"<p>If we scale from our factor to 1, the object seems to get closer</p>"

@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>       
    $(
        $scale = 1
        for ($scale = 1; $scale -lt 9; $scale += 0.125) {
            $scaleFactor = 1/[Math]::Pow(2,($scale - 1))
            "<rect stroke='currentColor' fill='transparent' x='0%' y='0%' width='100%' height='100%' transform-origin='50% 50%'>"
            "<animateTransform attributeName='transform' type='scale' values='$scaleFactor;1' dur='4.2s' repeatCount='indefinite' />"
            "</rect>"
        }                        
    )    
</svg>
"@

"<p>If we scale from 1 to our factor, the object seems to get farther away</p>"

@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>       
    $(
        $scale = 1
        for ($scale = 1; $scale -lt 9; $scale += 0.125) {
            $scaleFactor = 1/[Math]::Pow(2,($scale - 1))
            "<rect stroke='currentColor' fill='transparent' x='0%' y='0%' width='100%' height='100%' transform-origin='50% 50%'>"
            "<animateTransform attributeName='transform' type='scale' values='1;$scaleFactor' dur='4.2s' repeatCount='indefinite' />"
            "</rect>"
        }                        
    )    
</svg>
"@

"<p>We can also transform the element itself, with all of our inner transforms intact</p>"


"<style>.rotated-demo { transform: $((Rotate3d 1 1 1 45deg).CSS)}</style>"
@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg rotated-demo' width='100%' height='100%' transform-origin='50% 50%' >
    $(
        $scale = 1
        for ($scale = 1; $scale -lt 9; $scale += 0.125) {
            $scaleFactor = 1/[Math]::Pow(2,($scale - 1))
            "<rect stroke='currentColor' fill='transparent' x='0%' y='0%' width='100%' height='100%' transform-origin='50% 50%'>"
            "<animateTransform attributeName='transform' type='scale' values='1;$scaleFactor' dur='4.2s' repeatCount='indefinite' />"
            "</rect>"
        }
    )
</svg>
"@

"<p>We can animate this, too</p>"

"<style>
@keyframes spinning-demo {
    0% { 
        transform: $((Rotate3d 1 1 1 0deg).CSS)
    }    
    50% {
        transform: $((Rotate3d 1 1 1 180deg).CSS)
    }    
    100% {
        transform: $((Rotate3d 1 1 1 360deg).CSS)
    }
}
.spinning-demo {
    animation-name: spinning-demo;
    animation-duration: 4.2s;
    animation-iteration-count: infinite;
}
</style>"

@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg spinning-demo' width='100%' height='100%' transform-origin='50% 50%' >
    $(
        $scale = 1
        for ($scale = 1; $scale -lt 9; $scale += 0.125) {
            $scaleFactor = 1/[Math]::Pow(2,($scale - 1))
            "<rect stroke='currentColor' fill='transparent' x='0%' y='0%' width='100%' height='100%' transform-origin='50% 50%'>"
            "<animateTransform attributeName='transform' type='scale' values='1;$scaleFactor' dur='4.2s' repeatCount='indefinite' />"
            "</rect>"
        }
    )
</svg>
"@

"<p>We can also animate our transform-origin as we animate our transform</p>"

"<p>Let's revisit our lookaround examples, with some added motion</p>"

@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>       
    $(
        $scale = 1
        for ($scale = 1; $scale -lt 9; $scale += 0.125) {
            $scaleFactor = 1/[Math]::Pow(2,($scale - 1))
            "<rect stroke='currentColor' class='look-around' fill='transparent' x='0%' y='0%' width='100%' height='100%' transform-origin='50% 50%'>"
            "<animateTransform attributeName='transform' type='scale' values='1;$scaleFactor;1' dur='4.2s' repeatCount='indefinite' />"
            "</rect>"
        }                        
    )    
</svg>
"@

@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>       
    $(
        $scale = 1
        for ($scale = 1; $scale -lt 9; $scale += 0.125) {
            $scaleFactor = 1/[Math]::Pow(2,($scale - 1))
            "<rect stroke='currentColor' class='look-left-and-right' fill='transparent' x='0%' y='0%' width='100%' height='100%' transform-origin='50% 50%'>"
            "<animateTransform attributeName='transform' type='scale' values='1;$scaleFactor;1' dur='4.2s' repeatCount='indefinite' />"
            "</rect>"
        }                        
    )
</svg>
"@

@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>       
    $(
        $scale = 1
        for ($scale = 1; $scale -lt 9; $scale += 0.125) {
            $scaleFactor = 1/[Math]::Pow(2,($scale - 1))
            "<rect stroke='currentColor' class='look-up-and-down' fill='transparent' x='0%' y='0%' width='100%' height='100%' transform-origin='50% 50%'>"
            "<animateTransform attributeName='transform' type='scale' values='1;$scaleFactor;1' dur='4.2s' repeatCount='indefinite' />"
            "</rect>"
        }                        
    )    
</svg>
"@


@"
### Circles

We can perform this magic trick with any shape.

Using `<circle>` instead of `<rect>` produces some interesting results.
"@ | 
    ConvertFrom-Markdown |
        Select-Object -ExpandProperty Html



@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>    
    $(            
        copyz -Attribute @(
            "cx='50%'"
            "cy='50%'"
            "r='25%'"
        ) -StepCount 32 -Element circle
    )
</svg>
"@        

"<p>We can also look up and down</p>"

@"
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>    
    $(            
        copyz -Attribute @(
            "class='look-up-and-down'"
            "cx='50%'"
            "cy='50%'"
            "r='25%'"
        ) -StepCount 64 -Element circle                            
    )
</svg>
"@

"<p>Or look left and right</p>"

@"
<style>
@keyframes look-left-and-right {
    0%, 100% {
        transform-origin: 50% 50%;
    }
    33% {
        transform-origin: 25% 50%;
    }
    66% {
        transform-origin: 75% 50%;
    }    
}
.look-left-and-right {
    animation-name: look-left-and-right;
    animation-duration: 4.2s;
    animation-iteration-count: infinite;
}

</style>
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>    
    $(
        copyz -Attribute @(
            "class='look-left-and-right'"
            "cx='50%'"
            "cy='50%'"
            "r='25%'"
        ) -StepCount 64 -Element circle
    )
</svg>

"@


$lookFarLeftAndRight = @"
@keyframes look-far-left-and-right {
    0%, 100% {
        transform-origin: 50% 50%;
    }
    33% {
        transform-origin: -25% 50%;
    }
    66% {
        transform-origin: 125% 50%;
    }    
}
.look-far-left-and-right {
    animation-name: look-far-left-and-right;
    animation-duration: 4.2s;
    animation-iteration-count: infinite;
}
"@


@"

We can use a transform-origin that exceeds 100%.

This will make things appear outside of their original bounds.

When animated, this can look like we are moving outside the original object.

~~~css
$lookFarLeftAndRight
~~~

"@ |
    ConvertFrom-Markdown | 
        Select-Object -ExpandProperty Html

@"
<style>
$lookFarLeftAndRight
</style>
<svg xmlns='http://www.w3.org/2000/svg' class='demo-svg' width='100%' height='100%' transform-origin='50% 50%'>    
    $(
        copyz -Attribute @(
            "class='look-far-left-and-right'"
            "cx='50%'"
            "cy='50%'"
            "r='25%'"
        ) -StepCount 64 -Element circle
    )
</svg>
"@

"</section>"

return