#!/usr/bin/env bash

# ========================================================
# 🦸‍♂️ ИНСТРУМЕНТАРИЙ DEXTERITY v3.0
# Многофункциональный инструмент для работы с русским языком и системой в UserLAnd
# ========================================================

# --- Конфигурация ---
VERSION="3.0"
CONFIG_DIR="$HOME/.config/dexterity"
BACKUP_DIR="/sdcard/dexter_backups"
LOG_FILE="$CONFIG_DIR/dexterity.log"

# --- Цвета и стили ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# --- Инициализация ---
mkdir -p "$CONFIG_DIR"
touch "$LOG_FILE"

# --- Вспомогательные функции ---
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

show_loading() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

check_and_install() {
    local package=$1
    local command=${2:-$package}
    if ! command -v "$command" &> /dev/null; then
        echo -e "${YELLOW}⚠️ $package не установлен. Установить? (y/N): ${NC}"
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            echo -e "${CYAN}Установка $package...${NC}"
            sudo apt update &> /dev/null
            sudo apt install -y "$package" &> /dev/null &
            show_loading $!
            if command -v "$command" &> /dev/null; then
                echo -e "${GREEN}✅ $package установлен.${NC}"
            else
                echo -e "${RED}❌ Не удалось установить $package.${NC}"
                return 1
            fi
        else
            return 1
        fi
    fi
    return 0
}

# --- Основные функции ---

setup_russian() {
    dialog --title "🇷🇺 Настройка русского языка" --infobox "Установка языковых пакетов и генерация локали..." 5 50
    sleep 1
    sudo apt update &> /dev/null
    sudo apt install -y language-pack-ru &> /dev/null
    sudo locale-gen ru_RU.UTF-8 &> /dev/null
    export LANG=ru_RU.UTF-8
    export LC_ALL=ru_RU.UTF-8
    export LANGUAGE=ru_RU:ru
    grep -qxF 'export LANG=ru_RU.UTF-8' ~/.bashrc || echo -e "\n# Русская локаль для DEXTERITY\nexport LANG=ru_RU.UTF-8\nexport LC_ALL=ru_RU.UTF-8\nexport LANGUAGE=ru_RU:ru" >> ~/.bashrc
    dialog --title "Готово" --msgbox "Русская локаль успешно настроена!\n\nПерезапустите терминал для применения изменений." 8 50
}

translate_text() {
    check_and_install "translate-shell" "trans" || return
    TEMP_FILE=$(mktemp)
    dialog --title "Перевод текста" --inputbox "Введите текст для перевода (en ↔ ru):" 10 60 2>"$TEMP_FILE"
    text=$(<"$TEMP_FILE")
    rm -f "$TEMP_FILE"
    if [ -n "$text" ]; then
        result=$(trans -b "$text" 2>&1)
        dialog --title "Результат перевода" --msgbox "$result" 20 70
    else
        dialog --title "Ошибка" --msgbox "Текст не был введен." 6 40
    fi
}

spell_check() {
    check_and_install "aspell" "aspell" || return
    check_and_install "aspell-ru" "aspell" || return
    TEMP_FILE=$(mktemp)
    dialog --title "Проверка орфографии" --inputbox "Введите путь к файлу:" 8 50 2>"$TEMP_FILE"
    filepath=$(<"$TEMP_FILE")
    rm -f "$TEMP_FILE"
    if [ -f "$filepath" ]; then
        dialog --title "Результат проверки" --infobox "Проверка орфографии в файле...\n$filepath" 5 60
        sleep 1
        aspell check -l ru "$filepath"
        dialog --title "Готово" --msgbox "Проверка орфографии завершена." 6 40
    else
        dialog --title "Ошибка" --msgbox "Файл не найден: $filepath" 6 60
    fi
}

system_monitor() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    RAM_USAGE=$(free | grep Mem | awk '{printf("%.1f"), $3/$2 * 100.0}')
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    UPTIME=$(uptime -p | sed 's/up //')
    
    dialog --title "🖥️ Системный монитор" --gauge "Загрузка CPU: $CPU_USAGE%" 10 50 $CPU_USAGE
    dialog --title "🖥️ Системный монитор" --gauge "Загрузка RAM: $RAM_USAGE%" 10 50 $RAM_USAGE
    dialog --title "🖥️ Системный монитор" --gauge "Загрузка диска: $DISK_USAGE%" 10 50 $DISK_USAGE
    
    INFO="System Uptime: $UPTIME\n\n$(df -h | head -2)\n\n$(free -h)\n\n$(ps aux --sort=-%cpu | head -6)"
    dialog --title "Полная информация о системе" --msgbox "$INFO" 25 70
}

