param(
    [string]$GatewayBaseUrl = "http://localhost:8081",
    [string]$AdminEmail = "admin@agrismart.gn",
    [string]$AdminPassword = "admin123",
    [string]$UserEmail = "visiteur@agrismart.gn",
    [string]$UserPassword = "Test@1234"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-JsonPost {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][hashtable]$Body,
        [hashtable]$Headers = @{}
    )

    $jsonBody = $Body | ConvertTo-Json -Depth 6
    return Invoke-RestMethod -Method Post -Uri $Url -Headers $Headers -ContentType "application/json" -Body $jsonBody
}

function Resolve-AccessToken {
    param(
        [Parameter(Mandatory = $true)]$LoginResponse
    )

    if ($null -eq $LoginResponse) {
        return $null
    }

    if ($LoginResponse.PSObject.Properties.Name -contains 'token' -and $LoginResponse.token) {
        return [string]$LoginResponse.token
    }
    if ($LoginResponse.PSObject.Properties.Name -contains 'accessToken' -and $LoginResponse.accessToken) {
        return [string]$LoginResponse.accessToken
    }
    if ($LoginResponse.PSObject.Properties.Name -contains 'access_token' -and $LoginResponse.access_token) {
        return [string]$LoginResponse.access_token
    }

    return $null
}

function Assert-StatusCode {
    param(
        [Parameter(Mandatory = $true)][scriptblock]$Action,
        [Parameter(Mandatory = $true)][int]$ExpectedStatus,
        [Parameter(Mandatory = $true)][string]$Label
    )

    try {
        & $Action | Out-Null
        if ($ExpectedStatus -eq 200) {
            Write-Host "[OK] $Label (200)" -ForegroundColor Green
            return
        }
        throw "Expected status $ExpectedStatus but request succeeded with 200"
    } catch {
        $status = $null
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
            $status = [int]$_.Exception.Response.StatusCode
        }

        if ($status -eq $ExpectedStatus) {
            Write-Host "[OK] $Label ($ExpectedStatus)" -ForegroundColor Green
            return
        }

        throw "[KO] $Label expected $ExpectedStatus but got $status. Details: $($_.Exception.Message)"
    }
}

Write-Host "== AgriSmart P0 smoke test ==" -ForegroundColor Cyan

$adminLogin = Invoke-JsonPost -Url "$GatewayBaseUrl/api/auth/login" -Body @{
    email = $AdminEmail
    password = $AdminPassword
}

$adminToken = Resolve-AccessToken -LoginResponse $adminLogin
if (-not $adminToken) {
    throw "[KO] Admin login did not return an access token"
}
Write-Host "[OK] Admin login + JWT token" -ForegroundColor Green

$userLogin = Invoke-JsonPost -Url "$GatewayBaseUrl/api/auth/login" -Body @{
    email = $UserEmail
    password = $UserPassword
}
$userToken = Resolve-AccessToken -LoginResponse $userLogin
if (-not $userToken) {
    throw "[KO] User login did not return an access token"
}
Write-Host "[OK] User login + JWT token" -ForegroundColor Green

$adminHeaders = @{ Authorization = "Bearer $adminToken" }
$userHeaders = @{ Authorization = "Bearer $userToken" }

$health = Invoke-RestMethod -Method Get -Uri "$GatewayBaseUrl/api/health" -Headers $adminHeaders
if (-not $health) {
    throw "[KO] Backend health endpoint returned empty response"
}
Write-Host "[OK] Backend API reachable through gateway" -ForegroundColor Green

$chatbotAuth = Invoke-RestMethod -Method Get -Uri "$GatewayBaseUrl/api/chatbot/health" -Headers $adminHeaders
if ($chatbotAuth.status -ne "ok") {
    throw "[KO] Chatbot health check failed"
}
Write-Host "[OK] Chatbot health via Spring Boot proxy" -ForegroundColor Green

$chatbotResponse = Invoke-JsonPost -Url "$GatewayBaseUrl/api/chatbot/message" -Headers $adminHeaders -Body @{
    query = "Donne moi un conseil de navigation pour les utilisateurs"
    lang = "fr"
}
if (-not $chatbotResponse.response) {
    throw "[KO] Chatbot message endpoint returned no response"
}
Write-Host "[OK] Chatbot message returns a valid response" -ForegroundColor Green

Assert-StatusCode -ExpectedStatus 200 -Label "ADMIN can access /api/users" -Action {
    Invoke-RestMethod -Method Get -Uri "$GatewayBaseUrl/api/users" -Headers $adminHeaders
}

Assert-StatusCode -ExpectedStatus 403 -Label "Non-admin is blocked on /api/users" -Action {
    Invoke-RestMethod -Method Get -Uri "$GatewayBaseUrl/api/users" -Headers $userHeaders
}

Write-Host "== Smoke test completed successfully ==" -ForegroundColor Cyan
