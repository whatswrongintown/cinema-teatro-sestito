# Section share cards (U18, see docs/design.md, section "Share cards").
# Builds one 1200x630 collage card per main page of the Posters and historical
# programming sections and saves it as share-card.jpg in that section's bundle
# (front matter `shareImage: "share-card.jpg"`). Posters are picked at random
# among the better-known films; the same -Seed gives the same cards (1956 is
# the published set). Renders with Microsoft Edge (headless). Run from the
# repository root:  & .\docs\share-card\make-cards.ps1
param([int]$Seed = 1956)
$ErrorActionPreference = 'Stop'
$repo = (Get-Location).Path
if (-not (Test-Path "$repo\data\posters\films.json")) { throw 'Run from the repository root.' }
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$out = Join-Path ([IO.Path]::GetTempPath()) "share-cards-$PID"
New-Item -ItemType Directory -Force $out | Out-Null
$root = 'file:///' + ($repo -replace '\\', '/')
$rnd = New-Object System.Random $Seed

function Pick($list, $n) {
  $a = @($list | Where-Object { $_ }); $res = @(); if ($a.Count -eq 0) { return @() }
  $idx = [System.Collections.Generic.List[int]]::new(); 0..($a.Count - 1) | ForEach-Object { $idx.Add($_) }
  while ($res.Count -lt $n -and $idx.Count -gt 0) { $i = $rnd.Next($idx.Count); $res += $a[$idx[$i]]; $idx.RemoveAt($i) }
  return $res
}

# --- data ---------------------------------------------------------------
$films = (Get-Content "$repo\data\posters\films.json" -Raw -Encoding UTF8 | ConvertFrom-Json).films
$paesi = @{}; Import-Csv "$repo\static\data\programmazione_paesi.csv" -Encoding UTF8 | ForEach-Object {
  foreach ($c in ($_.country -split ',')) { $c = $c.Trim(); if ($c) { if (-not $paesi[$_.const]) { $paesi[$_.const] = @() }; $paesi[$_.const] += $c } } }
$fonti = @{}; Import-Csv "$repo\static\data\programmazione_agende.csv" -Encoding UTF8 | ForEach-Object {
  foreach ($s in ($_.source -split ',')) { $s = $s.Trim(); if ($s -and $s -notmatch '(?i)note.su') { if (-not $fonti[$_.const]) { $fonti[$_.const] = @() }; if ($fonti[$_.const] -notcontains $s) { $fonti[$_.const] += $s } } } }

# Well-known films (top 40% by IMDb votes) with a printed portrait poster.
$rows = foreach ($f in $films) {
  $printed = @($f.posters | Where-Object { -not $_.is_retro })
  if (-not $printed) { continue }
  $v = 0; if ($f.extra -and $f.extra.'Num Votes') { $v = [double]$f.extra.'Num Votes'[0] }
  $portrait = @($printed | Where-Object { $_.orientation -eq 'portrait' })
  [pscustomobject]@{ id = $f.film_id; title = $f.title; votes = $v; genres = @($f.genres); letter = $f.letter
    years = @($f.screenings | ForEach-Object { [int]$_.year } | Sort-Object -Unique)
    poster = $(if ($portrait) { $portrait[0] } else { $printed[0] }); printed = $printed }
}
$soglia = ($rows | Sort-Object votes -Descending | Select-Object -Index ([int]($rows.Count * 0.4))).votes
$noti = @($rows | Where-Object { $_.votes -ge $soglia -and $_.poster.orientation -eq 'portrait' })
$usati = @{}
function Fresh($list) { @($list | Where-Object { $_ -and -not $usati[$_.id] }) }
function Tile($row, $chip, $p = $null) { if (-not $p) { $p = $row.poster }; $usati[$row.id] = $true; @{ src = "$root/static/$($p.large)"; chip = $chip } }

$paeseIt = @{ 'Italy' = 'Italia'; 'USA' = 'Stati Uniti'; 'United States' = 'Stati Uniti'; 'France' = 'Francia'; 'United Kingdom' = 'Regno Unito'; 'Japan' = 'Giappone'; 'West Germany' = 'Germania Ovest'; 'Spain' = 'Spagna'; 'Hong Kong' = 'Hong Kong'; 'Mexico' = 'Messico' }

# --- cards --------------------------------------------------------------
$cards = [ordered]@{}

$cards['posters'] = @{ kicker = 'Manifesti'; t1 = 'Manifesti'; t2 = 'e locandine'; sub = '1.057 film · 1.787 manifesti'
  tiles = @(Pick (Fresh $noti) 6 | ForEach-Object { Tile $_ '' }) }

