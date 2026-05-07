[xml]$sheet = Get-Content .\xlsx_unpacked\xl\worksheets\sheet1.xml -Raw
$ns = New-Object System.Xml.XmlNamespaceManager($sheet.NameTable)
$ns.AddNamespace('x','http://schemas.openxmlformats.org/spreadsheetml/2006/main')
function CellText($row, $ref) {
    $cell = $row.SelectSingleNode("x:c[starts-with(@r,'$ref')]", $ns)
    if ($null -eq $cell) { return '' }
    return $cell.SelectSingleNode('x:is/x:t', $ns).InnerText
}
function Category($name) {
    if ($name -match '^Ammonium') { return 'Ammonium' }
    if ($name -match '^Calcium') { return 'Calcium' }
    if ($name -match 'acid') { return 'Acid' }
    if ($name -match '^Lead') { return 'Lead' }
    if ($name -match '^Potassium') { return 'Potassium' }
    if ($name -match '^Sodium') { return 'Sodium' }
    if ($name -match '^Zinc') { return 'Zinc' }
    return 'Other'
}
function TypeName($name, $category) {
    if ($category -eq 'Acid') { return 'Concentrated acid' }
    if ($name -match 'nitrate') { return 'Nitrate salt' }
    if ($name -match 'phosphate') { return 'Phosphate salt' }
    if ($name -match 'sulfate') { return 'Sulfate salt' }
    if ($name -match 'oxalate') { return 'Oxalate salt' }
    if ($name -match 'tartrate') { return 'Tartrate salt' }
    if ($name -match 'fluoride') { return 'Fluoride salt' }
    if ($name -match 'acetate') { return 'Acetate salt / reagent' }
    if ($name -match 'Picric') { return 'Controlled supply' }
    return 'Lab / industrial reagent'
}
function StatusName($name, $industries, $category) {
    $text = ($name + ' ' + $industries).ToLower()
    if ($category -eq 'Acid' -or $category -eq 'Lead' -or $text.Contains('explosives') -or $text.Contains('fluoride') -or $name -match 'Silver nitrate') { return 'By documents' }
    return 'Available'
}
function Slug($name) { return (($name.ToLower() -replace '%',' percent') -replace '[^a-z0-9]+','-').Trim('-') }
function Initials($name) { (($name -replace '[0-9%]','') -split '\s+' | Where-Object { $_ } | Select-Object -First 2 | ForEach-Object { $_.Substring(0,1).ToUpper() }) -join '' }
function Pack($p) {
    $text = ($p.Name + ' ' + $p.Industries + ' ' + $p.Type).ToLower()
    if ($p.Category -eq 'Acid' -or $text.Contains('metal cleaning') -or $text.Contains('water treatment')) { return 'drum' }
    if ($text.Contains('fertilizer') -or $text.Contains('feed') -or $text.Contains('detergents') -or $text.Contains('paper') -or $text.Contains('coating')) { return 'bag' }
    if ($text.Contains('laborator') -or $text.Contains('analysis') -or $text.Contains('hplc') -or $text.Contains('titration') -or $text.Contains('medical') -or $text.Contains('pharma') -or $text.Contains('buffers')) { return 'bottle' }
    return 'jerrycan'
}
$themes = @{
    Ammonium = @{Main='#164e63';Soft='#e0f2fe';Accent='#c81e1e';Label='NH4'}; Calcium = @{Main='#047857';Soft='#dcfce7';Accent='#84cc16';Label='Ca'}; Acid = @{Main='#b91c1c';Soft='#fee2e2';Accent='#f97316';Label='H+'}; Lead = @{Main='#475569';Soft='#e2e8f0';Accent='#94a3b8';Label='Pb'}; Potassium = @{Main='#7c3aed';Soft='#ede9fe';Accent='#c81e1e';Label='K'}; Sodium = @{Main='#2563eb';Soft='#dbeafe';Accent='#38bdf8';Label='Na'}; Zinc = @{Main='#b45309';Soft='#fef3c7';Accent='#c81e1e';Label='Zn'}; Other = @{Main='#101828';Soft='#f1f5f9';Accent='#c81e1e';Label='Rx'}
}
function Svg($p) {
    $t = $themes[$p.Category]; $pack = Pack $p; $code = Initials $p.Name
    $common = "<rect width='640' height='420' fill='$($t.Soft)'/><circle cx='546' cy='72' r='132' fill='$($t.Main)' opacity='0.10'/><circle cx='82' cy='354' r='110' fill='$($t.Accent)' opacity='0.10'/><ellipse cx='320' cy='360' rx='150' ry='24' fill='#0f172a' opacity='0.12'/>"
    $label = "<rect x='218' y='168' width='204' height='98' rx='12' fill='#fff' opacity='0.96'/><text x='320' y='207' text-anchor='middle' fill='$($t.Main)' font-size='34' font-weight='900' font-family='Arial'>$($t.Label)</text><text x='320' y='245' text-anchor='middle' fill='#101828' font-size='22' font-weight='800' font-family='Arial'>$code</text>"
    if ($pack -eq 'bag') { $body = "<path d='M210 76h220l36 274H174L210 76Z' fill='#fff' stroke='$($t.Main)' stroke-width='10'/><path d='M210 76c62 24 150 24 220 0' fill='none' stroke='#cbd5e1' stroke-width='9'/><path d='M184 286h272l8 64H176l8-64Z' fill='$($t.Main)' opacity='0.92'/><text x='320' y='326' text-anchor='middle' fill='#fff' font-size='30' font-weight='900' font-family='Arial'>25 KG</text>$label" }
    elseif ($pack -eq 'drum') { $body = "<rect x='214' y='58' width='212' height='300' rx='30' fill='$($t.Main)'/><path d='M214 112h212M214 304h212' stroke='#fff' stroke-width='12' opacity='0.38'/><rect x='238' y='34' width='164' height='44' rx='13' fill='#cbd5e1' stroke='$($t.Main)' stroke-width='8'/>$label<text x='320' y='326' text-anchor='middle' fill='#fff' font-size='24' font-weight='900' font-family='Arial'>INDUSTRIAL DRUM</text>" }
    elseif ($pack -eq 'jerrycan') { $body = "<path d='M218 92h62c10-34 70-34 80 0h62v266H218V92Z' fill='#fff' stroke='$($t.Main)' stroke-width='10'/><rect x='280' y='48' width='80' height='48' rx='14' fill='#cbd5e1' stroke='$($t.Main)' stroke-width='8'/><path d='M218 276h204v82H218z' fill='$($t.Main)' opacity='0.92'/>$label<text x='320' y='326' text-anchor='middle' fill='#fff' font-size='24' font-weight='900' font-family='Arial'>CHEMICAL GRADE</text>" }
    else { $body = "<rect x='236' y='72' width='168' height='286' rx='28' fill='#fff' stroke='$($t.Main)' stroke-width='10'/><rect x='266' y='32' width='108' height='58' rx='14' fill='#cbd5e1' stroke='$($t.Main)' stroke-width='8'/><path d='M236 268h168v62a28 28 0 0 1-28 28H264a28 28 0 0 1-28-28Z' fill='$($t.Main)' opacity='0.92'/>$label<text x='320' y='326' text-anchor='middle' fill='#fff' font-size='23' font-weight='900' font-family='Arial'>REAGENT</text>" }
    return "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 640 420' role='img' aria-label='$($p.Name) packaging image'>$common$body<text x='320' y='392' text-anchor='middle' fill='#344054' font-size='20' font-weight='800' font-family='Arial'>Falcon Chemicals</text></svg>"
}
$products = @()
foreach ($row in $sheet.SelectNodes('//x:sheetData/x:row[position()>1]', $ns)) {
    $name = CellText $row 'A'; $industries = CellText $row 'B'; if (-not $name) { continue }
    $cat = Category $name; $type = TypeName $name $cat; $status = StatusName $name $industries $cat; $slug = Slug $name
    $products += [ordered]@{name=$name; category=$cat; type=$type; status=$status; industries=$industries; image="assets/product-images/$slug.svg"; packaging=''}
}
$imgDir = Join-Path (Get-Location) 'assets\product-images'; New-Item -ItemType Directory -Path $imgDir -Force | Out-Null
foreach ($p in $products) { $p.packaging = Pack $p; Set-Content -Path (Join-Path $imgDir "$(Slug $p.name).svg") -Value (Svg $p) -Encoding UTF8 }
$json = $products | ConvertTo-Json -Depth 5
$html = Get-Content .\index.html -Raw
$html = [regex]::Replace($html, 'const products = \[[\s\S]*?\]\.map\(\(\[name, category, type, status\]\) => \(\{ name, category, type, status \}\)\);', "const products = $json;")
$html = $html.Replace('Search by compound name or filter by chemical family. Product photos can be replaced with your real stock photos once supplied.', 'Search by compound name or filter by chemical family. Each product card now includes the industry applications from the supplied Excel sheet.')
$html = $html.Replace('Product images shown are clean catalogue packshots for presentation. Send your real product photos or preferred image source and they will be swapped in.', 'Product images are ready-to-use Falcon Chemicals packshots generated into the local assets/product-images folder. Real supplier photos can replace them when licensed images are available.')
$html = $html.Replace('<div class="product-image">${productImage(product, index)}</div>', '<div class="product-image"><img src="${product.image}" alt="${escapeHtml(product.name)} packaging"></div>')
$html = $html.Replace('<p>${escapeHtml(product.type)}</p>', '<p>${escapeHtml(product.type)}</p><div class="industry-tags">${product.industries.split(",").map((industry) => `<span>${escapeHtml(industry.trim())}</span>`).join("")}</div>')
$html = $html.Replace('const matchesSearch = !query || product.name.toLowerCase().includes(query);', 'const haystack = `${product.name} ${product.industries} ${product.type}`.toLowerCase();' + "`n" + '                const matchesSearch = !query || haystack.includes(query);')
Set-Content -Path .\index.html -Value $html -Encoding UTF8
Write-Output "Generated $($products.Count) product images."
