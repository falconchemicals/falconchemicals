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
function Safe($s) { return [System.Security.SecurityElement]::Escape($s) }
function Logo($x, $y, $scale) {
    $w = 76 * $scale; $h = 30 * $scale
    $bird = "<g transform='translate($x $y) scale($scale)'><path d='M27 4c-11 2-20 7-27 17 9-2 16 0 22 4-6 1-11 4-16 9 13-2 23-8 31-18 3-4 4-8 5-13-4 3-9 4-15 1Z' fill='#65a30d'/><path d='M18 11h21L25 18Z' fill='#0f766e'/><text x='48' y='18' fill='#16a34a' font-size='15' font-weight='900' font-family='Arial'>Falcon</text><text x='98' y='18' fill='#1d4ed8' font-size='15' font-weight='900' font-family='Arial'>Chemicals</text><text x='49' y='31' fill='#667085' font-size='8' font-weight='700' font-family='Arial'>industrial products</text></g>"
    return $bird
}
function BagSvg($p) {
    $name = Safe $p.Name
    $smallLogo = Logo 88 122 0.62
    $bigLogo = Logo 335 92 0.92
    return @"
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 900 560' role='img' aria-label='$name Falcon Chemicals product bag'>
  <defs>
    <linearGradient id='cloth' x1='0' x2='1' y1='0' y2='1'><stop stop-color='#ffffff'/><stop offset='1' stop-color='#eef2f7'/></linearGradient>
    <filter id='shadow' x='-20%' y='-20%' width='140%' height='150%'><feDropShadow dx='0' dy='18' stdDeviation='18' flood-color='#0f172a' flood-opacity='0.18'/></filter>
  </defs>
  <rect width='900' height='560' fill='#ffffff'/>
  <ellipse cx='248' cy='486' rx='130' ry='24' fill='#0f172a' opacity='0.12'/>
  <ellipse cx='620' cy='490' rx='188' ry='30' fill='#0f172a' opacity='0.14'/>
  <g filter='url(#shadow)'>
    <path d='M78 168h230l22 300H56l22-300Z' fill='url(#cloth)' stroke='#e5e7eb' stroke-width='5'/>
    <path d='M78 168c48 18 178 18 230 0' fill='none' stroke='#d1d5db' stroke-width='5'/>
    <path d='M62 417c80 22 166 20 260-4v55H56Z' fill='#1d75b8'/>
    <path d='M62 398c78 20 170 18 260-12' fill='none' stroke='#65a30d' stroke-width='9'/>
    <path d='M62 426c88 10 175 5 260-18' fill='none' stroke='#ffffff' stroke-width='5' opacity='0.82'/>
    $smallLogo
    <text x='193' y='285' text-anchor='middle' fill='#1d75b8' font-size='24' font-weight='900' font-family='Arial'>$name</text>
  </g>
  <g filter='url(#shadow)'>
    <path d='M394 86h330l44 382H356l38-382Z' fill='url(#cloth)' stroke='#e5e7eb' stroke-width='6'/>
    <path d='M724 86l70 54v328l-26 0-44-382Z' fill='#e5e7eb' stroke='#d1d5db' stroke-width='5'/>
    <path d='M394 86c72 24 250 24 330 0' fill='none' stroke='#d1d5db' stroke-width='6'/>
    <path d='M430 92c-12-52 20-68 30-10' fill='none' stroke='#1d75b8' stroke-width='13' stroke-linecap='round'/>
    <path d='M676 92c-12-52 20-68 30-10' fill='none' stroke='#1d75b8' stroke-width='13' stroke-linecap='round'/>
    <path d='M548 86c-8-38 15-48 24-5' fill='none' stroke='#1d75b8' stroke-width='11' stroke-linecap='round'/>
    <path d='M430 88v164M704 88v164' stroke='#1d75b8' stroke-width='12' opacity='0.92'/>
    <path d='M368 408c122 38 250 38 410-6v66H356Z' fill='#1d75b8'/>
    <path d='M366 388c120 34 265 30 400-20' fill='none' stroke='#65a30d' stroke-width='12'/>
    <path d='M366 422c120 15 260 8 400-32' fill='none' stroke='#ffffff' stroke-width='6' opacity='0.86'/>
    $bigLogo
    <text x='560' y='214' text-anchor='middle' fill='#94a3b8' font-size='24' font-weight='700' font-family='Arial'>industrial products</text>
    <text x='560' y='337' text-anchor='middle' fill='#1d75b8' font-size='34' font-weight='900' font-family='Arial'>$name</text>
  </g>
</svg>
"@
}
$products = @()
foreach ($row in $sheet.SelectNodes('//x:sheetData/x:row[position()>1]', $ns)) {
    $name = CellText $row 'A'; $industries = CellText $row 'B'; if (-not $name) { continue }
    $cat = Category $name; $type = TypeName $name $cat; $status = StatusName $name $industries $cat; $slug = Slug $name
    $products += [ordered]@{name=$name; category=$cat; type=$type; status=$status; industries=$industries; image="assets/product-images/$slug.svg"; packaging='bag'}
}
$imgDir = Join-Path (Get-Location) 'assets\product-images'; New-Item -ItemType Directory -Path $imgDir -Force | Out-Null
foreach ($p in $products) { Set-Content -Path (Join-Path $imgDir "$(Slug $p.name).svg") -Value (BagSvg $p) -Encoding UTF8 }
$json = $products | ConvertTo-Json -Depth 5
$html = Get-Content .\index.html -Raw
$html = [regex]::Replace($html, 'const products = \[[\s\S]*?\];\s*\n\s*const themeMap', "const products = $json;`n`n        const themeMap")
$html = $html.Replace('Product images are ready-to-use Falcon Chemicals packshots generated into the local assets/product-images folder. Real supplier photos can replace them when licensed images are available.', 'Product images use a unified Falcon Chemicals 25kg bag and jumbo bag design, branded with the company logo and the individual compound name.')
Set-Content -Path .\index.html -Value $html -Encoding UTF8
Write-Output "Generated $($products.Count) Falcon bag mockups."