$dec = 1950, 1960, 1970, 1980, 1990, 2000
$cards['posters-per-anno'] = @{ kicker = 'Manifesti'; t1 = 'Per'; t2 = 'anno'; sub = '46 anni di proiezioni, dal 1953 al 2004'
  tiles = @(foreach ($d in $dec) { $c = Fresh ($noti | Where-Object { $y = $_.years | Where-Object { $_ -ge $d -and $_ -lt $d + 10 }; $y }); if ($c) { $r = Pick $c 1; $y = @($r.years | Where-Object { $_ -ge $d -and $_ -lt $d + 10 })[0]; Tile $r "$y" } }) }

$formati = @(@('fotobuste', '50x70', 'Fotobusta 50×70'), @('locandine', '33x70', 'Locandina 33×70'), @('manifesti', '70x100', 'Manifesto 70×100'), @('manifesti', '100x140', 'Manifesto 100×140'), @('manifesti', '140x200', 'Manifesto 140×200'), @('fotobuste', '50x70', 'Fotobusta 50×70'))
$cards['posters-per-formato'] = @{ kicker = 'Manifesti'; t1 = 'Per'; t2 = 'formato'; sub = 'Cinque formati, dalla locandina al manifesto 140×200'
  tiles = @(foreach ($fm in $formati) { $c = Fresh ($rows | Where-Object { $_.votes -ge $soglia -and ($_.printed | Where-Object { $_.category -eq $fm[0] -and $_.size -eq $fm[1] }) }); $r = Pick $c 1; $p = @($r.printed | Where-Object { $_.category -eq $fm[0] -and $_.size -eq $fm[1] })[0]; Tile $r $fm[2] $p }) }

function PerGruppo($chiavi, $test) { $n = 0; foreach ($k in $chiavi) { if ($n -ge 6) { break }; $c = Fresh ($noti | Where-Object { & $test $_ $k }); if ($c) { $n++; Tile (Pick $c 1) $k } } }
$generiPosters = Pick @('Western', 'Commedia', 'Horror', 'Fantascienza', 'Avventura', 'Poliziesco', 'Guerra', 'Musicale', 'Thriller', 'Animazione') 10
$cards['posters-per-genere'] = @{ kicker = 'Manifesti'; t1 = 'Per'; t2 = 'genere'; sub = '23 generi, dal western alla commedia'
  tiles = @(PerGruppo $generiPosters { param($r, $k) $r.genres -contains $k }) }

$paesiPosters = @('Italy', 'United States', 'France', 'United Kingdom', 'Japan', 'West Germany')
$cards['posters-per-paese'] = @{ kicker = 'Manifesti'; t1 = 'Per'; t2 = 'paese'; sub = '39 paesi di produzione'
  tiles = @(foreach ($k in $paesiPosters) { $c = Fresh ($noti | Where-Object { $paesi[$_.id] -contains $k }); if ($c) { Tile (Pick $c 1) $paeseIt[$k] } }) }

$cards['posters-per-fonte'] = @{ kicker = 'Manifesti'; t1 = 'Per'; t2 = 'fonte'; sub = '79 fonti della programmazione'
  tiles = @(& { $viste = @{}; foreach ($r in (Pick (Fresh ($noti | Where-Object { $fonti[$_.id] })) 60)) { $s = $fonti[$r.id][0]; if (-not $viste[$s] -and $viste.Count -lt 6) { $viste[$s] = $true; Tile $r $s } } }) }

$cards['posters-per-titolo'] = @{ kicker = 'Manifesti'; t1 = 'Per'; t2 = 'titolo'; sub = '1.057 film dalla A alla Z'
  tiles = @(foreach ($l in (Pick @('A', 'B', 'C', 'D', 'F', 'G', 'I', 'L', 'M', 'P', 'R', 'S', 'T', 'U', 'V') 6 | Sort-Object)) { $c = Fresh ($noti | Where-Object { $_.letter -eq $l }); if ($c) { Tile (Pick $c 1) $l } }) }

$retro = foreach ($f in $films) { foreach ($p in @($f.posters | Where-Object { $_.is_retro -and $_.orientation -eq 'portrait' })) { [pscustomobject]@{ id = $f.film_id; title = $f.title; poster = $p } } }
$cards['posters-retro'] = @{ kicker = 'Manifesti'; t1 = 'Retro'; t2 = 'scritti a mano'; sub = '142 manifesti disegnati sul retro di altri'
  tiles = @(Pick ($retro | Group-Object id | ForEach-Object { $_.Group[0] }) 6 | ForEach-Object { Tile $_ $_.title }) }

