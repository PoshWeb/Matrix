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
    # Gets a 3d identity matrix
    # This is the object, untransformed, in 3d.
    Matrix3D Identity
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
.EXAMPLE
    # Constructing a cube using translation

    # Make a corner point
    $corner = [Numerics.Vector3]::new(1,1,1)

    # Make a square by translating along X and Y
    $square = @(
        $corner
        $corner | TranslateX 1
        $corner | TranslateY 1
        $corner | TranslateX 1 | TranslateY 1
    )

    # Make a cube by translating the square along Z.
    $cube = @(
        $square
        $square |
            TranslateZ 1
    )

    $cube
.LINK
    https://github.com/PoshWeb/Matrix
.LINK
    https://learn.microsoft.com/en-us/dotnet/api/system.numerics.matrix4x4?wt.mc_id=MVP_321542
.LINK
    https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/transform-function/matrix3D
.LINK
    https://learn.microsoft.com/en-us/dotnet/api/system.numerics.matrix3x2?wt.mc_id=MVP_321542
.LINK
    https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/transform-function/matrix
#>
[Alias(
    'Matrix4x4',
    'Matrix3x2',
    'Matrix2d',
    'Matrix3d',    
    'Quaternion',
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
# Any arguments for the transform function
# Arguments can include numbers of CSS units.
# `deg` and `turn` are converted into radians
# `%` becomes a value between 0 and 1 
[Parameter(ValueFromRemainingArguments)]
[Alias('Arguments','Argument','Args')]
[object[]]
$ArgumentList,

# Any input objects.
# If the input object has a `Transform` static method,
# it will be transformed.
# If it does not, it will be passed thru.
[Parameter(ValueFromPipeline)]
[Alias('Input')]
[PSObject[]]
$InputObject,

# The name of the method or property of a matrix transform.
# If this is provided, this method will be called instead.
# Many aliases, such as `Skew` or `Rotate`,
# will use a custom member and will ignore this parameter.
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
        elseif ($firstElement -match 'Quaternion') {
            [Numerics.Quaternion].GetMembers('Static,Public').Name -notmatch '_'
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

# Get our invocation name
$myName = $MyInvocation.InvocationName

# and all of our input
$allInput = @($input)

# If input was not piped
if (-not $allInput.Length) {
    # bind it to any unpiped input object
    $allInput += $InputObject
}

# Attempt to determine the matrix type.
$matrixType = 
    # If the name contains 3d or 4x4,    
    if ($myName -match '(?>3d|4x4)') {
        [Numerics.Matrix4x4] # treat it as a 3d matrix.
    } 
    elseif ($myName -match '(?>Quaternion|Versor)') {
        [Numerics.Quaternion]
    }
    else { # Otherwise
        [Numerics.Matrix3x2] # treat it as a 2d matrix.
    }

# Declare a  quick little filter to convert css units into numbers.
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

# Then convert all of our arguments into units
$ArgumentList = @(
    $ArgumentList | cssunit    
)

# Next we will be determine the right matrix transform
# Switch based off the name.
# Any matching CSS transforms should be their literal equivalent.
# These are _mostly_ self explanatory, with one _very_ annoying outlier
switch ($myName) {
    Rotate {
        # Rotate becomes `[Numerics.Matrix3x2]::CreateRotation`
        $MatrixType = [Numerics.Matrix3x2]
        $Member = 'CreateRotation'
        $ArgumentList = $ArgumentList[0]
    }
    RotateX {
        # RotateX becomes `[Numerics.Matrix4x4]::CreateRotationX`
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateRotationX'
        $ArgumentList = $ArgumentList[0]
    }
    RotateY {
        # RotateY becomes `[Numerics.Matrix4x4]::CreateRotationY`
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateRotationY'
        $ArgumentList = $ArgumentList[0]
    }
    RotateZ {
        # RotateZ becomes `[Numerics.Matrix4x4]::CreateRotationZ`
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateRotationZ'
        $ArgumentList = $ArgumentList[0]
    }
    Rotate3d {
        # Rotate3d is the complicated one.
        # It took some digging, but the CSS working defines rotate3d in matrix form
        # https://drafts.csswg.org/css-transforms-2/#Rotate3dDefined
        
        # It's a 4x4 matrix
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'Create'
        # that requires normalized vectors
        $x, $y, $z, $null = $ArgumentList
        # Sadly, this Normalize is different than .NET's Normalize
        $normalize = [Numerics.Vector3]::new($x, $y, $z)
        # We need to get the sum of all squares (the length)
        $magnitude = $normalize.Length()
        # If that sum was zero, make it the sqrt root of 3
        if ($magnitude -eq 0) { $magnitude = [Math]::Sqrt(3) }
        # Normalize x y z with the magnitude
        $x, $y, $z = ($x/$magnitude), ($y/$magnitude), ($z/$magnitude)
        # The formula requires each value squared, so do that now
        $x2, $y2, $z2 = [Math]::Pow($x, 2), [Math]::Pow($y,2), [Math]::Pow($z, 2)
        # It also defines the angle as `alpha`
        $alpha = $ArgumentList[3] -as [single]
        # And then uses this bit of trig to find a point in the unit circle 
        $sc = [Math]::Sin($alpha/2) * [Math]::Cos($alpha/2)
        # and this to find the max size of the square, given that angle
        $sq = [Math]::Pow([Math]::Sin($alpha/2), 2)                

        # This next bit of complexity is translated directly from the reference.
        # With spacing and docs added for clarity.
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

        # Every other CSS transform can be done in a few lines of PowerShell
        # This particular transform is the (quite painful) outlier.
    }
    Scale {
        # Scale becomes `[Numerics.Matrix3x2]::CreateScale`
        $MatrixType = [Numerics.Matrix3x2]
        $Member = 'CreateScale'
    }
    ScaleX {
        # `ScaleX` becomes `[Numerics.Matrix4x4]::CreateScale`
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateScale'
        $ArgumentList = $ArgumentList[0], 1, 1
    }
    ScaleY {
        # `ScaleY` becomes `[Numerics.Matrix4x4]::CreateScale`
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateScale'
        $ArgumentList = 1, $ArgumentList[0], 1
    }
    ScaleZ {
        # `ScaleZ` becomes `[Numerics.Matrix4x4]::CreateScale`
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateScale'
        $ArgumentList = 1, 1, $ArgumentList[0]
    }
    Scale3d {
        # `Scale3d` becomes `[Numerics.Matrix4x4]::CreateScale`
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateScale'        
    }
    Skew {
        # `Skew` becomes `[Numerics.Matrix3x2]::CreateSkew`
        $MatrixType = [Numerics.Matrix3x2]
        $Member = 'CreateSkew'
        if ($ArgumentList.Length -eq 1) {
            $ArgumentList *= 2
        }
    }
    SkewX {
        # `SkewX` becomes `[Numerics.Matrix3x2]::CreateSkew`
        $MatrixType = [Numerics.Matrix3x2]
        $Member = 'CreateSkew'
        if ($ArgumentList.Length -eq 1) {
            $ArgumentList = $ArgumentList[0], 0
        }
    }
    SkewY {
        # `SkewY` becomes `[Numerics.Matrix3x2]::CreateSkew`
        $MatrixType = [Numerics.Matrix3x2]
        $Member = 'CreateSkew'
        if ($ArgumentList.Length -eq 1) {
            $ArgumentList = 0, $ArgumentList[0]
        }
    }
    Translate {
        # `Translate` becomes `[Numerics.Matrix3x2]::CreateTranslation`
        $MatrixType = [Numerics.Matrix3x2]
        $Member = 'CreateTranslation'
    }
    Translate3d {
        # `Translate3d` becomes `[Numerics.Matrix4x4]::CreateTranslation`
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateTranslation'
    }    
    TranslateX {
        # `TranslateX` becomes `[Numerics.Matrix4x4]::CreateTranslation`
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateTranslation'
        $ArgumentList = @($ArgumentList[0], 0, 0)
    }
    TranslateY {
        # `TranslateY` becomes `[Numerics.Matrix4x4]::CreateTranslation`
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateTranslation'
        $ArgumentList = @(0, $ArgumentList[0], 0)
    }
    TranslateZ {
        # `TranslateZ` becomes `[Numerics.Matrix4x4]::CreateTranslation`
        $MatrixType = [Numerics.Matrix4x4]
        $Member = 'CreateTranslation'
        $ArgumentList = @(0, 0, $ArgumentList[0])
    }
}

# If we do not have a matching member
if ($null -eq $matrixType::$Member) {
    # error out
    Write-Error "$Member does not exist on $MatrixType"
    return
}

# If we have no arguments
if (-not $ArgumentList.Length) {
    # and no member, return the matrix type.
    if (-not $PSBoundParameters.Member) {return $matrixType } 
    # If we have no arguments and a member, return the member.
    else { return $matrixType::$member }   
}

# If the first argument is a static member
if ($ArgumentList.Length -eq 1 -and 
    $matrixType::($ArgumentList[0])
) {
    # use that as the member
    $Member = $ArgumentList[0]
}


# .Net does not provide a `Create` method for either matrix that accepts a matrix
if ($Member -eq 'Create' -and $ArgumentList[0] -is $matrixType) {
    # So take all of Matrix properties and make them arguments.
    $argumentList = foreach ($property in $ArgumentList[0].psobject.properties) {
        if ($property.Name -match '^M\d{2}') {
            $property.Value
        }
    }
}

# Create the matrix by invoking the member
# (or just returning the property)
$matrix = 
    if ($matrixType::$member.Invoke) {        
        $matrixType::$Member.Invoke($ArgumentList)
    } else {
        $matrixType::$Member
    }

# If we have any input
if ($allInput.Length -and ($null -ne $allInput[0])) {
    # Make a 3d variation of our matrix
    $3dMatrix  =
        if ($matrix -is [Numerics.Matrix3x2]) {        
            [Numerics.Matrix4x4]::Create($matrix)
        } 
        elseif ($matrix -is [Numerics.Quaternion]) {
            [Numerics.Matrix4x4]::CreateFromQuaternion($matrix)
        }
        else {
            $matrix
        }

    # Walk over all of our input
    foreach ($in in $allInput) {
        # If the input is transformable
        if ($in::Transform.Invoke) {
            # transform the input.
            $in::Transform($in, $3dMatrix)
        } else {
            # Otherwise, pass the input thru.
            $in
        }
    }
} else {
    # If we had no input, output the matrix.
    $matrix
}