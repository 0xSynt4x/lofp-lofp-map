# LOFP Map Setup — GitHub Pages Deployment
# 
# ANLEITUNG:
# 1. Die heruntergeladene "lofp_ultimate_map.html" als "index.html" in diesen Ordner kopieren
#    (E:\Projekte\lofp-map\index.html)
# 2. Dieses Script ausfuehren: .\setup.ps1

$ErrorActionPreference = "Stop"

if (-not (Test-Path "index.html")) {
    Write-Host "FEHLER: index.html nicht gefunden!" -ForegroundColor Red
    Write-Host "Bitte die heruntergeladene 'lofp_ultimate_map.html' als 'index.html' hierhin kopieren:" -ForegroundColor Yellow
    Write-Host "  E:\Projekte\lofp-map\index.html" -ForegroundColor Cyan
    exit 1
}

Write-Host "index.html gefunden. Starte GitHub-Setup..." -ForegroundColor Green

if (-not (Test-Path ".git")) {
    git init
    git branch -M main
}

$ghInstalled = Get-Command gh -ErrorAction SilentlyContinue
if ($ghInstalled) {
    Write-Host "GitHub CLI gefunden. Erstelle Repo..." -ForegroundColor Cyan
    gh repo create lofp-map --public --description "Interactive world map for Legends of Future Past MUD" --source . --remote origin --push
} else {
    Write-Host "GitHub CLI nicht installiert." -ForegroundColor Yellow
    Write-Host "  1. https://github.com/new -> Repo 'lofp-map' erstellen (Public)" -ForegroundColor White
    Write-Host "  2. Dann: git remote add origin https://github.com/jensoppermann/lofp-map.git" -ForegroundColor White
}

git add index.html
git commit -m "feat: LOFP Ultimate Map with pathfinding, locator, and exploit guide"
git push -u origin main

Write-Host ""
Write-Host "DONE! GitHub Pages aktivieren:" -ForegroundColor Green
Write-Host "  Repo Settings -> Pages -> Source: main branch -> Save" -ForegroundColor Cyan
Write-Host "  URL: https://jensoppermann.github.io/lofp-map/" -ForegroundColor Cyan
