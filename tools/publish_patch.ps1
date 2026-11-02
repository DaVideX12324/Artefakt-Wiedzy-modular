# Publikacja paczki aktualizacji: wydanie z .pck w DaVideX12324/ArtefaktWiedzy-updates + manifest w gist.
# Użycie (po eksporcie łatki w Godocie): dwuklik publish_patch.bat albo  powershell -File tools/publish_patch.ps1 [ścieżka.pck]
#   domyślnie build/<platforma>/patch.pck (zapas: build/patch.pck); wersja i build z resources/build.json (podbija je ExportCheck).
# Paczki są skumulowane względem bazy, więc manifest wskazuje tylko najnowszą. Link do pełnego exe (url) zostaje z gista.
# -Platform android: baza = base_android z build.json, wpis "android" w manifeście (reszta manifestu zostaje).
# -Full: pełny exe (build/windows/ArtefaktWiedzy.exe) jako nowa baza — gra pobiera go sama (wpis "exe", ExeUpdater) i podmienia się.
# -Base N: łatka na starą bazę N (np. starsze exe graczy) — wpis główny gista (czytany przez stare exe) dla tej bazy.
param([string]$Pck = "", [string]$Platform = "windows", [switch]$Full, [int]$Base = 0)
$ErrorActionPreference = "Stop"
# Okno z wtyczki: przy sukcesie zamyka się samo, przy błędzie czeka na Enter.
trap { Write-Host $_ -ForegroundColor Red; Read-Host "Enter, aby zamknąć"; exit 1 }
Set-Location (Join-Path $PSScriptRoot "..")

$Repo = "DaVideX12324/ArtefaktWiedzy-updates"
$Gist = "cc2274c3de25a1ee9a122ad9419097a8"
# Łatka ma KB–MB; pełny pck (bez 'Eksportuj jako łatkę') ma ~220 MB.
$MaxMB = 50

if ($Full) { if (-not $Pck) { $Pck = "build/windows/ArtefaktWiedzy.exe" } }
elseif (-not $Pck) { $Pck = "build/$Platform/patch.pck"; if (-not (Test-Path $Pck)) { $Pck = "build/patch.pck" } }
if (-not (Test-Path $Pck)) { throw "Brak paczki: $Pck" }
if (-not $Full -and (Get-Item $Pck).Length -gt $MaxMB * 1MB) { throw "Paczka ma ponad $MaxMB MB — to pełny pck? Eksportuj z zaznaczonym 'Eksportuj jako łatkę'." }
$info = Get-Content "resources/build.json" -Raw -Encoding UTF8 | ConvertFrom-Json
$version = [string]$info.version
$build = [int]$info.build
$android = $Platform -eq "android"
$base = if ($Base -gt 0) { $Base } elseif ($android) { [int]$info.base_android } else { [int]$info.base }
$asset = if ($Full) { "ArtefaktWiedzy.exe" } elseif ($android) { "patch_android_$build.pck" } else { "patch_$build.pck" }
$tmp = Join-Path ([IO.Path]::GetTempPath()) ("aw_patch_" + [guid]::NewGuid())
New-Item -ItemType Directory $tmp | Out-Null
try {
	Copy-Item $Pck (Join-Path $tmp $asset)
	Write-Host "Wydanie $version (build $build): $Pck"
	$notesPath = Join-Path $tmp "notes.md"
	[IO.File]::WriteAllText($notesPath, $(if ($info.notes) { [string]$info.notes } else { "Paczka $version (build $build)" }), (New-Object Text.UTF8Encoding $false))
	$tag = "$version-build$build" + $(if ($Full) { "-full" } elseif ($android) { "-android" } else { "" })  # build w tagu: kilka łatek tej samej wersji
	# Wydanie już jest (ta sama paczka publikowana drugi raz, np. z -Base) — tylko podmiana pliku.
	cmd /c "gh release view $tag -R $Repo >nul 2>&1"  # przez cmd: stderr gh ("release not found") przy Stop w PS 5.1 przerywał skrypt
	if ($LASTEXITCODE -eq 0) { gh release upload $tag (Join-Path $tmp $asset) -R $Repo --clobber }
	else { gh release create $tag (Join-Path $tmp $asset) -R $Repo -t "$version (build $build$(if ($android) { ', Android' }))" -F $notesPath }
	if ($LASTEXITCODE -ne 0) { throw "wysłanie wydania nie powiodło się" }
	$url = "https://github.com/$Repo/releases/download/$tag/$asset"

	# Obecny manifest z gista: pozostałe wpisy zostają. Pełny exe idzie do osobnego wpisu "exe" (ExeUpdater). Łatki — do
	# "bases"[baza] (nowe exe), a wpis główny (stare exe czytają tylko jego) tylko dla bazy, którą już opisuje — stare exe
	# zawsze dostaną łatkę z ExeUpdaterem, kolejność i liczba wydań nie mają znaczenia.
	# Bez --jq: PowerShell 5.1 gubi cudzysłowy w argumentach (".files[\"version.json\"]") i odczyt wychodził pusty.
	$gistJson = gh api "gists/$Gist" | Out-String
	if ($LASTEXITCODE -ne 0) { throw "odczyt gista nie powiódł się" }
	$current = [string](($gistJson | ConvertFrom-Json).files.'version.json'.content)
	$old = if ($current.Trim()) { $current | ConvertFrom-Json } else { $null }
	$manifest = [ordered]@{}
	if ($old) { foreach ($p in $old.PSObject.Properties) { $manifest[$p.Name] = $p.Value } }
	$exeUrl = if ($Full) { $url } elseif ($old -and $old.exe) { [string]$old.exe.url } else { "" }
	if ($Full) {
		$manifest["exe"] = [ordered]@{ version = $version; build = $build; base = $build; url = $url }
		if (-not $old) { $manifest["version"] = $version; $manifest["build"] = $build; $manifest["base"] = $build; $manifest["patches"] = @() }
	} else {
		$entry = [ordered]@{ version = $version; build = $build; base = $base; url = $(if ($android) { "" } else { $exeUrl }); patches = @([ordered]@{ build = $build; url = $url }) }
		if ($android) { $manifest["android"] = $entry }
		else {
			$bases = [ordered]@{}
			if ($old -and $old.bases) { foreach ($p in $old.bases.PSObject.Properties) { $bases[$p.Name] = $p.Value } }
			$bases["$base"] = [ordered]@{ version = $version; build = $build; patches = $entry.patches }
			$manifest["bases"] = $bases
			if (-not $old -or [int]$old.base -eq $base -or -not $old.exe -or $Base -gt 0) { foreach ($k in $entry.Keys) { $manifest[$k] = $entry[$k] } }
		}
	}
	# „pobierz” w starych exe przy innej bazie = pełny exe z GitHuba (bez Mega).
	if (-not $android -and $exeUrl) { $manifest["url"] = $exeUrl }
	$manifest.Remove("exe_url")
	$body = @{ files = @{ "version.json" = @{ content = ($manifest | ConvertTo-Json -Depth 8) } } } | ConvertTo-Json -Depth 10
	$bodyPath = Join-Path $tmp "body.json"
	[IO.File]::WriteAllText($bodyPath, $body, (New-Object Text.UTF8Encoding $false))
	gh api -X PATCH "gists/$Gist" --input $bodyPath | Out-Null
	if ($LASTEXITCODE -ne 0) { throw "aktualizacja gista nie powiodła się" }
	Write-Host "Gist zaktualizowany: $version, build $build"
	Write-Host $url
} finally {
	Remove-Item -Recurse -Force $tmp
}
