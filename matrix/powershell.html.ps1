<#
.SYNOPSIS
    PowerShell Matrix
.DESCRIPTION
    Using Matrix in PowerShell
#>
$cubeTranslationExample = {
    # Constructing a cube using translation

    # Make a corner point
    $corner = [Numerics.Vector3]::new(1,1,1)

    # Make a square by translating along X and Y
    $square = @(
        $corner
        $corner | TranslateX 1  
        $corner | TranslateX 1 | TranslateY 1
        $corner | TranslateY 1
    )

    # Make a cube by translating the square along Z.
    $cube = @(
        $square
        $square |
            TranslateZ 1
    )

    $cube
}

@"


The Matrix module allows us to apply these transformations to a pipeline of points, using [css compatible](/css/compatible/) transforms.

For example, let's construct the points in a cube

~~~PowerShell
$($cubeTranslationExample)
~~~

This produces:
~~~
$(. $cubeTranslationExample | Out-String)
~~~

The capability can be very powerful.

It lets us take an object pipeline full of points and transform them any way we see fit.

It also allows us to calculate complex information without having to do the math.

"@ | 
    ConvertFrom-Markdown | 
    Select-Object -ExpandProperty Html
