<#
.SYNOPSIS
    DotNet Matrix
.DESCRIPTION
    Matrix in DotNet
#>
param()

$matrixLinks = @{
    "Matrix3x2" = 
        '[[Numerics.Matrix3x2]](https://learn.microsoft.com/en-us/dotnet/api/system.numerics.matrix3x2?wt.mc_id=MVP_321542)'
    "Matrix3x2 Source" =
        '[[Numerics.Matrix3x2] source](https://github.com/microsoft/referencesource/blob/main/System.Numerics/System/Numerics/Matrix3x2.cs)'
    "Matrix4x4" = 
       '[[Numerics.Matrix4x4]](https://learn.microsoft.com/en-us/dotnet/api/system.numerics.matrix4x4?wt.mc_id=MVP_321542)'
    "Matrix4x4 Source" =
        '[[Numerics.Matrix4x4] source](https://github.com/microsoft/referencesource/blob/main/System.Numerics/System/Numerics/Matrix4x4.cs)'
    "Quaternion" =
        '[[Numerics.Quaternion]](https://learn.microsoft.com/en-us/dotnet/api/system.numerics.quaternion?wt.mc_id=MVP_321542)'
    "Quaternion Source" =
        '[[Numerics.Quaternion] source](https://github.com/microsoft/referencesource/blob/main/System.Numerics/System/Numerics/Quaternion.cs)'
}

ConvertFrom-Markdown -InputObject @"

# DotNet Matrix

This module would not be possible without the .NET framework.

.NET makes matrix math easy. 

Let's learn a bit about the dotnet matrix

## The DotNet Matrix

.NET provides three built-in types we can use to construct matrices:

* $($matrixLinks.'Matrix3x2')
* $($matrixLinks.'Matrix4x4')
* $($matrixLinks.'Quaternion')

Two of these map directly to CSS:

* `Matrix3x2` to a [CSS matrix()](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/transform-function/matrix)
* `Matrix4x4` to a [CSS matrix3d()](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/transform-function/matrix)

A `Quaternion` can be converted to a `Matrix4x4`, and thus can become a `matrix3d`

### The DotNet Matrix is Open Source

The DotNet core framework is open source, and so are the Matrix classes we use in this module.

They are well documented and fairly complete:

|Class|Source|
|-|-|
|$($matrixLinks.'Matrix3x2')|$($($matrixLinks.'Matrix3x2 Source'))|
|$($matrixLinks.'Matrix4x4')|$($($matrixLinks.'Matrix4x4 Source'))|
|$($matrixLinks.'Quaternion')|$($($matrixLinks.'Quaternion Source'))|

We can add, subtract, multiply and divide our matrices.
We can also use them to transform any `Vector2`, `Vector3`, or `Vector4`.

The Matrix module allows us to apply these transformations to an object pipeline of points in [PowerShell](/powershell/), 
using [css compatible](/css/compatible/) transforms.

"@ | 
    Select-Object -ExpandProperty Html

return
