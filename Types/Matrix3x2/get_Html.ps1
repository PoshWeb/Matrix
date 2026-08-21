<#
.SYNOPSIS
    Gets Matrix Html
.DESCRIPTION
    Gets an HTML representation of the Matrix.

    If there is an attached Content property, it will be rendered using the matrix.

    Otherwise, the Matrix's MathML representation will be rendered twice:

    * Once untransformed
    * Once transformed using itself    
#>
param()

# If we have content
if ($this.Content) {
    # put it in the matrix.
    "<section style='transform:$($this.CSS)'>"
        if ($this.Content.OuterXml) {
            $this.Content.OuterXml
        } elseif ($this.Content.Html) {
            $this.Content.Html
        } else {
            "$($this.Content)"
        }        
    "</section>"
} else {
    # Otherwise,
    $mathML = $this.MathML    
    $mathML.OuterXML # show the MathML
    # and show it again, transformed.
    $mathML.math.setAttribute('style', "transform:$($this.CSS)")
    $mathML.OuterXML
}