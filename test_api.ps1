# Test API endpoint
$token = Read-Host "Enter JWT token"
$semester = "2024_2025_1"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Write-Host "Testing API: http://localhost:5128/api/lecturer/courses?semester=$semester"
$response = Invoke-RestMethod -Uri "http://localhost:5128/api/lecturer/courses?semester=$semester" -Headers $headers -Method Get

Write-Host "`nAPI Response:"
$response | ConvertTo-Json -Depth 10

Write-Host "`nTotal classes found: $($response.Count)"
