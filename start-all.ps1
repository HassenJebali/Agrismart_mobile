<#
start-all.ps1
Launches all AgriSmart services in separate PowerShell windows.

Services started:
    1. MongoDB             - check only (start it manually if absent)
    2. Spring Boot         - spring_boot-main/                    (port 8082)
    3. API Gateway         - api-gateway/                         (port 8085)
    4. MCP Server          - chatbot-flask/mcp_server/app.py      (port 5001)
    5. Chatbot LangGraph   - chatbot-flask/agrismart_agents/app.py (port 5002)
    6. Angular             - agrismart-web/                       (port 4200)

Python prerequisites:
    Create the venv once before running this script:
        python -m venv .venv-1
        .venv-1\Scripts\Activate.ps1
        pip install -r chatbot-flask\requirements.txt

Usage:
    powershell -ExecutionPolicy Bypass -File .\start-all.ps1
#>

Set-StrictMode -Version Latest

$root         = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir   = Join-Path $root 'spring_boot-main'
$gatewayDir   = Join-Path $root 'api-gateway'
$frontendDir  = Join-Path $root 'agrismart-web'
$chatbotDir   = Join-Path $root 'chatbot-flask'
$mcpDir       = Join-Path $chatbotDir 'mcp_server'
$agentsDir    = Join-Path $chatbotDir 'agrismart_agents'
$venvActivate = Join-Path $root 'chatbot-flask\venv\Scripts\Activate.ps1'
$venvMlActivate = Join-Path $root '.venv-ml\Scripts\Activate.ps1'
$rootEnvFile  = Join-Path $root '.env'
$mlDir = Get-ChildItem -Path $root -Directory | Where-Object { $_.Name -like "*Detection*" -or $_.Name -like "*D?tection*" } | Select-Object -ExpandProperty FullName -First 1

function Import-EnvFile {
    param([string]$Path)
    if (-Not (Test-Path -LiteralPath $Path)) { return }
    Get-Content -LiteralPath $Path | ForEach-Object {
        $line = $_.Trim()
        if (-Not $line -or $line.StartsWith('#')) { return }
        $parts = $line.Split('=', 2)
        if ($parts.Count -lt 2) { return }
        $key   = $parts[0].Trim()
        $value = $parts[1].Trim().Trim('"').Trim("'")
        if ($key -and -not [string]::IsNullOrWhiteSpace($value)) {
            [Environment]::SetEnvironmentVariable($key, $value, 'Process')
        }
    }
}

function Start-Mongo {
    Write-Host "Checking MongoDB..."
    $svc = Get-Service -Name "MongoDB" -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq "Running") {
        Write-Host "  MongoDB is running (port 27017)." -ForegroundColor Green
    } else {
        Write-Host "  MongoDB not detected. Start it if needed:" -ForegroundColor Yellow
        Write-Host "    net start MongoDB  (PowerShell administrateur)" -ForegroundColor Yellow
    }
}

function Start-SpringBoot {
    Write-Host "Lancement Spring Boot (port 8082)..."
    Start-Process powershell -ArgumentList '-NoExit', '-Command',
        "Set-Location '$backendDir'; .\mvnw.cmd spring-boot:run" `
        -WorkingDirectory $backendDir
}

function Start-Gateway {
    Write-Host "Lancement API Gateway (port 8085)..."
    Start-Process powershell -ArgumentList '-NoExit', '-Command',
        "Set-Location '$gatewayDir'; ..\spring_boot-main\mvnw.cmd spring-boot:run" `
        -WorkingDirectory $gatewayDir
}

function Start-McpServer {
    Write-Host "Lancement MCP Server (port 5001)..."
    $activate = if (Test-Path -LiteralPath $venvActivate) { ". '$venvActivate'; " } else { "" }
    Start-Process powershell -ArgumentList '-NoExit', '-Command',
        "Set-Location '$mcpDir'; ${activate}python app.py" `
        -WorkingDirectory $mcpDir
}

function Start-Chatbot {
    Write-Host "Lancement Chatbot LangGraph (port 5002)..."
    $activate = if (Test-Path -LiteralPath $venvActivate) { ". '$venvActivate'; " } else { "" }
    Start-Process powershell -ArgumentList '-NoExit', '-Command',
        "Set-Location '$agentsDir'; ${activate}python app.py" `
        -WorkingDirectory $agentsDir
}

function Start-PlantAI {
    Write-Host "Lancement Plant Disease AI (port 8001)..."
    if (-not $mlDir) {
        Write-Host "  ERREUR : Dossier Détection de maladie non trouvé." -ForegroundColor Red
        return
    }
    $activate = if (Test-Path -LiteralPath $venvMlActivate) { ". '$venvMlActivate'; " } else { "" }
    Start-Process powershell -ArgumentList '-NoExit', '-Command',
        "Set-Location -LiteralPath '$mlDir'; ${activate}python app.py" `
        -WorkingDirectory $mlDir
}

function Start-Frontend {
    Write-Host "Lancement Angular (port 4200)..."
    Start-Process powershell -ArgumentList '-NoExit', '-Command',
        "Set-Location '$frontendDir'; npm install; npm start" `
        -WorkingDirectory $frontendDir
}

# --- Startup ------------------------------------------------------------------------
Write-Host "=== AgriSmart - Lancement des services ===" -ForegroundColor Cyan
Write-Host "Racine : $root"
Write-Host ""

Import-EnvFile -Path $rootEnvFile

Start-Mongo
Start-Sleep -Seconds 2

Start-SpringBoot
Start-Sleep -Seconds 3

Start-Gateway
Start-Sleep -Seconds 2

Start-McpServer
Start-Sleep -Seconds 1

Start-Chatbot
Start-Sleep -Seconds 1

Start-PlantAI
Start-Sleep -Seconds 1

Start-Frontend

Write-Host ""
Write-Host "=== Tous les services ont ete lances ===" -ForegroundColor Green
Write-Host "  Spring Boot  : http://localhost:8082"
Write-Host "  API Gateway  : http://localhost:8085"
Write-Host "  MCP Server   : http://localhost:5001/health"
Write-Host "  Chatbot      : http://localhost:5002/health"
Write-Host "  Angular      : http://localhost:4200"
Write-Host ""
Write-Host 'Smoke test : powershell -ExecutionPolicy Bypass -File .\smoke-test.ps1'	