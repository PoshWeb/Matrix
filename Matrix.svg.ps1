<#
.SYNOPSIS
    Matrix Logo
.DESCRIPTION
    Logo for `Matrix`
.LINK
    https://github.com/PoshWeb/Matrix
#>
param()

$psChevron = '<symbol id="psChevron" viewBox="0 0 100 100" transform-origin="50% 50%">
    <polygon points="40,20 45,20 60,50 35,80 32.5,80 55,50"/>
</symbol>'

@"

<svg xmlns='http://www.w3.org/2000/svg' width='100%' height='100%' transform-origin='50% 50%'>       
    $psChevron
    $(
        $scale = 1
        for ($scale = 1; $scale -lt 4; $scale += 0.5) {
            $scaleFactor = 1/[Math]::Pow(2,($scale - 1))
            $upscale = 1/[Math]::Pow(2,($scale))
            $transform = (Scale $scaleFactor).CSS


            "<line stroke='#4488ff' class='foreground-stroke' x1='25%' y1='0%' x2='25%' y2='100%' transform-origin='50% 50%' transform='$(
                $transform
            )' />"

            "<line stroke='#4488ff' class='foreground-stroke' x1='75%' y1='0%' x2='75%' y2='100%' transform-origin='50% 50%' transform='$(
                $transform
            )' />"

            "<line stroke='#4488ff' class='foreground-stroke' x1='0%' y1='25%' x2='100%' y2='25%' transform-origin='50% 50%' transform='$(
                $transform
            )' />"

            "<line stroke='#4488ff' class='foreground-stroke' x1='0%' y1='75%' x2='100%' y2='75%' transform-origin='50% 50%' transform='$(
                $transform
            )' />"

            
            <#"<line stroke='currentColor' x1='50%' y1='0%' x2='50%' y2='100%' transform-origin='50% 50%' transform='$(
                (Scale $scaleFactor).CSS
            )' />"#>
        }                        
    )
    <use href='#psChevron' y='$(50 - 15/2)%' height='15%' fill='#4488ff' class='foreground-fill' />    
</svg>
"@