total_cleanup() {
    dialog --title "Тотальная уборка" --yesno "Очистить кэш, временные файлы и логи?" 7 50
    if [ $? -eq 0 ]; then
        (
            echo "10"; echo "XXX"; echo "Очистка кэша apt..."; echo "XXX"
            sudo apt clean &> /dev/null && sudo apt autoclean -y &> /dev/null
            echo "40"; echo "XXX"; echo "Очистка временных файлов..."; echo "XXX"
            rm -rf /tmp/* &> /dev/null && rm -rf ~/.cache/* &> /dev/null
            echo "70"; echo "XXX"; echo "Очистка системных логов..."; echo "XXX"
            sudo rm -rf /var/log/* &> /dev/null
            echo "100"; echo "XXX"; echo "Готово!"; echo "XXX"
        ) | dialog --title "Очистка системы" --gauge "Выполняется..." 8 70 0
        dialog --title "Готово" --msgbox "Очистка завершена!" 6 40
    fi
}

smart_backup() {
    mkdir -p "$BACKUP_DIR"
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_file="$BACKUP_DIR/dexterity_backup_$timestamp.tar.gz"
    dialog --title "Резервное копирование" --yesno "Создать бэкап домашней директории?\n\nФайл будет сохранен в:\n$backup_file" 10 60
    if [ $? -eq 0 ]; then
        (
            echo "10"; echo "XXX"; echo "Создание архива..."; echo "XXX"
            tar -czf "$backup_file" -C "$HOME" . &> /dev/null
            echo "90"; echo "XXX"; echo "Проверка целостности..."; echo "XXX"
            if tar -tzf "$backup_file" &> /dev/null; then
                echo "100"; echo "XXX"; echo "Бэкап успешно создан!"; echo "XXX"
            else
                dialog --title "Ошибка" --msgbox "Ошибка при создании бэкапа!" 6 40
                return
            fi
        ) | dialog --title "Создание бэкапа" --gauge "Выполняется..." 8 70 0
        dialog --title "Готово" --msgbox "Бэкап успешно создан и проверен!\n\n$backup_file" 8 60
    fi
}

network_audit() {
    if ! command -v nmap &> /dev/null; then
        dialog --title "Ошибка" --msgbox "nmap не установлен. Установите его: sudo apt install nmap" 6 50
        return
    fi
    local_ip=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)
    if [ -z "$local_ip" ]; then
        dialog --title "Ошибка" --msgbox "Не удалось определить IP-адрес. Убедитесь, что Wi-Fi включен." 6 60
        return
    fi
    network=$(echo "$local_ip" | cut -d. -f1-3)
    dialog --title "Аудит сети" --infobox "Ваш IP: $local_ip\nСканирование сети ${network}.0/24..." 5 60
    sleep 2
    scan_result=$(nmap -sn "${network}.0/24" | grep -E "Nmap scan report for|MAC" | sed 's/Nmap scan report for/Host:/')
    dialog --title "Результаты аудита сети" --msgbox "$scan_result" 20 70
}

disk_usage() {
    if ! command -v ncdu &> /dev/null; then
        dialog --title "Ошибка" --msgbox "ncdu не установлен. Установите его: sudo apt install ncdu" 6 50
        return
    fi
    TEMP_FILE=$(mktemp)
    dialog --title "Анализ диска" --menu "Выберите директорию для анализа:" 12 50 2 \
        1 "Домашняя директория (~)" \
        2 "Вся система (/)" \
        2>"$TEMP_FILE"
    choice=$(<"$TEMP_FILE")
    rm -f "$TEMP_FILE"
    case $choice in
        1) target="$HOME" ;;
        2) target="/" ;;
        *) return ;;
    esac
    clear
    ncdu "$target" --color dark -e
    echo -e "${GREEN}Анализ завершён. Нажмите Enter, чтобы вернуться в меню...${NC}"
    read
}

# --- Основное меню ---
while true; do
    choice=$(dialog --clear --title "🦸‍♂️ ИНСТРУМЕНТАРИЙ DEXTERITY v$VERSION" \
        --menu "Выберите действие с помощью стрелок и нажмите Enter:" 22 60 15 \
        1 "🇷🇺 Настройка русского языка" \
        2 "🔄 Перевод текста (en ↔ ru)" \
        3 "📝 Проверка орфографии в файле" \
        4 "🖥️ Системный монитор" \
        5 "🧹 Тотальная уборка" \
        6 "💾 Умный бэкап" \
        7 "🌐 Аудит сети" \
        8 "📊 Анализ диска (NCDU)" \
        0 "❌ Выход" \
        3>&1 1>&2 2>&3 3>&-)
    case $? in
        0)
            case $choice in
                1) setup_russian ;;
                2) translate_text ;;
                3) spell_check ;;
                4) system_monitor ;;
                5) total_cleanup ;;
                6) smart_backup ;;
                7) network_audit ;;
                8) disk_usage ;;
                0) break ;;
            esac
            ;;
        1) break ;;
        255) break ;;
    esac
done
clear
echo -e "${GREEN}До свидания, DEXTER!${NC}"
exit 0
