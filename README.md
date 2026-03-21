EU
# SecureBox: Automated VPS Hardening Suite

**SecureBox** is a professional software suite designed for the automated deployment and security hardening of servers running **Ubuntu 24.04 LTS**. Implementing the "Security by Default" philosophy, it transforms a clean OS installation into a hardened node compliant with modern information security standards.

## System Architecture

The project utilizes a hybrid management model:

1.  **Transport Layer (PowerShell 7+):** Executed client-side (Windows/Linux). It generates `ED25519` cryptographic keys, clears `known_hosts` to mitigate Man-In-The-Middle (MITM) risks, and securely delivers configurations to the target server via SCP.
2.  **Orchestration Layer (Ansible):** Executed locally on the server (Localhost execution). It performs idempotent configuration of all system components.
3.  **Audit Layer (Lynis):** Conducts automated system audits before and after configuration, providing empirical evidence of security improvements via the Hardening Index.

## Security Profiles

The system offers two distinct configuration tiers:

| Feature | Standard (`playbook-standard.yml`) | Maximum (`playbook-maximum.yml`) |
| :--- | :--- | :--- |
| **Lynis Index** | **~67/100** | **~77/100** |
| **SSH Hardening** | Random port, Key-only auth, Root disabled | + Session limits, timeouts, VERBOSE logging |
| **Network Security** | UFW (Deny All Inbound), Fail2Ban | + Disabling DCCP, SCTP, RDS, TIPC protocols |
| **Audit & Monitoring** | Baseline (Lynis) | + `auditd`, `acct`, `sysstat`, `rkhunter`, `AIDE` |
| **Physical Security** | — | USB-storage module disabling |
| **Compliance** | General Hardening | **CIS Benchmarks** alignment |

## Key Features

* **Dynamic Randomization:** Every deployment is unique. The system generates random 10-character usernames, SSH ports (45000-60000), and 20-character sudo passwords.
* **Cryptographic Strength:** Total transition from password-based authentication to `ED25519` ECC keys.
* **Intelligent Fail2Ban:** Automatically reconfigures the jail to monitor the dynamically generated SSH port.
* **Cloud-Init Override:** Forcibly overrides insecure default settings provided by cloud vendors (e.g., DigitalOcean, AWS) via `/etc/ssh/sshd_config.d/`.
* **Automated Cleanup (Anti-Forensics):** Upon successful deployment, the script removes playbooks and public keys from the `/root/` directory, leaving no deployment artifacts behind.

## Deployment Instructions

1.  **Clone the repository:**
2.  **Select your profile:** Choose either `playbook-standard.yml` or `playbook-maximum.yml` and rename the selected file to **`playbook.yml`**.
3.  **Execute the Transport Script:** Run the `.ps1` script via PowerShell.
4.  **Configuration:** Enter the server IP and `root` password when prompted (required twice: for file delivery and Ansible initialization).
5.  **IMPORTANT:** Securely save the final report generated in the console. **Port 22 will be closed immediately upon completion.**

## Lynis Audit Results

In the **Maximum** profile, the system automatically implements advanced security controls:
* **File Integrity Monitoring:** Installation of `AIDE`. Due to the intensive indexing process, the initial database must be initialized manually:
    ```bash
    sudo aideinit
    ```
* **Intrusion Detection:** Integration of the `rkhunter` (Rootkit Hunter) scanner.
* **Legal Compliance:** Implementation of Legal Banners (banners/motd) in the terminal greeting to warn unauthorized users.
* **Kernel Hardening:** Tuning system parameters via `sysctl` to mitigate network attacks (e.g., ICMP-redirect protection).

---

RU
# SecureBox: Automated VPS Hardening Suite

**SecureBox** — это программный комплекс для автоматизированного развертывания и укрепления (hardening) безопасности серверов под управлением **Ubuntu 24.04 LTS**. Проект реализует концепцию "Security by Default", превращая чистую систему в защищенный узел, соответствующий современным стандартам информационной безопасности.

## Архитектура системы

Проект построен на гибридной модели управления:
1.  **Transport Layer (PowerShell 7+):** Выполняется на стороне клиента (Windows/Linux). Генерирует криптографические ключи `ED25519`, очищает `known_hosts` для предотвращения атак типа MITM и безопасно доставляет конфигурацию на целевой сервер через SCP.
2.  **Orchestration Layer (Ansible):** Выполняется локально на сервере (Localhost execution). Реализует идемпотентную настройку всех системных компонентов.
3.  **Audit Layer (Lynis):** Проводит автоматический аудит системы до и после применения настроек, предоставляя числовое подтверждение эффективности защиты (Hardening Index).

## Профили защиты

Система предлагает два уровня жесткости конфигурации:

| Характеристика | Standard (`playbook-standard.yml`) | Maximum (`playbook-maximum.yml`) |
| :--- | :--- | :--- |
| **Lynis Index** | **~67/100** | **~77/100** |
| **SSH Hardening** | Случайный порт, без паролей, без root | + Ограничение сессий, таймаутов и логирование VERBOSE |
| **Сетевая защита** | UFW (Deny All Inbound), Fail2Ban | + Отключение протоколов DCCP, SCTP, RDS, TIPC |
| **Аудит** | Базовый (Lynis) | + `auditd`, `acct`, `sysstat`, `rkhunter` |
| **Физическая защита** | — | Отключение модулей USB-storage |
| **Compliance** | Базовый Hardening | Соответствие стандартам CIS Benchmarks |

## Основные возможности

* **Динамическая рандомизация:** Каждое развертывание уникально. Генерируются случайные имена пользователей (10 символов), SSH-порты (45000-60000) и sudo-пароли (20 символов).
* **Криптографическая стойкость:** Полный отказ от парольной аутентификации в пользу ключей `ED25519`.
* **Интеллектуальный Fail2Ban:** Автоматически настраивается на прослушивание динамического SSH-порта.
* **Борьба с Cloud-Init:** Принудительное переопределение небезопасных настроек облачных провайдеров в `/etc/ssh/sshd_config.d/`.
* **Самоуничтожение (Anti-Forensics):** После успешного деплоя скрипт удаляет плейбуки и публичные ключи из директории `/root/`, не оставляя следов автоматизации.

## Инструкция по запуску

1.  Клонируйте репозиторий
2.  Определите, нужна версия `playbook-standard` или `playbook-maximum`, переименуйте нужный в `playbook.yml`
3.  Запустите транспортный скрипт(.ps1) через PowerShell
4.  Введите IP-адрес сервера и пароль `root` (потребуется дважды: для доставки файлов и запуска Ansible).
5.  **Важно:** Сохраните итоговый отчет, который появится в консоли! После завершения порт 22 будет закрыт.

## Результаты аудита Lynis

В версии **Maximum** система автоматически внедряет контроли безопасности, которые значительно повышают доверие к узлу:
* Установка системного аудитора `auditd` запуск производится вручную, ввиду длительности запуска:  
  ```bash  
  sudo aideinit  
  ```  
* Интеграция сканера руткитов `rkhunter`.
* Внедрение юридических баннеров (Legal Banners) в приветствие терминала.
* Харденинг параметров ядра через `sysctl` (защита от ICMP-redirect атак).
