<#
.SYNOPSIS
    CSS Compatibility    
.DESCRIPTION
    Matrix CSS Compatibility
.COMPONENT
    /matrix/css/
#>
[Reflection.AssemblyMetadata(
    'og:description', 'Matrix CSS Compatibility'
)]
param()

$Title = 'CSS Compatibility'

ConvertFrom-Markdown -InputObject @"

# Matrix CSS

## Matrix CSS Compatibility

Matrix is mostly compatible with CSS.

Each CSS transform function can be represented in a 4x4 or 3x2 matrix.

Matrix extends every `[Numerics.Matrix4x4]` and `[Numerics.Matrix3x2]` matrix with a .CSS property.

We can embed matrices in any css file or html file by simply outputting that property:

~~~PowerShell
(rotateX 45deg).CSS
~~~

This capability is quite useful.

It means we can transform objects in 2D or 3D the exact same way we would in CSS.

The rest of this page proves the point.

It shows a side-by-side comparison of pure CSS and the matrix operation.

Each side should be identical.

"@ | 
    Select-Object -ExpandProperty Html


"<style>"
".side-by-side { display: grid; place-items: center; grid-template-columns: 1fr 1fr 1fr; margin: 2.5rem; }" 
".side-by-side article { border: 1px solid; padding: 0.5rem; }"
".flex-gap { display: flex; flex-direction: column; gap: 3rem;}"
".grid-overlap { display: grid; grid-template-rows: 1fr; grid-template-columns: 1fr; place-items: center;transform-style: preserve-3d }"

"

.cube {
    width: 100px;
    height: 100px;
    transform-style: preserve-3d;
    transition: transform 1.5s;
    transform: rotate3d(1, 1, 1, 60deg);
    /*transform: $((Rotate3d 1 1 1 45deg).CSS);*/
}

.floating { float: left; }
.floating-right { float: right; }

.face {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    position: absolute;
    backface-visibility: inherit;
    font-size: 60px;
    border: 0.1rem dashed;
}

.front { transform: translateZ(50px); }
.front-matrix { transform: $((TranslateZ 50).CSS)}

.back { transform: rotateY(180deg) translateZ(50px); }
.back-matrix { transform: $(((RotateY 180deg) * (TranslateZ -50)).CSS)}

.right { transform: rotateY(90deg) translateZ(50px); }
.right-matrix { transform: $((RotateY 90deg).CSS) $((translateZ 50px).CSS)}

.left { transform: rotateY(-90deg) translateZ(50px); }
.left-matrix { transform: $((RotateY -90deg).CSS) $((translateZ 50px).CSS)}

.top { transform: rotateX(90deg) translateZ(50px); }
.top-matrix { transform: $((RotateX 90deg).CSS) $((translateZ 50px).CSS)}
.bottom { transform: rotateX(-90deg) translateZ(50px); }
.bottom-matrix { transform: $((RotateX -90deg).CSS) $((translateZ 50px).CSS)}
  
@keyframes spinning {
    from {
        transform: rotateX(0) rotateY(180deg) rotateZ(0)
    }
    to {
        transform: rotateX(360deg) rotateY(-180deg) rotateZ(360deg)
    }
}

@keyframes spinning-matrix {
    from {
        transform: $(((rotateX 0) * (rotateY 180deg) * (rotateZ 0)).CSS)
    }
    to {
        transform: $(((rotateX 360deg) * (rotateY -180deg) * (rotateZ 360deg)).CSS)
    }
}

.spinning {
    animation-name: spinning;
    animation-duration: 7s;
    animation-iteration-count: infinite;
}

.spinning-matrix {
    animation-name: spinning-matrix;
    animation-duration: 7s;
    animation-iteration-count: infinite;
}
"

"</style>"


