# Odoo Development Environment - PowerShell Start Script

$ErrorActionPreference = "Stop"

# Colors
function Write-Color {
    param($Text, $Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

Write-Color "`n==========================================" "Cyan"
Write-Color "Odoo Development Environment" "Cyan"
Write-Color "==========================================" "Cyan"
Write-Host ""

# Load environment variables
if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.+)$") {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
}

$env_port = $env:HOST_PORT
if (-not $env_port) { $env_port = "8089" }

$admin_pass = $env:ADMIN_PASSWORD
if (-not $admin_pass) { $admin_pass = "Adasoft@2025" }

$db_name = $env:POSTGRES_DB
if (-not $db_name) { $db_name = "adasoft" }

# Check Docker
try {
    docker --version | Out-Null
} catch {
    Write-Color "Error: Docker is not installed or not running" "Red"
    exit 1
}

try {
    docker-compose --version | Out-Null
    $dc = "docker-compose"
} catch {
    try {
        docker compose version | Out-Null
        $dc = "docker compose"
    } catch {
        Write-Color "Error: docker-compose not found" "Red"
        exit 1
    }
}

# Check if first run
if (-not (Test-Path ".initialized")) {
    Write-Color "`nFirst run detected - Building images..." "Cyan"
    Write-Host "This will take 5-10 minutes...`n"
    
    & $dc build
    
    if ($LASTEXITCODE -eq 0) {
        New-Item -ItemType File -Path ".initialized" -Force | Out-Null
        Write-Color "✓ Build complete`n" "Green"
    } else {
        Write-Color "✗ Build failed" "Red"
        exit 1
    }
}

# Start services
Write-Color "Starting services..." "Cyan"
& $dc up -d

if ($LASTEXITCODE -ne 0) {
    Write-Color "✗ Failed to start services" "Red"
    exit 1
}

Write-Color "✓ Services started`n" "Green"

# Wait for services
Write-Color "Waiting for services to be ready..." "Cyan"
Start-Sleep -Seconds 5

# Check if services are running
$status = & $dc ps
if (-not ($status -match "odoo_web.*Up")) {
    Write-Color "✗ Odoo container failed to start" "Red"
    Write-Host "Check logs: docker-compose logs web"
    exit 1
}

Write-Color "✓ All services are running`n" "Green"

# Display info
Write-Color "==========================================" "Green"
Write-Color "✓✓✓ Odoo is Ready! ✓✓✓" "Green"
Write-Color "==========================================" "Green"
Write-Host ""

Write-Color "Access URLs:" "Blue"
Write-Color "  Odoo:    http://localhost:$env_port" "Cyan"
Write-Color "  pgAdmin: http://localhost:5050" "Cyan"
Write-Host ""

Write-Color "Default Credentials:" "Blue"
Write-Host "  Master Password: $admin_pass"
Write-Host "  pgAdmin Email:   admin@admin.com"
Write-Host "  pgAdmin Pass:    $admin_pass"
Write-Host ""
Write-Host "  After creating database:"
Write-Host "  Database: $db_name"
Write-Host "  Email:    admin"
Write-Host "  Password: admin"
Write-Host ""

Write-Color "==========================================" "Blue"
Write-Color "Features Enabled:" "Blue"
Write-Color "==========================================" "Blue"
Write-Host ""
Write-Host "  ✓ Auto-reload (watchdog)"
Write-Host "  ✓ Dev mode enabled"
Write-Host "  ✓ QWeb debugging"
Write-Host "  ✓ Assets debugging"
Write-Host ""
Write-Color "Edit files in addons\ → Save → Auto reload!" "Yellow"
Write-Host ""

Write-Color "==========================================" "Blue"
Write-Color "Useful Commands:" "Blue"
Write-Color "==========================================" "Blue"
Write-Host ""
Write-Host "  View logs:        docker-compose logs -f web"
Write-Host "  Restart:          docker-compose restart"
Write-Host "  Stop:             docker-compose down"
Write-Host "  Shell:            docker-compose exec web bash"
Write-Host "  Database shell:   docker-compose exec db psql -U odoo"
Write-Host ""

Write-Color "==========================================" "Blue"
Write-Color "Next Steps:" "Blue"
Write-Color "==========================================" "Blue"
Write-Host ""
Write-Host "1. Open Odoo: http://localhost:$env_port"
Write-Host "2. Create your first database"
Write-Host "3. Start developing!"
Write-Host ""
Write-Color "==========================================" "Cyan"
Write-Host ""
