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
function Packaging($name, $industries, $category, $type) {
    $text = ($name + ' ' + $industries + ' ' + $type).ToLower()
    if ($category -eq 'Acid' -or $text.Contains('water treatment') -or $text.Contains('metal cleaning')) { return 'drum' }
    if ($text.Contains('fertilizer') -or $text.Contains('feed') -or $text.Contains('detergents') -or $text.Contains('paper') -or $text.Contains('coating') -or $text.Contains('plastics')) { return 'bag' }
    return 'jerrycan'
}
function Slug($name) { return (($name.ToLower() -replace '%',' percent') -replace '[^a-z0-9]+','-').Trim('-') }
function Safe($s) { return [System.Security.SecurityElement]::Escape($s) }
function BrandLogo($cx, $cy, $scale) {
@"
<g transform='translate($cx $cy) scale($scale)'>
  <circle cx='0' cy='0' r='22' fill='#101828'/>
  <path d='M14 -12 C5 -10 -3 -5 -12 4 C-4 2 2 3 8 7 C2 8 -4 12 -12 18 C-3 16 5 12 14 4 C16 0 17 -4 18 -8 C16 -7 14 -7 12 -8 C14 -10 14 -12 14 -12Z' fill='#0f766e'/>
  <path d='M-6 -2 L10 -2 L0 4Z' fill='#ffffff'/>
  <circle cx='8' cy='-5' r='1.5' fill='#ffffff'/>
  <path d='M0 10 C4 12 8 12 12 10' fill='none' stroke='#ffffff' stroke-width='1.8' stroke-linecap='round'/>
  <path d='M-10 10 L6 10 L3 18 L-7 18Z' fill='#ffffff'/>
  <path d='M-7 10 L-7 3 L5 3 L5 10' fill='none' stroke='#ffffff' stroke-width='1.8' stroke-linejoin='round'/>
</g>
"@
}
function BagSvg($p) {
    $name = Safe $p.name; $sub = Safe $p.type
@"
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 400 520' width='400' height='520'>
<defs>
  <linearGradient id='bagBody' x1='0' y1='0' x2='1' y2='1'><stop offset='0%' stop-color='#ffffff'/><stop offset='50%' stop-color='#f8fafc'/><stop offset='100%' stop-color='#e2e8f0'/></linearGradient>
  <linearGradient id='sideFold' x1='0' y1='0' x2='1' y2='0'><stop offset='0%' stop-color='#cbd5e1' stop-opacity='0.6'/><stop offset='50%' stop-color='#ffffff' stop-opacity='0'/><stop offset='100%' stop-color='#94a3b8' stop-opacity='0.4'/></linearGradient>
  <linearGradient id='brandRed' x1='0' y1='0' x2='1' y2='0'><stop offset='0%' stop-color='#c81e1e'/><stop offset='100%' stop-color='#981b1b'/></linearGradient>
  <filter id='dropShadow' x='-10%' y='-10%' width='120%' height='120%'><feDropShadow dx='0' dy='8' stdDeviation='12' flood-color='#101828' flood-opacity='0.15'/></filter>
</defs>
<rect width='400' height='520' fill='#f1f5f9'/><ellipse cx='200' cy='485' rx='140' ry='18' fill='#101828' opacity='0.08'/>
<g filter='url(#dropShadow)'>
  <path d='M80 60 Q200 45 320 60 L335 440 Q200 470 65 440Z' fill='url(#bagBody)'/>
  <path d='M80 60 L65 440 Q200 470 200 485 L200 50 Q140 52 80 60' fill='url(#sideFold)' opacity='0.5'/>
  <path d='M320 60 L335 440 Q200 470 200 485 L200 50 Q260 52 320 60' fill='url(#sideFold)' opacity='0.3'/>
  <path d='M65 400 L335 400 L335 440 Q200 470 65 440Z' fill='#000' opacity='0.07'/>
  <path d='M80 60 Q200 45 320 60' fill='none' stroke='#cbd5e1' stroke-width='2'/>
</g>
<ellipse cx='200' cy='52' rx='35' ry='10' fill='#e2e8f0' stroke='#cbd5e1' stroke-width='1.5'/><rect x='185' y='42' width='30' height='16' rx='4' fill='#f1f5f9' stroke='#cbd5e1'/>
<rect x='95' y='75' width='210' height='6' rx='3' fill='url(#brandRed)'/>
$(BrandLogo 200 115 1.45)
<text x='200' y='168' text-anchor='middle' font-family='Inter, Arial, sans-serif' font-weight='900' font-size='18' fill='#101828'>FALCON CHEMICALS</text>
<text x='200' y='184' text-anchor='middle' font-family='Inter, Arial, sans-serif' font-weight='700' font-size='10' fill='#667085' letter-spacing='2'>CAIRO · EGYPT</text>
<rect x='100' y='200' width='200' height='4' rx='2' fill='url(#brandRed)'/>
<rect x='98' y='214' width='204' height='84' rx='8' fill='#f8fafc' stroke='#e2e8f0'/>
<text x='200' y='244' text-anchor='middle' font-family='Inter, Arial, sans-serif' font-weight='900' font-size='15' fill='#101828'>$name</text>
<text x='200' y='265' text-anchor='middle' font-family='Inter, Arial, sans-serif' font-weight='700' font-size='11' fill='#667085'>$sub</text>
<text x='200' y='282' text-anchor='middle' font-family='Inter, Arial, sans-serif' font-weight='600' font-size='9' fill='#94a3b8'>Industrial Grade</text>
<circle cx='200' cy='326' r='29' fill='#101828'/><text x='200' y='323' text-anchor='middle' font-family='Inter, Arial' font-weight='900' font-size='10' fill='#fff'>NET WT.</text><text x='200' y='340' text-anchor='middle' font-family='Inter, Arial' font-weight='900' font-size='16' fill='#fff'>25 KG</text>
<rect x='100' y='365' width='200' height='4' rx='2' fill='url(#brandRed)'/>
<text x='200' y='420' text-anchor='middle' font-family='Inter, Arial' font-weight='700' font-size='8' fill='#94a3b8'>FOR INDUSTRIAL USE ONLY · STORE IN DRY PLACE</text>
<text x='200' y='435' text-anchor='middle' font-family='Inter, Arial' font-weight='600' font-size='8' fill='#cbd5e1'>www.falconchemicals.com · +20 100 000 0000</text>
<text x='88' y='250' text-anchor='middle' font-family='Inter, Arial' font-weight='800' font-size='9' fill='#94a3b8' transform='rotate(-90 88 250)'>FALCON CHEMICALS · 25KG</text>
<text x='312' y='250' text-anchor='middle' font-family='Inter, Arial' font-weight='800' font-size='9' fill='#94a3b8' transform='rotate(90 312 250)'>FALCON CHEMICALS · 25KG</text>
</svg>
"@
}
function DrumSvg($p) {
    $name = Safe $p.name; $sub = Safe $p.type
@"
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 380 520' width='380' height='520'>
<defs><linearGradient id='drumBlue' x1='0' y1='0' x2='1' y2='0'><stop offset='0%' stop-color='#1e40af'/><stop offset='50%' stop-color='#3b82f6'/><stop offset='100%' stop-color='#1e3a8a'/></linearGradient><radialGradient id='drumTop' cx='50%' cy='50%' r='50%'><stop offset='0%' stop-color='#60a5fa'/><stop offset='70%' stop-color='#2563eb'/><stop offset='100%' stop-color='#1e40af'/></radialGradient><linearGradient id='brandRed2' x1='0' y1='0' x2='1' y2='0'><stop offset='0%' stop-color='#c81e1e'/><stop offset='100%' stop-color='#981b1b'/></linearGradient><filter id='drumShadow' x='-15%' y='-5%' width='130%' height='110%'><feDropShadow dx='0' dy='12' stdDeviation='16' flood-color='#0f172a' flood-opacity='0.25'/></filter></defs>
<rect width='380' height='520' fill='#f8fafc'/><ellipse cx='190' cy='475' rx='130' ry='22' fill='#0f172a' opacity='0.12'/>
<g filter='url(#drumShadow)'><rect x='75' y='90' width='230' height='370' rx='16' fill='url(#drumBlue)'/><rect x='75' y='160' width='230' height='8' rx='4' fill='#1e3a8a' opacity='0.32'/><rect x='75' y='270' width='230' height='8' rx='4' fill='#1e3a8a' opacity='0.32'/><rect x='75' y='380' width='230' height='8' rx='4' fill='#1e3a8a' opacity='0.32'/><ellipse cx='190' cy='90' rx='115' ry='28' fill='url(#drumTop)'/><ellipse cx='190' cy='90' rx='108' ry='24' fill='none' stroke='#cbd5e1' stroke-width='5'/><ellipse cx='145' cy='82' rx='14' ry='8' fill='#d1d5db' stroke='#6b7280'/><ellipse cx='235' cy='82' rx='14' ry='8' fill='#d1d5db' stroke='#6b7280'/></g>
<rect x='100' y='184' width='180' height='188' rx='10' fill='#fff' opacity='0.96' stroke='#e2e8f0'/><rect x='100' y='184' width='180' height='8' rx='4' fill='url(#brandRed2)'/>
$(BrandLogo 190 222 1)
<text x='190' y='262' text-anchor='middle' font-family='Inter, Arial' font-weight='900' font-size='14' fill='#101828'>FALCON CHEMICALS</text>
<text x='190' y='291' text-anchor='middle' font-family='Inter, Arial' font-weight='900' font-size='13' fill='#1e40af'>$name</text>
<text x='190' y='309' text-anchor='middle' font-family='Inter, Arial' font-weight='600' font-size='10' fill='#64748b'>$sub</text>
<rect x='145' y='326' width='90' height='32' rx='16' fill='#101828'/><text x='190' y='336' text-anchor='middle' font-family='Inter, Arial' font-weight='900' font-size='9' fill='#94a3b8'>CAPACITY</text><text x='190' y='351' text-anchor='middle' font-family='Inter, Arial' font-weight='900' font-size='13' fill='#fff'>200 L</text>
<rect x='100' y='364' width='180' height='8' rx='4' fill='url(#brandRed2)'/>
<rect x='85' y='120' width='50' height='50' rx='6' fill='#fef3c7' stroke='#f59e0b' transform='rotate(-8 110 145)'/><text x='110' y='151' text-anchor='middle' font-family='Arial' font-weight='900' font-size='22' fill='#b45309' transform='rotate(-8 110 145)'>!</text>
<text x='190' y='445' text-anchor='middle' font-family='Inter, Arial' font-weight='700' font-size='8' fill='#93c5fd'>CAIRO, EGYPT · FALCONCHEMICALS.COM</text>
</svg>
"@
}
function JerrySvg($p) {
    $name = Safe $p.name; $sub = Safe $p.type
@"
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 360 480' width='360' height='480'>
<defs><linearGradient id='jerryBlue' x1='0' y1='0' x2='1' y2='0'><stop offset='0%' stop-color='#1e40af'/><stop offset='55%' stop-color='#3b82f6'/><stop offset='100%' stop-color='#1e3a8a'/></linearGradient><linearGradient id='brandRed3' x1='0' y1='0' x2='1' y2='0'><stop offset='0%' stop-color='#c81e1e'/><stop offset='100%' stop-color='#981b1b'/></linearGradient><filter id='jerryShadow' x='-10%' y='-5%' width='120%' height='110%'><feDropShadow dx='0' dy='10' stdDeviation='14' flood-color='#0f172a' flood-opacity='0.2'/></filter></defs>
<rect width='360' height='480' fill='#f1f5f9'/><ellipse cx='180' cy='435' rx='100' ry='16' fill='#0f172a' opacity='0.1'/>
<g filter='url(#jerryShadow)'><rect x='90' y='140' width='180' height='270' rx='18' fill='url(#jerryBlue)'/><rect x='105' y='180' width='30' height='190' rx='12' fill='#1e3a8a' opacity='0.25'/><rect x='225' y='180' width='30' height='190' rx='12' fill='#1e3a8a' opacity='0.25'/><rect x='145' y='115' width='70' height='35' rx='8' fill='#2563eb' stroke='#1e40af' stroke-width='2'/><rect x='155' y='95' width='50' height='25' rx='6' fill='#d1d5db' stroke='#6b7280'/><path d='M215 140 L215 80 Q215 60 235 60 L255 60 Q275 60 275 80 L275 140' fill='none' stroke='#4b5563' stroke-width='18' stroke-linecap='round'/></g>
<rect x='108' y='205' width='144' height='168' rx='10' fill='#fff' opacity='0.96' stroke='#e2e8f0'/><rect x='108' y='205' width='144' height='7' rx='3.5' fill='url(#brandRed3)'/>
$(BrandLogo 180 240 0.95)
<text x='180' y='278' text-anchor='middle' font-family='Inter, Arial' font-weight='900' font-size='13' fill='#101828'>FALCON CHEMICALS</text>
<text x='180' y='306' text-anchor='middle' font-family='Inter, Arial' font-weight='900' font-size='12' fill='#1e40af'>$name</text>
<text x='180' y='323' text-anchor='middle' font-family='Inter, Arial' font-weight='600' font-size='9' fill='#64748b'>$sub</text>
<rect x='134' y='338' width='92' height='25' rx='12.5' fill='#101828'/><text x='180' y='355' text-anchor='middle' font-family='Inter, Arial' font-weight='900' font-size='12' fill='#fff'>20 LITERS</text>
<text x='180' y='404' text-anchor='middle' font-family='Inter, Arial' font-weight='700' font-size='8' fill='#bfdbfe'>CAIRO, EGYPT</text>
</svg>
"@
}
$products = @()
foreach ($row in $sheet.SelectNodes('//x:sheetData/x:row[position()>1]', $ns)) {
    $name = CellText $row 'A'; $industries = CellText $row 'B'; if (-not $name) { continue }
    $cat = Category $name; $type = TypeName $name $cat; $status = StatusName $name $industries $cat; $pack = Packaging $name $industries $cat $type; $slug = Slug $name
    $products += [ordered]@{name=$name; category=$cat; type=$type; status=$status; industries=$industries; image="assets/product-images/$slug.svg"; packaging=$pack}
}
$imgDir = Join-Path (Get-Location) 'assets\product-images'; New-Item -ItemType Directory -Path $imgDir -Force | Out-Null
foreach ($p in $products) {
    $svg = if ($p.packaging -eq 'drum') { DrumSvg $p } elseif ($p.packaging -eq 'jerrycan') { JerrySvg $p } else { BagSvg $p }
    Set-Content -Path (Join-Path $imgDir "$(Slug $p.name).svg") -Value $svg -Encoding UTF8
}
$json = $products | ConvertTo-Json -Depth 5
$html = Get-Content .\index.html -Raw
$html = [regex]::Replace($html, 'const products = \[[\s\S]*?\];\s*\n\s*const themeMap', "const products = $json;`n`n        const themeMap")
$html = $html.Replace('Product images use a unified Falcon Chemicals 25kg bag and jumbo bag design, branded with the company logo and the individual compound name.', 'Product images use Falcon Chemicals packaging mockups: 25kg white chemical bags, 200L blue drums, and 20L blue jerry cans, each branded with the compound name.')
Set-Content -Path .\index.html -Value $html -Encoding UTF8
Write-Output "Generated $($products.Count) packaging mockups: $((($products | Where-Object packaging -eq 'bag').Count)) bags, $((($products | Where-Object packaging -eq 'drum').Count)) drums, $((($products | Where-Object packaging -eq 'jerrycan').Count)) jerry cans."
