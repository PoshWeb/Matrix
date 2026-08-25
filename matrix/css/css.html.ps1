<#
.SYNOPSIS
    CSS Matrix
.DESCRIPTION
    Matrix in CSS  
.LINK
    https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/Matrix_math_for_the_web
.COMPONENT
    /matrix/css/
#>
param()

@'

# CSS Matrix

CSS loves matrix transformations!

Whenever we `rotate`, `scale`, or `translate`, we are using a matrix transform.

All those nice 3D effects?  Matrix transforms.

The `Matrix` module helps give us greater mastery of [matrix transformations](/matrix/css/transform/),
and gives us a way to make [css compatible](/matrix/css/compatible) transforms in PowerShell.

Matrix maps [dotnet](/matrix/dotnet/) to [css](/matrix/css/).

* `Matrix3x2` is a [CSS matrix()](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/transform-function/matrix)
* `Matrix4x4` is a [CSS matrix3d()](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/transform-function/matrix)

'@ |
    ConvertFrom-Markdown |
        Select-Object -ExpandProperty Html