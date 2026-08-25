<#
.SYNOPSIS
    MathML Matrix
.DESCRIPTION
    Matrix and MathML
#>
[OutputType('text/html')]
param()


@'

## MathML Matrix

A Matrix is just Math.

MathML can show math inside of HTML.

To show a matrix as a MathML matrix, we just need to access the `.MathML` property.

~~~PowerShell
(Scale3d 3 2 1).MathML
~~~

'@ |
    ConvertFrom-Markdown |
        Select-Object -ExpandProperty Html

(Scale3d 3 2 1).MathML


@'

### Matrix3x2

A 2D Matrix (`Matrix3x2`) can be mapped to a 3D Matrix (`Matrix4x4`).

When we show a 2D Matrix's MathML, we show both the `matrix` and and it's equivalent `matrix3d`

~~~PowerShell
(Scale 1 2).MathML
~~~
'@ |
    ConvertFrom-Markdown |
        Select-Object -ExpandProperty Html

(Scale 1 2).MathML

@'

### Quaternion

A Quaternion (`[Numerics.Quaternion]`) can be mapped to a 3D Matrix (`[Numerics.Matrix4x4]`).

When we show a Quaternion's MathML, we show both the `[Numerics.Quaternion]` and and it's equivalent `matrix3d`

~~~PowerShell
(Quaternion Identity).MathML
~~~
'@ |
    ConvertFrom-Markdown |
        Select-Object -ExpandProperty Html

(Quaternion Identity).MathML

@'

### MathML in HTML

MathML obviously works fine in html.

We can also preview the matrix by accessing another property: `.html`

~~~PowerShell
(Scale3d 3 2 1).Html
~~~

By default, this will show the matrix twice.

Once in it's original form, and once transformed by itself.

'@ |
    ConvertFrom-Markdown |
        Select-Object -ExpandProperty Html

(Scale3d 3 2 1).Html


@'

A Matrix3x2 and a Quaternion can both be converted to a Matrix4x4

We show the equivalent matrix side by side 

~~~PowerShell
(Scale 1 0.5).MathML
(Quaternion 0.5 0.5 0.5 1).MathML
~~~
'@ |
    ConvertFrom-Markdown |
        Select-Object -ExpandProperty Html


(Scale 1 0.5).MathML

(Quaternion 0 0 0 1).MathML

@'

We can also attach our own .Content property to the matrix:

~~~PowerShell
Scale -1 1 | 
    Add-Member NoteProperty Content "<h3>Backwards</h3>" -Force -PassThru |
        Select-Object -ExpandProperty Html
~~~
'@ | 
    ConvertFrom-Markdown |
        Select-Object -ExpandProperty Html


Scale -1 1 | 
    Add-Member NoteProperty Content "<h3>Backwards</h3>" -Force -PassThru |
        Select-Object -ExpandProperty Html