# Historical programming
$scansioni = Get-ChildItem "$repo\static\images\programmazione_storica" -Directory | ForEach-Object {
  $img = Join-Path $_.FullName "$($_.Name)_01.webp"; if (Test-Path $img) { $_.Name } }
$titoli = @{}; Get-ChildItem "$repo\content\programmazione-storica\fonti" -Recurse -Filter index.md | ForEach-Object {
  $t = Get-Content $_.FullName -Raw -Encoding UTF8
  if ($t -match 'gallery_dir="/images/programmazione_storica/([^"]+)"' ) { $dir = $Matches[1]; if ($t -match '(?m)^title:\s*"?([^"\r\n]+)"?') { $titoli[$dir] = $Matches[1].Trim() } } }
function Scan($dir) { @{ src = "$root/static/images/programmazione_storica/$dir/$($dir)_01.webp"; chip = $titoli[$dir] } }
$perTipo = @{ agende = @(); calendario = @(); rubrica = @(); appunti = @() }
foreach ($d in $scansioni) { foreach ($k in @($perTipo.Keys)) { if ($d -match $k) { $perTipo[$k] += $d } } }
$agende = @($scansioni | Where-Object { $_ -notmatch 'calendario|rubrica|appunti' })
$scelteFonti = @((Pick $agende 2) + (Pick $perTipo.calendario 2) + (Pick $perTipo.rubrica 1) + (Pick $perTipo.appunti 1))

$cards['programmazione'] = @{ kicker = 'Programmazione storica'; t1 = 'Programmazione'; t2 = 'storica'; sub = '5.479 proiezioni dal 1948 al 2004'
  tiles = @((Pick (Fresh $noti) 3 | ForEach-Object { Tile $_ '' }) + (Pick ($scansioni | Where-Object { $scelteFonti -notcontains $_ }) 3 | ForEach-Object { @{ src = (Scan $_).src; chip = '' } })) }
$cards['programmazione-anni'] = @{ kicker = 'Programmazione storica'; t1 = 'Anno'; t2 = 'per anno'; sub = '57 anni, dal 1948 al 2004'
  tiles = @(foreach ($d in $dec) { $c = Fresh ($noti | Where-Object { $_.years | Where-Object { $_ -ge $d -and $_ -lt $d + 10 } }); if ($c) { $r = Pick $c 1; $y = @($r.years | Where-Object { $_ -ge $d -and $_ -lt $d + 10 })[0]; Tile $r "$y" } }) }
$generiProg = Pick @('Western', 'Commedia', 'Horror', 'Fantascienza', 'Avventura', 'Poliziesco', 'Guerra', 'Musicale', 'Thriller', 'Animazione', 'Drammatico', 'Azione') 12
$cards['programmazione-generi'] = @{ kicker = 'Programmazione storica'; t1 = 'Generi'; t2 = 'cinematografici'; sub = '23 generi nei film proiettati'
  tiles = @(PerGruppo $generiProg { param($r, $k) $r.genres -contains $k }) }
$cards['programmazione-paesi'] = @{ kicker = 'Programmazione storica'; t1 = 'Paesi'; t2 = 'di produzione'; sub = '64 paesi di produzione'
  tiles = @(foreach ($k in @('United States', 'Italy', 'France', 'Spain', 'United Kingdom', 'Hong Kong')) { $c = Fresh ($noti | Where-Object { $paesi[$_.id] -contains $k }); if ($c) { Tile (Pick $c 1) $paeseIt[$k] } }) }
$cards['programmazione-fonti'] = @{ kicker = 'Programmazione storica'; t1 = 'Fonti'; t2 = 'originali'; sub = 'Agende, calendari, rubriche e appunti da cui è ricostruita la programmazione'
  tiles = @($scelteFonti | ForEach-Object { Scan $_ }) }

