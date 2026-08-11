<#
.SYNOPSIS
    Matrix 
.DESCRIPTION
    Makes and Manipulates Matrix Transformations.

    Matrix Transformations move objects in space.

    Matrix makes matrixes in PowerShell.

    This can transform objects in 2D, 3D, and 4D

    We can use matrix to make CSS or transform Vectors.
.NOTES
    Matrix math is hard, and this module lets us avoid having to do it.

    Instead, we can pipe objects into this module and transform them.

    A Matrix in .NET is the same as a Matrix in CSS.

    |css function|.NET type|
    |-|-|
    |`matrix()`|`[Numerics.Matrix3x2]`|
    |`matrix3d()`|`[Numerics.Matrix4x4]`|

    This means we can do every transformation that CSS can do.

    Any object piped with a `Transform` static method will be transformed.
    
    Other objects will be passed thru.    
.EXAMPLE
    # Get the identity matrix.
    # This is the object, untransformed, in 2D
    Matrix Identity
.EXAMPLE
    Matrix3D 1
.EXAMPLE
    # Scale a point in 2d space by directly calling `::CreateScale`
    [Numerics.Vector2]::new(1,1) |
        Matrix 2 -Member CreateScale 1 2
.EXAMPLE
    # Scale a point in 2d space by using `scale`
    [Numerics.Vector2]::new(1,1) |
        Scale 1 2
.EXAMPLE
    # Skew a point
    [Numerics.Vector2]::new(1,1) |
        Skew 30deg 10deg
.EXAMPLE
    # Skew a point along X, then along Y
    [Numerics.Vector2]::new(1,1) |
        SkewX 30deg |
        SkewY 10deg
.EXAMPLE
    [Numerics.Vector2]::new(1,1) |
        ScaleZ 1
.EXAMPLE
    # Scale X in 2D
    [Numerics.Vector2]::new(1,1) |
        ScaleX 2
.EXAMPLE    
    # Scale X in 3D
    [Numerics.Vector3]::new(1,1,1) |
        ScaleX 2
.EXAMPLE
    # Scale Y in 3D
    [Numerics.Vector2]::new(1,1) |
        ScaleY 2
.EXAMPLE
    # Scale Z in 3D
    [Numerics.Vector3]::new(1,1,1) |
        ScaleZ 3

.EXAMPLE
    # Move a point in 3d
    [Numerics.Vector3]::new(1,1,1) |
        TranslateX 3 |        
        TranslateY 3 |
        TranslateZ 3 
.EXAMPLE
    # Move and scale a point in 3d
    [Numerics.Vector3]::new(1,1,1) |
        Translate3d 1 2 5 |
        Scale3d 3 2 1
.EXAMPLE
    [Numerics.Vector3]::new(1,1,1) |
        Translate3d 1 2 5 |
        Scale3d 3 2 1
.EXAMPLE
    # Rotate3d
    [Numerics.Vector3]::new(1,1,1) |
        Rotate3d 1 1 1 30deg
.EXAMPLE
    # rotate3d as a matrix3d, as CSS 
    (Rotate3d 1 1 1 30deg).css 
#>
[Alias(
    'Matrix4x4',
    'Matrix3x2',
    'Matrix2d',
    'Matrix3d',
    'Skew',
    'SkewX',
    'SkewY',
    'Scale',
    'ScaleX',
    'ScaleY',
    'ScaleZ',
    'Scale3d',
    'Rotate',
    'RotateX',
    'RotateY',
    'RotateZ',
    'Rotate3d',
    'Translate',
    'Translate3d',
    'TranslateX',
    'TranslateY',
    'TranslateZ'
)]
[CmdletBinding(PositionalBinding=$false)]
param(
[Parameter(ValueFromRemainingArguments)]
[Alias('Arguments','Argument','Args')]
[object[]]
$ArgumentList,

[Parameter(ValueFromPipeline)]
[Alias('Input')]
[PSObject[]]
$InputObject,

[ArgumentCompleter({
    param(
        $CommandName, $parameterName, $wordToComplete,
        $commandAst, $fakeBoundParameters
    )    

    $firstElement = @($commandAst.CommandElements)[0]
    $members = 
        if ($firstElement -match '(?>3d|4x4)') {
            [Numerics.Matrix4x4].GetMembers('Static,Public').Name -notmatch '_'
        }
        else {
            [Numerics.Matrix3x2].GetMembers('Static,Public').Name -notmatch '_'
        }

    if ($wordToComplete) {
        $members -match "$([regex]::Escape($wordToComplete))"
    } else {
        $members
    }
})]
[string]
$Member = 'Create'
)

$myName = $MyInvocation.InvocationName

$allInput = @($input)

if (-not $allInput) {
    $allInput += $InputObject
}

$matrixType = 
    if ($myName -match '3d' -or $myName -match '4x4') {
        [Numerics.Matrix4x4]
    } else {
        [Numerics.Matrix3x2]
    }


# A quick little filter to convert css units into numbers.
filter cssunit {
    $arg = $_
    if ($arg -isnot [string]) {
        return $arg
    }
    switch -regex ($arg) {        
        'turn$' {
            # Each turn of the circle is 360 radians
            ($_ -replace 'turn$' -as [single]) * ([Math]::PI/180 * 360)
            continue
        }
        'deg$' {
            ($_ -replace 'deg$' -as [single]) * ([Math]::PI/180)
            continue
        }
        '%$' {
            ($_ -replace '%$' -as [single])
            continue
        }        
        '[\-\.\d]+\p{L}+' {
            $_ -replace '\p{L}+$' -as [single]
            continue
        }
        default {
            $_
        }
    }
}


