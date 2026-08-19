<#
.SYNOPSIS
    Includes a Sitemap
.DESCRIPTION
    Includes a sitemap
.LINK
    https://en.wikipedia.org/wiki/Sitemaps
#>
[OutputType('application/xml')]
param(
# A root url for the website
[uri]
$Url,

# A collection of all pages
# The keys should be the urls.
[Alias('Pages')]
[Collections.IDictionary]
$PagesByUrl,

# An optional list of items to disallow
[SupportsWildcards()]
[Alias('Hide','Hidden','NoIndex','NoSitemap')]
[string[]]
$Disallow
)

# If there were no pages, there is no sitemap
if (-not $PagesByUrl.Count) {
    return
}


# A sitemap is just a bit of XML
$sitemap = @(
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

    :nextPage foreach ($key in $PagesByUrl.Keys) {
        $keyUri = $key -as [Uri]
        $page = $PagesByUrl[$key]

        # Skip any page that is not html
        if ($page.Extension -ne 'html') { continue }

        # Skip any explicitly disallowed pages
        if ($Disallow) {
            foreach ($disallowed in $Disallow) {
                if ($keyUri.LocalPath -like "*$disallowed*") { continue nextPage }
                if ($keyUri.AbsoluteUri -like "*$disallowed*") { continue nextPage }
            }
        }
        
        # If the page does not want to be indexed or sitemapped
        # (or is explicitly hidden)
        if ($page.NoIndex -or 
            $page.NoSitemap -or 
            $page.Hidden -or 
            $page.Hide
        ) { continue } # continue.

        # Otherwise, it's in the sitemap
        "<url>"
        
            # If the url was already absolute
            if ($keyUri.IsAbsoluteUri) {
                "<loc>$key</loc>" # use it
            } else {
                # Otherwise, use our site url.
                "<loc>$($url -replace '/$')/$($key -replace '^/')</loc>"
            }

            # If the page has a date
            if ($PagesByUrl[$key].Date -is [DateTime]) {
                # that will be it's last modified
                "<lastmod>$($PagesByUrl[$key].Date.ToString('yyyy-MM-dd'))</lastmod>"
            }
            
        "</url>"
    }
    '</urlset>'
)

# Cast our sitemap to XML.
# This will return the sitemap, or throw an exception if the XML is invalid.
[xml]$sitemap

