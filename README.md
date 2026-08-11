# Matrix
[![Matrix](https://img.shields.io/powershellgallery/dt/Matrix)](https://www.powershellgallery.com/packages/Matrix/)
## Matrix Transforms with PowerShell
Matrix math is tedious.  This module lets us avoid having to do it.

We can represent changes in space using a matrix.

|dimension|css function|.NET type|
|-|-|-|
|2D|`matrix()`|`[Numerics.Matrix3x2]`|
|3D|`matrix3d()`|`[Numerics.Matrix4x4]`|

In CSS, these are called [Transform Functions](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/transform-function)

The module allows you to make, modify, and use matrix transforms.

It supports almost identical syntax to the CSS.

We manipulate objects in 2D or 3d the same way a webpage would.

## Installing and Importing

You can install Matrix from the [PowerShell gallery](https://powershellgallery.com/)

~~~PowerShell
Install-Module Matrix -Scope CurrentUser -Force
~~~

Once installed, you can import the module with:

~~~PowerShell
Import-Module Matrix -PassThru
~~~


You can also clone the repo and import the module locally:

~~~PowerShell
git clone https://github.com/PoshWeb/Matrix/
cd ./Matrix
Import-Module ./ -PassThru
~~~

## Functions
Matrix has 1 function
### Get-Matrix
#### Matrix

Makes and Manipulates Matrix Transformations.

Matrix Transformations move objects in space.

Matrix makes matrixes in PowerShell.

This can transform objects in 2D, 3D, and 4D

We can use matrix to make CSS or transform Vectors.

<details>
<summary>Notes</summary>

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

</details>

<details open>
<summary>Aliases</summary>

- Matrix2d
- Matrix3d
- Matrix3x2
- Matrix4x4
- Rotate
- Rotate3d
- RotateX
- RotateY
- RotateZ
- Scale
- Scale3d
- ScaleX
- ScaleY
- ScaleZ
- Skew
- SkewX
- SkewY
- Translate
- Translate3d
- TranslateX
- TranslateY
- TranslateZ
</details>


<details open>
<summary>Examples</summary>

#### Example 1

Get the identity matrix.
This is the object, untransformed, in 2D
~~~PowerShell
Matrix Identity
~~~


#### Example 2

~~~PowerShell
Matrix3D 1
~~~


#### Example 3

Scale a point in 2d space by directly calling `::CreateScale`
~~~PowerShell
[Numerics.Vector2]::new(1,1) |
    Matrix 2 -Member CreateScale 1 2
~~~


#### Example 4

Scale a point in 2d space by using `scale`
~~~PowerShell
[Numerics.Vector2]::new(1,1) |
    Scale 1 2
~~~


#### Example 5

Skew a point
~~~PowerShell
[Numerics.Vector2]::new(1,1) |
    Skew 30deg 10deg
~~~


#### Example 6

Skew a point along X, then along Y
~~~PowerShell
[Numerics.Vector2]::new(1,1) |
    SkewX 30deg |
    SkewY 10deg
~~~


#### Example 7

~~~PowerShell
[Numerics.Vector2]::new(1,1) |
    ScaleZ 1
~~~


#### Example 8

Scale X in 2D
~~~PowerShell
[Numerics.Vector2]::new(1,1) |
    ScaleX 2
~~~


#### Example 9

Scale X in 3D
~~~PowerShell
[Numerics.Vector3]::new(1,1,1) |
    ScaleX 2
~~~


#### Example 10

Scale Y in 3D
~~~PowerShell
[Numerics.Vector2]::new(1,1) |
    ScaleY 2
~~~


#### Example 11

Scale Z in 3D
~~~PowerShell
[Numerics.Vector3]::new(1,1,1) |
    ScaleZ 3
~~~


#### Example 12

Move a point in 3d
~~~PowerShell
[Numerics.Vector3]::new(1,1,1) |
    TranslateX 3 |        
    TranslateY 3 |
    TranslateZ 3
~~~


#### Example 13

Move and scale a point in 3d
~~~PowerShell
[Numerics.Vector3]::new(1,1,1) |
    Translate3d 1 2 5 |
    Scale3d 3 2 1
~~~


#### Example 14

~~~PowerShell
[Numerics.Vector3]::new(1,1,1) |
    Translate3d 1 2 5 |
    Scale3d 3 2 1
~~~


#### Example 15

Rotate3d
~~~PowerShell
[Numerics.Vector3]::new(1,1,1) |
    Rotate3d 1 1 1 30deg
~~~


#### Example 16

rotate3d as a matrix3d, as CSS 
~~~PowerShell
(Rotate3d 1 1 1 30deg).css
~~~

</details>
<details open>
<summary>Parameters</summary>

|Name|Type|Description|
|-|-|-|
|ArgumentList|Object[]||
|InputObject|PSObject[]||
|Member|String||
</details>

<details open>
<summary>Links</summary>

* [system.numerics.matrix3x2](https://learn.microsoft.com/en-us/dotnet/api/system.numerics.matrix3x2?wt.mc_id=MVP_321542)
* [system.numerics.matrix4x4](https://learn.microsoft.com/en-us/dotnet/api/system.numerics.matrix4x4?wt.mc_id=MVP_321542)

</details>