$ArgumentList = @(
    $ArgumentList | cssunit    
)

$Matrix = $null

switch ($myName) {
    Rotate {        
        $MatrixType = [Numerics.Matrix3x2]
        $Member = 'CreateRotation'
        $ArgumentList = $ArgumentList[0]
    }
    RotateX {
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateRotationX'
        $ArgumentList = $ArgumentList[0]
    }
    RotateY {
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateRotationY'
        $ArgumentList = $ArgumentList[0]
    }
    RotateZ {
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateRotationZ'
        $ArgumentList = $ArgumentList[0]
    }
    Rotate3d {
        
        # https://drafts.csswg.org/css-transforms-2/#Rotate3dDefined
        
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'Create'
        $x, $y, $z, $null = $ArgumentList
        $normalize = [Numerics.Vector3]::new($x, $y, $z)
        $magnitude = $normalize.Length()
        if ($magnitude -eq 0) { $magnitude = [Math]::Sqrt(3) }
        $x, $y, $z = ($x/$magnitude), ($y/$magnitude), ($z/$magnitude)
        $x2, $y2, $z2 = [Math]::Pow($x, 2), [Math]::Pow($y,2), [Math]::Pow($z, 2)
        $alpha = $ArgumentList[3] -as [single]
        $sc = [Math]::Sin($alpha/2) * [Math]::Cos($alpha/2)
        $sq = [Math]::Pow([Math]::Sin($alpha/2), 2)                

        $ArgumentList = @(
            #M 1 1
            1 - (2 * ($y2 + $z2) * $sq)
            # M 1 2
            2 * (($x * $y * $sq) - ($z * $sc))
            # M 1 3
            2 * (($x * $z * $sq) + ($y * $sc))
            # M 1 4
            0

            
            # M 2 1
            2 * (($x * $y * $sq) + ($z * $sc))
            
            # M 2 2
            1 - (2 * ($x2 + $z2) * $sq)

            # M 2 3
            2 * (($y * $z * $sq) - ($x * $sc))

            # m 2 4
            0

            # M 3 1
            2 * (($x * $z * $sq) - ($y * $sc))

            # M 3 2
            2 * (($y * $z * $sq) + ($x * $sc))

            # M 3 3
            1.0 - (2 * ($x2 + $y2) * $sq)

            # M 3 4
            0

            # M 4 1
            0
            # M 4 2
            0
            # M 4 3
            0
            # M 4 4
            1
        )
        
    }
    Scale {
        $MatrixType = [Numerics.Matrix3x2]
        $Member = 'CreateScale'        
    }
    ScaleX {
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateScale'
        $ArgumentList = $ArgumentList[0], 1, 1
    }
    ScaleY {
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateScale'
        $ArgumentList = 1, $ArgumentList[0], 1
    }
    ScaleZ {
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateScale'
        $ArgumentList = 1, 1, $ArgumentList[0]
    }
    Scale3d {
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateScale'        
    }
    Skew {
        $MatrixType = [Numerics.Matrix3x2]
        $Member = 'CreateSkew'
        if ($ArgumentList.Length -eq 1) {
            $ArgumentList *= 2
        }
    }
    SkewX {
        $MatrixType = [Numerics.Matrix3x2]
        $Member = 'CreateSkew'
        if ($ArgumentList.Length -eq 1) {
            $ArgumentList = $ArgumentList[0], 0
        }
    }
    SkewY {
        $MatrixType = [Numerics.Matrix3x2]
        $Member = 'CreateSkew'
        if ($ArgumentList.Length -eq 1) {
            $ArgumentList = 0, $ArgumentList[0]
        }
    }
    Translate {
        $MatrixType = [Numerics.Matrix3x2]
        $Member = 'CreateTranslation'
    }
    Translate3d {
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateTranslation'
    }    
    TranslateX {
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateTranslation'
        $ArgumentList = @($ArgumentList[0], 0, 0)
    }
    TranslateY {
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateTranslation'
        $ArgumentList = @(0, $ArgumentList[0], 0)
    }
    TranslateZ {
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateTranslation'
        $ArgumentList = @(0, 0, $ArgumentList[0])
    }
}

if ($null -eq $matrixType::$Member) {
    return
}

if (-not $ArgumentList.Length) {
    if (-not $PSBoundParameters.Member) {return $matrixType } 
    else { return $matrixType::$member }   
}

if ($ArgumentList.Length -eq 1 -and 
    $matrixType::($ArgumentList[0])
) {
    $Member = 'identity'
}

if (-not $matrix) {
    $matrix = 
        if ($matrixType::$member.Invoke) {
            $matrixType::$Member.Invoke($ArgumentList)
        } else {
            $matrixType::$Member
        }
}


if ($allInput.Length -and ($null -ne $allInput[0])) {
    $3dMatrix  = 
        if ($matrix -is [Numerics.Matrix3x2]) {
            [Numerics.Matrix4x4]::Create($matrix)
        } else {
            $matrix
        }

    foreach ($in in $allInput) {
        if ($in::Transform) {
            $in::Transform($in, $3dMatrix)
        } else {
            $in
        }
    }
} else {
    $matrix
}

