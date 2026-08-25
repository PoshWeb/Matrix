[xml]@"
<math display='block'>
<mo>[</mo>
<mtable>
$(
    foreach ($row in 1..4) {
        "<mtr>"
        foreach ($col in 1..4) {
            "<mtd><mn>$($this."M${row}${col}")</mn></mtd>"
        }
        "</mtr>"
    }
)
</mtable>
<mo>]</mo>  
</math>
"@

