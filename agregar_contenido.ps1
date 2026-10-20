<#
.SYNOPSIS
  Script para agregar películas o series al catálogo de StreamBox desde tu PC.
  Los cambios se guardan en catalog.json y se suben a GitHub para que aparezcan en tu iPhone al instante.
#>

param(
    [switch]$NoPush
)

$catalogPath = Join-Path $PSScriptRoot "catalog.json"
if (-not (Test-Path $catalogPath)) {
    Write-Error "No se encontró catalog.json en $catalogPath"
    exit 1
}

$catalog = Get-Content $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json

Clear-Host
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  StreamBox - Gestor de Contenido (PC)    " -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "1. Agregar Película"
Write-Host "2. Agregar Serie con Episodios"
Write-Host "3. Salir"
$opt = Read-Host "`nSelecciona una opción (1, 2 o 3)"

if ($opt -eq "1") {
    Write-Host "`n--- NUEVA PELÍCULA ---" -ForegroundColor Green
    $title = Read-Host "Título de la película"
    $id = "mov_" + ([System.Guid]::NewGuid().ToString().Substring(0,8))
    $poster = Read-Host "URL del Póster vertical (ej. https://.../poster.jpg)"
    $banner = Read-Host "URL del Banner horizontal (ej. https://.../banner.jpg)"
    $video = Read-Host "URL del Video (MP4 o M3U8)"
    $genre = Read-Host "Género (ej. Acción, Ciencia Ficción, Terror) [por defecto: Acción]"
    if ([string]::IsNullOrWhiteSpace($genre)) { $genre = "Acción" }
    $year = Read-Host "Año [por defecto: 2025]"
    if ([string]::IsNullOrWhiteSpace($year)) { $year = "2025" }
    $duration = Read-Host "Duración (ej. 1h 45m)"
    if ([string]::IsNullOrWhiteSpace($duration)) { $duration = "1h 45m" }
    $desc = Read-Host "Sinopsis / Descripción"

    $newMovie = [PSCustomObject]@{
        id = $id
        title = $title
        type = "movie"
        genre = $genre
        year = $year
        duration = $duration
        rating = "5.0"
        description = $desc
        posterUrl = $poster
        bannerUrl = $banner
        videoUrl = $video
        categories = @("Tendencias", "Películas", $genre)
    }

    $itemsList = [System.Collections.ArrayList]@($catalog.items)
    $itemsList.Insert(0, $newMovie)
    $catalog.items = $itemsList
    $catalog.updatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    $jsonStr = $catalog | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($catalogPath, $jsonStr, [System.Text.Encoding]::UTF8)
    Write-Host "`n✔ ¡Película '$title' agregada exitosamente a catalog.json!" -ForegroundColor Green

} elseif ($opt -eq "2") {
    Write-Host "`n--- NUEVA SERIE ---" -ForegroundColor Green
    $title = Read-Host "Título de la serie"
    $id = "ser_" + ([System.Guid]::NewGuid().ToString().Substring(0,8))
    $poster = Read-Host "URL del Póster vertical"
    $banner = Read-Host "URL del Banner horizontal"
    $genre = Read-Host "Género [por defecto: Drama]"
    if ([string]::IsNullOrWhiteSpace($genre)) { $genre = "Drama" }
    $year = Read-Host "Año [por defecto: 2025]"
    if ([string]::IsNullOrWhiteSpace($year)) { $year = "2025" }
    $desc = Read-Host "Sinopsis / Descripción"
    $epCount = [int](Read-Host "¿Cuántos episodios deseas agregar ahora?")

    $episodes = @()
    for ($i = 1; $i -le $epCount; $i++) {
        Write-Host "`n-- Episodio $i --" -ForegroundColor Cyan
        $epTitle = Read-Host "Título del Episodio $i"
        $epVideo = Read-Host "URL del video del Episodio $i"
        $epDur = Read-Host "Duración del Episodio (ej. 45m)"
        $epDesc = Read-Host "Descripción del episodio (opcional)"
        
        $episodes += [PSCustomObject]@{
            episodeNumber = $i
            title = if ([string]::IsNullOrWhiteSpace($epTitle)) { "Episodio $i" } else { $epTitle }
            duration = if ([string]::IsNullOrWhiteSpace($epDur)) { "45 min" } else { $epDur }
            description = $epDesc
            posterUrl = $poster
            videoUrl = $epVideo
        }
    }

    $season1 = [PSCustomObject]@{
        seasonNumber = 1
        title = "Temporada 1"
        episodes = $episodes
    }

    $newSeries = [PSCustomObject]@{
        id = $id
        title = $title
        type = "series"
        genre = $genre
        year = $year
        duration = "$epCount Episodios"
        rating = "5.0"
        description = $desc
        posterUrl = $poster
        bannerUrl = $banner
        categories = @("Tendencias", "Series", $genre)
        seasons = @($season1)
    }

    $itemsList = [System.Collections.ArrayList]@($catalog.items)
    $itemsList.Insert(0, $newSeries)
    $catalog.items = $itemsList
    $catalog.updatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    $jsonStr = $catalog | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($catalogPath, $jsonStr, [System.Text.Encoding]::UTF8)
    Write-Host "`n✔ ¡Serie '$title' con $epCount episodios agregada a catalog.json!" -ForegroundColor Green

} else {
    Write-Host "Operación cancelada."
    exit 0
}

# Subir a GitHub automáticamente
if (-not $NoPush) {
    $pushConfirm = Read-Host "`n¿Deseas subir los cambios a GitHub ahora para que aparezcan en tu iPhone? (S/N)"
    if ($pushConfirm -match "^[sSyY]") {
        git add catalog.json
        git commit -m "Update catalog: $title"
        git push
        Write-Host "`n🚀 ¡Cambios publicados! Abre la app StreamBox en tu iPhone para ver el nuevo contenido." -ForegroundColor Cyan
    }
}
