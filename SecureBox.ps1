# ==========================================
# SecureBox: Транспорт и проверка (Test)
# ==========================================

Write-Host "=== Инициализация подключения ===" -ForegroundColor Cyan
$ServerIP = Read-Host "Введите IP-адрес сервера"
$Username = Read-Host "Введите логин (нажмите Enter для 'root')"
if ([string]::IsNullOrWhiteSpace($Username)) { $Username = "root" }

$KeyPath = "$env:USERPROFILE\.ssh\id_ed25519"
$PubKeyPath = "$KeyPath.pub"

# 1. Генерация ключей
Write-Host "`n[1] Проверка SSH-ключей..." -ForegroundColor Yellow
if (!(Test-Path $KeyPath)) {
    Write-Host "Генерируем новые SSH ключи ED25519..."
    ssh-keygen -t ed25519 -C "securebox_transport" -f $KeyPath -N '""' | Out-Null
    Write-Host "Ключи успешно созданы!" -ForegroundColor Green
} else {
    Write-Host "Ключи уже существуют, используем их." -ForegroundColor Green
}

# 2. Передача файлов (Транспорт)
Write-Host "`n[2] Отправка файлов в /root/ (Потребуется пароль от $Username)..." -ForegroundColor Yellow
# Отправляем публичный ключ и плейбук прямо в корень root
scp -o StrictHostKeyChecking=no playbook.yml $PubKeyPath "${Username}@${ServerIP}:/root/"

# 3. Установка Ansible и запуск плейбука
Write-Host "`n[3] Запуск инициализации на сервере (Потребуется пароль от $Username)..." -ForegroundColor Yellow

# Команда, которая выполнится на сервере: ставим ansible и запускаем плейбук из /root/
$RemoteCommand = @"
    export DEBIAN_FRONTEND=noninteractive;
    apt-get update -qq;
    apt-get install ansible -y -qq;
    ansible-playbook /root/playbook.yml -c local;
"@

ssh -o StrictHostKeyChecking=no "${Username}@${ServerIP}" $RemoteCommand

Write-Host "`n=== Тест транспорта завершен! ===" -ForegroundColor Cyan
Pause