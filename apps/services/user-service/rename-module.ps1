# Đường dẫn đến file .env
$envFile = ".env"

# Kiểm tra file tồn tại
if (-Not (Test-Path $envFile)) {
    Write-Host "❌ File .env không tồn tại!" -ForegroundColor Red
    exit 1
}

# Đọc APP_NAME từ file .env
$APP_NAME = Get-Content $envFile | Where-Object { $_ -match "^APP_NAME=" } | ForEach-Object {
    ($_ -split "=", 2)[1].Trim()
}

if (-not $APP_NAME) {
    Write-Host "❌ APP_NAME không được tìm thấy trong .env!" -ForegroundColor Red
    exit 1
}

# Định nghĩa tên module cũ và mới
$OLD_MODULE = "github.com/evrone/go-clean-template"
$NEW_MODULE = "github.com/hoan02/$APP_NAME"

Write-Host "🔧 Replacing module name:"
Write-Host "From: $OLD_MODULE"
Write-Host "To:   $NEW_MODULE`n"

# Danh sách file cần sửa
$extensions = @("*.go", "*.mod", "*.md", "*.yml", "*.yaml")

foreach ($ext in $extensions) {
    Get-ChildItem -Path . -Filter $ext -Recurse | ForEach-Object {
        $filePath = $_.FullName
        $content = Get-Content -Path $filePath -Raw
        $updatedContent = $content -replace [regex]::Escape($OLD_MODULE), $NEW_MODULE
        $updatedContent | Set-Content -Path $filePath
        Write-Host "✅ Updated: $filePath"
    }
}

Write-Host "`n🎉 Done! Running go mod tidy..."

go mod tidy
