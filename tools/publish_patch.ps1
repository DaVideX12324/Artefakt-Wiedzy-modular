# Publikacja paczki aktualizacji: wydanie z .pck w DaVideX12324/ArtefaktWiedzy-updates + manifest w gist.
# Użycie (po eksporcie łatki w Godocie): dwuklik publish_patch.bat albo  powershell -File tools/publish_patch.ps1 [ścieżka.pck]
#   domyślnie build/patch.pck; wersja i build z resources/build.json (podbija je ExportCheck).
# Paczki są skumulowane względem bazy, więc manifest wskazuje tylko najnowszą. Link do pełnego exe (url) zostaje z gista.
param([string]$Pck = "build/patch.pck")
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

$Repo = "DaVideX12324/ArtefaktWiedzy-updates"
$Gist = "cc2274c3de25a1ee9a122ad9419097a8"
# Pełny exe (gdy paczka się nie pobierze albo przy nowej bazie).
$FullUrl = "https://mega.nz/folder/ZJVTTSLb#PtinvmoFu9NuOYVPZRQ7Fw"
# Łatka ma KB–MB; pełny pck (bez 'Eksportuj jako łatkę') ma ~220 MB.
$MaxMB = 50

if (-not (Test-Path $Pck)) { throw "Brak paczki: $Pck" }
if ((Get-Item $Pck).Length -gt $MaxMB * 1MB) { throw "Paczka ma ponad $MaxMB MB — to pełny pck? Eksportuj z zaznaczonym 'Eksportuj jako łatkę'." }
$info = Get-Content "resources/build.json" -Raw | ConvertFrom-Json
$version = [string]$info.version
$build = [int]$info.build
$asset = "patch_$build.pck"
$tmp = Join-Path ([IO.Path]::GetTempPath()) ("aw_patch_" + [guid]::NewGuid())
New-Item -ItemType Directory $tmp | Out-Null
try {
	Copy-Item $Pck (Join-Path $tmp $asset)
	Write-Host "Wydanie $version (build $build): $Pck"
	gh release create $version (Join-Path $tmp $asset) -R $Repo -t $version -n $(if ($info.notes) { [string]$info.notes } else { "Paczka $version (build $build)" })
	if ($LASTEXITCODE -ne 0) { throw "gh release create nie powiodło się" }
	$url = "https://github.com/$Repo/releases/download/$version/$asset"

	$manifest = [ordered]@{ version = $version; build = $build; url = $FullUrl; patches = @([ordered]@{ build = $build; url = $url }) }
	$body = @{ files = @{ "version.json" = @{ content = ($manifest | ConvertTo-Json -Depth 5) } } } | ConvertTo-Json -Depth 6
	$bodyPath = Join-Path $tmp "body.json"
	[IO.File]::WriteAllText($bodyPath, $body, (New-Object Text.UTF8Encoding $false))
	gh api -X PATCH "gists/$Gist" --input $bodyPath | Out-Null
	if ($LASTEXITCODE -ne 0) { throw "aktualizacja gista nie powiodła się" }
	Write-Host "Gist zaktualizowany: $version, build $build"
	Write-Host $url
} finally {
	Remove-Item -Recurse -Force $tmp
}
