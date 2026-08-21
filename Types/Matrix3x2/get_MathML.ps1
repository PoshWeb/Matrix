<#
.SYNOPSIS
    Matrix MathML
.DESCRIPTION
    Gets the Matrix as a MathML representation of itself.    
#>
[xml]@"
<math display='block'>
    <mo>[</mo>
    <mtable>
    $(
        foreach ($row in 1..3) {
            "<mtr>"
            foreach ($col in 1..2) {
                "<mtd><mn>$($this."M${row}${col}")</mn></mtd>"
            }
            "</mtr>"
        }
    )
    </mtable>
    <mo>]</mo>
    <mo>=</mo>$(
        [Numerics.Matrix4x4]::Create($this).MathML.math.innerXml
    )  
</math>
"@
