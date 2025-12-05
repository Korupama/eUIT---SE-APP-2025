# ===================================================
# CONFIG
# ===================================================
$baseUrl = "http://localhost:5128"
$userId = "80068"
$password = "12345678"
$role = "lecturer"

$outputFile = "result.json"

# ===================================================
# LOGIN
# ===================================================
$loginBody = @{
    userId = $userId
    password = $password
    role = $role
} | ConvertTo-Json

try {
    $loginRes = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
} catch {
    Write-Host "❌ Login failed"
    exit
}

$token = $loginRes.accessToken
Write-Host "✔ Logged in, token collected"

# Prepare results array
$results = @()

# ===================================================
# Helper function for requests
# ===================================================
function Run-Test {
    param (
        [string]$name,
        [string]$method,
        [string]$url,
        $body = $null
    )

    Write-Host "→ Testing $name"

    try {
        if ($body) {
            $response = Invoke-RestMethod `
                -Uri $url `
                -Method $method `
                -Headers @{ Authorization = "Bearer $token" } `
                -Body ($body | ConvertTo-Json) `
                -ContentType "application/json"
        }
        else {
            $response = Invoke-RestMethod `
                -Uri $url `
                -Method $method `
                -Headers @{ Authorization = "Bearer $token" }
        }

        $results += @{
            name = $name
            success = $true
            data = $response
        }
    }
    catch {
        $results += @{
            name = $name
            success = $false
            error = $_.Exception.Message
        }
    }
}

# ===================================================
# TEST LIST
# ===================================================

Run-Test "profile" "GET" "$baseUrl/api/lecturer/profile"
Run-Test "courses_all" "GET" "$baseUrl/api/lecturer/courses"
Run-Test "schedule_month" "GET" "$baseUrl/api/lecturer/schedule/month"
Run-Test "exams_all" "GET" "$baseUrl/api/lecturer/exams"
Run-Test "notifications" "GET" "$baseUrl/api/lecturer/notifications"
Run-Test "tuition" "GET" "$baseUrl/api/lecturer/tuition?mssv=23520541"
Run-Test "grades_class" "GET" "$baseUrl/api/lecturer/grades?classCode=IT001.Q11"
Run-Test "absence_history" "GET" "$baseUrl/api/lecturer/absences"

# ===================================================
# EXPORT JSON
# ===================================================
$final = @{
    timestamp = (Get-Date)
    lecturer = $userId
    resultCount = $results.Count
    results = $results
}

$final | ConvertTo-Json -Depth 10 | Set-Content -Path $outputFile -Encoding UTF8

Write-Host "✔ All test results written to $outputFile"
Write-Host "Done!"
