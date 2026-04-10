Write-Host "Suche lofp_ultimate_map.html im Downloads-Ordner..." -ForegroundColor Cyan
$downloads = "$env:USERPROFILE\Downloads"
$source = Get-ChildItem $downloads -Filter "lofp*ultimate*map*" -Recurse -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $source) {
    $source = Get-ChildItem $downloads -Filter "lofp*map*" -Recurse -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
}
if ($source) {
    Copy-Item $source.FullName "E:\Projekte\lofp-map\index.html" -Force
    Write-Host "Kopiert: $($source.FullName) -> E:\Projekte\lofp-map\index.html" -ForegroundColor Green
    Write-Host "Dateigroesse: $([math]::Round($source.Length/1024)) KB" -ForegroundColor Gray
} else {
    Write-Host "Nicht gefunden! Bitte manuell die Datei 'lofp_ultimate_map.html' von Claude runterladen." -ForegroundColor Red
    Write-Host "Dann: copy <pfad>\lofp_ultimate_map.html E:\Projekte\lofp-map\index.html" -ForegroundColor Yellow
}
