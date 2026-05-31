#!/usr/bin/env bash

# ========================================================
# 🦸‍♂️ DEXTERITY v4.0 - Современный инструмент для UserLAnd
# ========================================================

VERSION="4.0"
CONFIG_DIR="$HOME/.config/dexterity"
BACKUP_DIR="/sdcard/dexter_backups"
LOG_FILE="$CONFIG_DIR/dexterity.log"

# --- Цвета для gum (можно менять) ---
export GUM_CHOOSE_HEADER_FOREGROUND="212"
export GUM_CONFIRM_PROMPT_FOREGROUND="46"
export GUM_SPIN_SPINNER="dot"

# --- Инициализация ---
mkdir -p "$CONFIG_DIR"
touch "$LOG_FILE"

# --- Логирование ---
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# --- Функция установки пакетов с рекомендованными ---
smart_install() {
    local packages=("$@")
    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -qw "$pkg"; then
            echo "📦 Установка $pkg (с рекомендациями)..."
            sudo apt update &>/dev/null
            sudo apt install --install-recommends -y "$pkg" &>/dev/null
            if [ $? -eq 0 ]; then
                echo "✅ $pkg установлен"
            else
                echo "❌ Ошибка при установке $pkg"
                return 1
            fi
        else
            echo "✅ $pkg уже установлен"
        fi
    done
}

# --- Проверка зависимостей ---
check_deps() {
    local missing=()
    for cmd in gum ncdu nmap; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        gum style --foreground 196 "⚠️ Отсутствуют: ${missing[*]}"
        gum confirm "Установить необходимые пакеты?" && smart_install "${missing[@]}"
    fi
}

# --- 1. Настройка русского языка ---
setup_russian() {
    gum style --border normal --margin "1" --padding "1" --border-foreground 46 "🇷🇺 Настройка русского языка"
    if ! dpkg -l | grep -qw language-pack-ru; then
        sudo apt update &>/dev/null
        sudo apt install -y language-pack-ru &>/dev/null
    fi
    sudo locale-gen ru_RU.UTF-8 &>/dev/null
    export LANG=ru_RU.UTF-8
    export LC_ALL=ru_RU.UTF-8
    export LANGUAGE=ru_RU:ru
    grep -qxF 'export LANG=ru_RU.UTF-8' ~/.bashrc || {
        echo -e "\n# Русская локаль для DEXTERITY\nexport LANG=ru_RU.UTF-8\nexport LC_ALL=ru_RU.UTF-8\nexport LANGUAGE=ru_RU:ru" >> ~/.bashrc
    }
    gum style --foreground 46 "✅ Русская локаль настроена. Перезапусти терминал."
}

# --- 2. Перевод текста (gum input) ---
translate_text() {
    check_deps
    smart_install "translate-shell" &>/dev/null
    text=$(gum input --placeholder "Введите текст для перевода (en↔ru)" --width 60)
    if [ -n "$text" ]; then
        result=$(trans -b "$text" 2>&1)
        gum style --border normal --margin "1" --padding "1" --border-foreground 212 "$result"
    else
        gum style --foreground 196 "Текст не введён."
    fi
}

# --- 3. Проверка орфографии ---
spell_check() {
    check_deps
    smart_install "aspell" "aspell-ru"
    filepath=$(gum input --placeholder "Введите путь к файлу" --width 60)
    if [ -f "$filepath" ]; then
        gum spin --spinner dot --title "Проверяем орфографию..." -- aspell check -l ru "$filepath"
        gum style --foreground 46 "✅ Проверка завершена."
    else
        gum style --foreground 196 "Файл не найден: $filepath"
    fi
}

# --- 4. Системный монитор (исправлен) ---
system_monitor() {
    # CPU через /proc/stat
    cpu_usage() {
        local prev_idle prev_total
        read prev_idle prev_total < <(awk '/cpu / {print $5, $2+$3+$4+$5+$6+$7+$8}' /proc/stat)
        sleep 0.5
        read curr_idle curr_total < <(awk '/cpu / {print $5, $2+$3+$4+$5+$6+$7+$8}' /proc/stat)
        local idle=$(($curr_idle - $prev_idle))
        local total=$(($curr_total - $prev_total))
        echo $(($total - $idle)) $total
    }
    read cpu_busy cpu_total < <(cpu_usage)
    cpu_percent=$(( cpu_busy * 100 / cpu_total ))
    # RAM
    ram_total=$(free -k | awk '/Mem:/ {print $2}')
    ram_available=$(free -k | awk '/Mem:/ {print $7}')
    ram_used=$((ram_total - ram_available))
    ram_percent=$(( ram_used * 100 / ram_total ))
    # Disk
    disk_used=$(df -B1 / | awk 'NR==2 {print $3}')
    disk_total=$(df -B1 / | awk 'NR==2 {print $2}')
    disk_percent=$(( disk_used * 100 / disk_total ))
    # Uptime
    uptime=$(uptime -p | sed 's/up //')

    gum style --border normal --margin "1" --padding "1" --border-foreground 46 "📊 СИСТЕМНЫЙ МОНИТОР"
    gum style --foreground 212 "Загрузка CPU:    " && gum gauge --percent $cpu_percent --foreground 212 --border-foreground 212
    gum style --foreground 46  "Использование RAM:" && gum gauge --percent $ram_percent --foreground 46 --border-foreground 46
    gum style --foreground 99  "Использование диска:" && gum gauge --percent $disk_percent --foreground 99 --border-foreground 99
    echo ""
    gum style --foreground 226 "Аптайм: $uptime"
    echo ""
    read -n 1 -s -r -p "Нажмите любую клавишу для продолжения..."
}