# --- HTML ---------------------------------------------------------------
$css = @"
@font-face { font-family: 'Fraunces'; font-style: normal; font-weight: 300 900; src: url('$root/static/fonts/fraunces-variable-latin.woff2') format('woff2'); }
@font-face { font-family: 'Fraunces'; font-style: italic; font-weight: 300 900; src: url('$root/static/fonts/fraunces-italic-variable-latin.woff2') format('woff2'); }
@font-face { font-family: 'Archivo'; font-style: normal; font-weight: 400 800; font-stretch: 62% 125%; src: url('$root/static/fonts/archivo-variable-latin.woff2') format('woff2'); }
html, body { margin: 0; width: 1200px; height: 630px; overflow: hidden; background: #14100E; color: #F3EBDD; }
.card { display: grid; grid-template-columns: 430px 770px; height: 630px; }
.testo { padding: 0 40px 0 64px; display: flex; flex-direction: column; justify-content: center; gap: 22px; }
.label { margin: 0; font-family: 'Archivo', sans-serif; font-stretch: 75%; font-weight: 600; font-size: 18px; letter-spacing: 0.12em; text-transform: uppercase; color: #C9A45C; }
h1 { margin: 0; font-family: 'Fraunces', serif; font-weight: 400; font-size: 78px; line-height: 0.95; letter-spacing: -0.03em; }
h1 em { display: block; font-weight: 600; color: #E4584A; }
.sub { margin: 0; font-family: 'Archivo', sans-serif; font-size: 22px; line-height: 1.35; color: #D9CDBB; max-width: 15em; }
.sito { margin-top: 18px; color: #A89B8C; font-size: 15px; }
.tiles { display: grid; grid-template-columns: repeat(3, 1fr); grid-template-rows: repeat(2, 1fr); gap: 4px; height: 630px; }
.tile { position: relative; overflow: hidden; background: #1F1915; }
.tile img { width: 100%; height: 100%; object-fit: cover; object-position: center 30%; display: block; }
.chip { position: absolute; left: 10px; bottom: 10px; padding: 6px 10px 5px; background: rgba(20, 16, 14, 0.86); font-family: 'Archivo', sans-serif; font-stretch: 75%; font-weight: 600; font-size: 15px; letter-spacing: 0.1em; text-transform: uppercase; color: #F3EBDD; max-width: 220px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
"@
$report = @()
foreach ($name in $cards.Keys) {
  $c = $cards[$name]
  $tiles = ($c.tiles | Select-Object -First 6 | ForEach-Object { $chip = if ($_.chip) { "<span class=`"chip`">$([System.Net.WebUtility]::HtmlEncode($_.chip))</span>" } else { '' }; "<div class=`"tile`"><img src=`"$($_.src)`" alt=`"`">$chip</div>" }) -join "`n"
  $html = @"
<!doctype html><html lang="it"><head><meta charset="utf-8"><style>$css</style></head><body>
<div class="card"><div class="testo"><p class="label">Cinema Teatro Sestito · $($c.kicker)</p><h1>$($c.t1)<em>$($c.t2)</em></h1><p class="sub">$($c.sub)</p><p class="label sito">cinemateatrosestito.com</p></div>
<div class="tiles">$tiles</div></div><script>document.fonts.ready.then(function(){var h=document.querySelector('h1'),w=h.parentNode.clientWidth-104,s=78;h.style.whiteSpace='nowrap';var e=h.querySelector('em');while((h.scrollWidth>w||e.scrollWidth>w)&&s>40){s-=2;h.style.fontSize=s+'px'}});</script></body></html>
"@
  [IO.File]::WriteAllText((Join-Path $out "$name.html"), $html, [Text.UTF8Encoding]::new($false))
  $report += "$name : $(@($c.tiles).Count) tiles : $((@($c.tiles) | ForEach-Object { $_.chip }) -join ', ')"
}

# --- render to content/<section>/share-card.jpg ----------------------------
$dest = @{ 'posters' = 'posters'; 'posters-per-anno' = 'posters/by-year'; 'posters-per-formato' = 'posters/by-size'
  'posters-per-genere' = 'posters/by-genre'; 'posters-per-paese' = 'posters/by-country'; 'posters-per-fonte' = 'posters/by-source'
  'posters-per-titolo' = 'posters/by-title'; 'posters-retro' = 'posters/retro'; 'programmazione' = 'programmazione-storica'
  'programmazione-anni' = 'programmazione-storica/anni'; 'programmazione-generi' = 'programmazione-storica/generi'
  'programmazione-paesi' = 'programmazione-storica/paesi-di-produzione'; 'programmazione-fonti' = 'programmazione-storica/fonti' }
Add-Type -AssemblyName System.Drawing
$jpeg = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$q = New-Object System.Drawing.Imaging.EncoderParameters 1
$q.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), 85L
foreach ($name in $cards.Keys) {
  $png = Join-Path $out "$name.png"
  Start-Process -FilePath $edge -Wait -ArgumentList @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--force-device-scale-factor=1',
    '--allow-file-access-from-files', '--virtual-time-budget=5000', "--user-data-dir=$out\edge", '--window-size=1200,630',
    "--screenshot=$png", ('file:///' + ((Join-Path $out "$name.html") -replace '\\', '/')))
  $img = [System.Drawing.Image]::FromFile($png)
  $img.Save((Join-Path $repo "content\$($dest[$name])\share-card.jpg"), $jpeg, $q); $img.Dispose()
}
Start-Sleep -Seconds 1
Remove-Item -Recurse -Force $out
$report
