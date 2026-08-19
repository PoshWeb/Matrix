<#
.SYNOPSIS
    Includes a Menu
.DESCRIPTION


#>
param(
[PSObject]
$Menu,

[string]
$Name
)


filter menuToHtml {
    
    $menu = $_
    
    foreach ($property in $Menu.psobject.properties) {
        "<li>"
            if ($property.Value -is [string] -and 
                $property.Value -match '^/' -or $property.Value -is [uri]) {
                "<a href='$($property.Value)'>$(
                    if ($property.Name -notmatch '^<') {
                        [Web.HttpUtility]::HtmlEncode($property.Name)
                    } else {
                        $property.Name
                    }
                )</a>"
            } else {
                "<details $(if ($name) { "$("name='$(
                    [Web.HttpUtility]::HtmlAttributeEncode($name)
                )'")" } else { 'open' })>"
                    "<summary>$(
                        if ($property.Name -notmatch '^<') {
                            [Web.HttpUtility]::HtmlEncode($property.Name)
                        } else {
                            $property.Name
                        }
                    )</summary>"
                    "<ul>"
                        $property.Value | menuToHtml
                    "</ul>"
                "</details>"
            }
        "</li>"
    }    
}

"<menu>"
    "<ul>"
        $menu | menuToHtml
    "</ul>"
"</menu>"