# --- 5. Очистка системы ---
total_cleanup() {
    gum confirm "Очистить кэш apt, временные файлы и логи?" --affirmative "Да" --negative "Нет"
    if [ $? -eq 0 ]; then
        gum spin --spinner line --title "Очистка кэша apt..." -- sudo apt clean &>/dev/null && sudo apt autoclean -y &>/dev/null
        gum spin --spinner line --title "Очистка временных файлов..." -- sh -c 'rm -rf /tmp/* ~/.cache/*' &>/dev/null
        gum spin --spinner line --title "Очистка системных логов..." -- sudo rm -rf /var/log/* &>/dev/null
        gum style --foreground 46 "✅ Очистка завершена."
    fi
}

# --- 6. Умный бэкап ---
smart_backup() {
    mkdir -p "$BACKUP_DIR"
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_file="$BACKUP_DIR/dexterity_backup_$timestamp.tar.gz"
    gum confirm "Создать бэкап домашней директории?\nФайл: $backup_file" --affirmative "Да" --negative "Нет"
    if [ $? -eq 0 ]; then
        gum spin --spinner globe --title "Создание архива..." -- tar -czf "$backup_file" -C "$HOME" . &>/dev/null
        gum spin --spinner globe --title "Проверка целостности..." -- tar -tzf "$backup_file" &>/dev/null
        if [ $? -eq 0 ]; then
            gum style --foreground 46 "✅ Бэкап создан и проверен: $backup_file"
        else
            gum style --foreground 196 "❌ Ошибка при создании бэкапа."
        fi
    fi
}

# --- 7. Аудит сети (исправлен) ---
network_audit() {
    check_deps
    smart_install "arp-scan" "nmap"
    # Определяем интерфейс
    iface=$(ip route | grep default | awk '{print $5}' | head -1)
    if [ -z "$iface" ]; then
        gum style --foreground 196 "Не удалось определить сетевой интерфейс. Убедитесь, что Wi-Fi включён."
        return
    fi
    local_ip=$(ip -4 addr show "$iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    if [ -z "$local_ip" ]; then
        gum style --foreground 196 "Не удалось получить IP для интерфейса $iface."
        return
    fi
    network=$(echo "$local_ip" | cut -d. -f1-3)
    gum style --border normal --margin "1" --padding "1" --border-foreground 46 "🌐 Аудит сети"
    gum style "Ваш IP: $local_ip (интерфейс $iface)"
    gum style "Сканирование сети ${network}.0/24..."
    gum spin --spinner dot --title "Сканирование..." -- nmap -sn "${network}.0/24" -oG - | awk '/Up$/{print $2}' | while read ip; do
        echo "✅ $ip активен"
    done
    read -n 1 -s -r -p "Нажмите любую клавишу..."
}

# --- 8. Анализ диска ---
disk_usage() {
    check_deps
    target=$(gum choose "Домашняя директория (~)" "Вся система (/)" --header "Выберите директорию для анализа")
    case "$target" in
        "Домашняя директория (~)") dir="$HOME" ;;
        "Вся система (/)") dir="/" ;;
        *) return ;;
    esac
    clear
    ncdu "$dir" --color dark -e
    echo -e "\n"
    read -n 1 -s -r -p "Нажмите любую клавишу для продолжения..."
}

# --- Главное меню (gum) ---
main_menu() {
    while true; do
        clear
        gum style --border thick --margin "1" --padding "2 4" --border-foreground 99 "🦸‍♂️ DEXTERITY v$VERSION"
        choice=$(gum choose --height 15 --cursor.foreground 212 --header.foreground 46 \
            "🇷🇺 Настройка русского языка" \
            "🔄 Перевод текста (en↔ru)" \
            "📝 Проверка орфографии" \
            "📊 Системный монитор" \
            "🧹 Тотальная уборка" \
            "💾 Умный бэкап" \
            "🌐 Аудит сети" \
            "📁 Анализ диска" \
            "❌ Выход")
        case "$choice" in
            "🇷🇺 Настройка русского языка") setup_russian ;;
            "🔄 Перевод текста (en↔ru)") translate_text ;;
            "📝 Проверка орфографии") spell_check ;;
            "📊 Системный монитор") system_monitor ;;
            "🧹 Тотальная уборка") total_cleanup ;;
            "💾 Умный бэкап") smart_backup ;;
            "🌐 Аудит сети") network_audit ;;
            "📁 Анализ диска") disk_usage ;;
            "❌ Выход") echo -e "\nДо свидания, DEXTER!"; exit 0 ;;
        esac
    done
}

# --- Запуск ---
check_deps
main_menu
