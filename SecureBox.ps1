# ==========================================
# SecureBox: Транспорт и проверка (Исправленный v2)
# ==========================================

Write-Host "=== Инициализация подключения ===" -ForegroundColor Cyan
$ServerIP = Read-Host "Введите IP-адрес сервера"
$Username = Read-Host "Введите логин (нажмите Enter для 'root')"
if ([string]::IsNullOrWhiteSpace($Username)) { $Username = "root" }

# Определяем пути
$SshFolder = "$env:USERPROFILE\.ssh"
$KeyPath = "$SshFolder\id_ed25519"
$PubKeyPath = "$KeyPath.pub"
$PlaybookPath = Join-Path -Path $PSScriptRoot -ChildPath "playbook.yml"

# 1. Проверка и создание SSH-ключей
Write-Host "`n[1] Проверка SSH-ключей..." -ForegroundColor Yellow

if (!(Test-Path $SshFolder)) {
    New-Item -ItemType Directory -Force -Path $SshFolder | Out-Null
}

if (!(Test-Path $KeyPath)) {
    Write-Host "Генерируем новые SSH ключи ED25519..."
    ssh-keygen -t ed25519 -C "securebox_transport" -f $KeyPath -N "" | Out-Null
    Write-Host "Ключи успешно созданы!" -ForegroundColor Green
} else {
    Write-Host "Ключи уже существуют, используем их." -ForegroundColor Green
}

if (!(Test-Path $PlaybookPath)) {
    Write-Host "[ОШИБКА] playbook.yml не найден в папке $PSScriptRoot!" -ForegroundColor Red
    Pause
    exit
}

# --- НОВОЕ: Очистка старого отпечатка сервера ---
Write-Host "`n[!] Очистка старых записей known_hosts (защита от конфликтов)..." -ForegroundColor DarkGray
ssh-keygen -R $ServerIP 2>$null | Out-Null
# ------------------------------------------------

# 2. Передача файлов (Транспорт)
Write-Host "`n[2] Отправка файлов в /root/ (Потребуется пароль от $Username)..." -ForegroundColor Yellow
scp -o StrictHostKeyChecking=no "$PlaybookPath" "$PubKeyPath" "${Username}@${ServerIP}:/root/"

# 3. Запуск инициализации на сервере
Write-Host "`n[3] Запуск инициализации на сервере (Потребуется пароль от $Username)..." -ForegroundColor Yellow

# ОДНОСТРОЧНАЯ команда для Linux
$RemoteCommand = "export DEBIAN_FRONTEND=noninteractive; apt-get update -qq; apt-get install ansible -y -qq; ansible-playbook /root/playbook.yml -c local"

ssh -o StrictHostKeyChecking=no "${Username}@${ServerIP}" $RemoteCommand

Write-Host "`n=== Тест транспорта завершен! ===" -ForegroundColor Cyan
Pause