"<details open class='flex-gap'>"
"<summary>Cube</summary>"
    "<section class='side-by-side'>"    
        "<section class='cube spinning'>
            <div class='face front ANSI1-background'></div>
            <div class='face back ANSI2-background'></div>
            <div class='face right ANSI3-background'></div>
            <div class='face left ANSI4-background'></div>
            <div class='face top ANSI5-background'></div>
            <div class='face bottom ANSI6-background'></div>
        </section>"

        "<label>"
            "Cube"
        "</label>"
        "<section class='cube spinning'>
            <div class='face front-matrix ANSI1-background'></div>
            <div class='face back-matrix ANSI2-background'></div>
            <div class='face right-matrix ANSI3-background'></div>
            <div class='face left-matrix ANSI4-background'></div>
            <div class='face top-matrix ANSI5-background'></div>
            <div class='face bottom-matrix ANSI6-background'></div>
        </section>"                    
    "</section>"
"</details>"



$2d = [Ordered]@{
    "rotate(30deg)" = "rotate(30deg)", (Rotate 30deg).CSS
    "skewX(30deg)" = "skewX(30deg)", (SkewX 30deg).CSS
    "skewY(30deg)" = "skewY(30deg)", (SkewY 30deg).CSS
    "skew(30deg, 15deg)" = "skew(30deg, 15deg)", (Skew 30deg 15deg).CSS
    "skew(15deg, 30deg)" = "skew(15deg, 30deg)", (Skew 15deg 30deg).CSS
    "scale(1,1.5)" = "scale(1,1.5)", (Scale 1 1.5).CSS
    "scale(1.5,1)" = "scale(1.5,1)", (Scale 1.5 1).CSS
    "translate(-5px, 10px)" = "translate(-5px,10px)", (Translate -5px 10px).CSS
}


"<details open class='flex-gap'>"
"<summary>2D</summary>"
foreach ($key in $2d.Keys) {
    "<section class='side-by-side'>"
        "<article style='transform: $($2d[$key][0])'>"
            "$key"
        "</article>"    
        "<label>"
            "$key"
        "</label>"
        "<article style='transform: $($2d[$key][1])'>"
            "$key"
        "</article>"
    "</section>"
}
"</details>"

$3d = [Ordered]@{
    "rotateX(45deg)" = "rotateX(45deg)", (RotateX 45deg).CSS
    "rotateY(45deg)" = "rotateY(45deg)", (RotateY 45deg).CSS
    "rotateZ(45deg)" = "rotateZ(45deg)", (RotateZ 45deg).CSS
    "rotate3d(1,1,1, 45deg)" = "rotate3d(1,1,1, 45deg)", (rotate3d 1 1 1 45deg).CSS
    "scaleX(1.5)" = "scaleX(1.5)", (ScaleX 1.5).CSS
    "scaleY(1.5)" = "scaleY(1.5)", (ScaleY 1.5).CSS
    "scaleZ(1.5)" = "scaleZ(1.5)", (ScaleZ 1.5).CSS
    "scale3D(1.5, 0.75, 0.5)" = "scale3D(1.5, 0.75, 0.5)", (scale3D 1.5, 0.75, 0.5).CSS
    "translateX(10px)" = "translateX(10px)", (TranslateX 10px).CSS
    "translateY(10px)" = "translateY(10px)", (TranslateY 10px).CSS
    "translateZ(-20px)" = "translateZ(-20px)", (TranslateZ -20px).CSS
    "translate3d(10px, 20px, 30px)" = "translate3d(10px, 20px, 30px)", (translate3d 10px, 20px, 30px).CSS        
}

"<details open class='flex-gap'>"
"<summary>3D</summary>"
foreach ($key in $3d.Keys) {
    "<section class='side-by-side'>"
        "<article style='transform: $($3d[$key][0])'>"
            "$key"
        "</article>"    
        "<label>"
            "$key"
        "</label>"
        "<article style='transform: $($3d[$key][1])'>"
            "$key"
        "</article>"
    "</section>"
}
"</details>"






@(
    
    "<section class='floating cube'>"
        "<div class='face front'></div>
        <div class='face back'></div>
        <div class='face right'></div>
        <div class='face left'></div>
        <div class='face top'></div>
        <div class='face bottom'></div>"
    "</section>"
    "<section class='floating-right cube'>"
        "<div class='face front-matrix'></div>
        <div class='face back-matrix'></div>
        <div class='face right-matrix'></div>
        <div class='face left-matrix'></div>
        <div class='face top-matrix'></div>
        <div class='face bottom-matrix'></div>"
    "</section>"
) * 4


return
