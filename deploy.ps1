# Schritt 1: Repo erstellen und Map deployen
# Voraussetzung: gh CLI installiert + authentifiziert

Set-Location "E:\Projekte\lofp-map"

# Prüfe gh auth
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "gh nicht eingeloggt. Bitte zuerst: gh auth login" -ForegroundColor Red
    exit 1
}

# Prüfe ob index.html da ist
if (-not (Test-Path "index.html")) {
    Write-Host "index.html fehlt! Bitte die 'lofp_ultimate_map.html' als 'index.html' hierhin kopieren:" -ForegroundColor Red
    Write-Host "  E:\Projekte\lofp-map\index.html" -ForegroundColor Cyan
    exit 1
}

# Git init falls nötig
if (-not (Test-Path ".git")) { git init; git branch -M main }

# Repo erstellen
Write-Host "Erstelle GitHub Repo..." -ForegroundColor Cyan
gh repo create lofp-map --public --description "LOFP Interactive World Map" --source . --remote origin 2>$null

# Falls Repo schon existiert, remote setzen
$remoteExists = git remote get-url origin 2>$null
if (-not $remoteExists) {
    git remote add origin "https://github.com/jensoppermann/lofp-map.git"
}

# Commit + Push
git add -A
git commit -m "feat: LOFP Ultimate Map — pathfinding, locator, exploit guide" 2>$null
git push -u origin main --force

# GitHub Pages aktivieren
Write-Host "Aktiviere GitHub Pages..." -ForegroundColor Cyan
gh api repos/jensoppermann/lofp-map/pages -X POST -f "build_type=workflow" -f "source[branch]=main" -f "source[path]=/" 2>$null
# Fallback für ältere gh Versionen
gh repo edit --enable-pages 2>$null

Write-Host "`nFERTIG!" -ForegroundColor Green
Write-Host "URL: https://jensoppermann.github.io/lofp-map/" -ForegroundColor Cyan
Write-Host "`nFalls Pages nicht automatisch aktiv:" -ForegroundColor Yellow
Write-Host "  https://github.com/jensoppermann/lofp-map/settings/pages" -ForegroundColor White
Write-Host "  Source: Deploy from branch -> main -> / (root) -> Save" -ForegroundColor White
