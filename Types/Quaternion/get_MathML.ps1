<#
.SYNOPSIS
    Matrix MathML
.DESCRIPTION
    Gets the Matrix as a MathML representation of itself.
.NOTES
    Also shows the equivalent `[Numerics.Matrtix4x4]`
#>
param()
[xml]@"
<math display='block'>
<mo>[</mo>
<mtable>
$(
    "<mtr>"
    foreach ($var in 'X','Y','Z','W') {
        "<mtd>"
            "<mi>$var</mi>"
            "<mo>:</mo>"
            "<mn>$($this.$var)</mn>"        
        "</mtd>"
    }
    "</mtr>"
)
</mtable>
<mo>]</mo>
<mo>=</mo>$(
    [Numerics.Matrix4x4]::CreateFromQuaternion($this).MathML.math.innerXml
)
</math>
"@

