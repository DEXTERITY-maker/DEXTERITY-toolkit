#!/usr/bin/env bash

# ==============================================
# 🦸‍♂️ ИНСТРУМЕНТАРИЙ DEXTER v2.0
# Многофункциональный инструмент для работы с русским языком и системой в UserLAnd
# ==============================================

# Цвета для оформления вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- ФУНКЦИИ ДЛЯ РАБОТЫ С РУССКИМ ЯЗЫКОМ ---

# 1. Настройка русской локали
setup_russian() {
    echo -e "\n${GREEN}[🇷🇺 НАСТРОЙКА РУССКОГО ЯЗЫКА]${NC}"
    echo -e "${CYAN}Установка языковых пакетов и генерация локали...${NC}"
    
    # Установка языковых пакетов
    sudo apt update
    sudo apt install -y language-pack-ru
    
    # Генерация русской локали
    sudo locale-gen ru_RU.UTF-8
    
    # Настройка переменных окружения для текущей сессии
    export LANG=ru_RU.UTF-8
    export LC_ALL=ru_RU.UTF-8
    export LANGUAGE=ru_RU:ru
    
    # Добавление переменных в .bashrc для постоянного применения
    echo -e "\n# Русская локаль для DEXTER" >> ~/.bashrc
    echo "export LANG=ru_RU.UTF-8" >> ~/.bashrc
    echo "export LC_ALL=ru_RU.UTF-8" >> ~/.bashrc
    echo "export LANGUAGE=ru_RU:ru" >> ~/.bashrc
    
    echo -e "${GREEN}✅ Русская локаль успешно настроена!${NC}"
    echo -e "${YELLOW}⚠️ Перезапустите терминал для применения изменений.${NC}"
    read -p "Нажмите Enter, чтобы продолжить..."
}

# 2. Перевод текста (en -> ru, ru -> en)
translate_text() {
    echo -e "\n${GREEN}[🔄 ПЕРЕВОД ТЕКСТА]${NC}"
    
    # Проверка установки translate-shell
    if ! command -v trans &> /dev/null; then
        echo -e "${YELLOW}Установка translate-shell...${NC}"
        sudo apt install -y translate-shell
    fi
    
    echo -e "${CYAN}Выберите направление перевода:${NC}"
    echo "1) Английский → Русский"
    echo "2) Русский → Английский"
    read -p "Ваш выбор (1-2): " dir_choice
    
    case $dir_choice in
        1) from="en"; to="ru" ;;
        2) from="ru"; to="en" ;;
        *) echo -e "${RED}Неверный выбор.${NC}"; return ;;
    esac
    
    echo -e "${CYAN}Введите текст для перевода:${NC}"
    read -r text
    echo -e "${GREEN}Результат:${NC}"
    trans -b "$from:$to" "$text"
    read -p "Нажмите Enter, чтобы продолжить..."
}

# 3. Проверка орфографии в файле
spell_check() {
    echo -e "\n${GREEN}[📝 ПРОВЕРКА ОРФОГРАФИИ]${NC}"
    
    # Установка aspell и русского словаря
    if ! command -v aspell &> /dev/null; then
        echo -e "${YELLOW}Установка aspell и русского словаря...${NC}"
        sudo apt install -y aspell aspell-ru
    fi
    
    echo -n -e "${CYAN}Введите путь к файлу: ${NC}"
    read filepath
    
    if [ -f "$filepath" ]; then
        aspell check -l ru "$filepath"
        echo -e "${GREEN}✅ Проверка орфографии завершена.${NC}"
    else
        echo -e "${RED}❌ Файл не найден.${NC}"
    fi
    read -p "Нажмите Enter, чтобы продолжить..."
}

# 4. Транслитерация
transliterate() {
    echo -e "\n${GREEN}[🔤 ТРАНСЛИТЕРАЦИЯ (Русский → Латыница)]${NC}"
    
    echo -e "${CYAN}Введите текст на русском:${NC}"
    read -r text
    
    # Таблица транслитерации
    translit=$(echo "$text" | sed 'y/абвгдезийклмнопрстуфхцыэАБВГДЕЗИЙКЛМНОПРСТУФХЦЫЭ/abvgdezijklmnoprstufhcyeABVGDEZIJKLMNOPRSTUFHCYE/' | \
    sed 'y/ёЁ/yoYO/' | \
    sed 'y/жЖ/zhZH/' | \
    sed 'y/чЧ/chCH/' | \
    sed 'y/шШ/shSH/' | \
    sed 'y/щЩ/shshSHSH/' | \
    sed 'y/юЮ/yuYU/' | \
    sed 'y/яЯ/yaYA/' | \
    sed 'y/ьъЬЪ//' )
    
    echo -e "${GREEN}Результат транслитерации:${NC}"
    echo "$translit"
    read -p "Нажмите Enter, чтобы продолжить..."
}

# 5. Русская дата
russian_date() {
    echo -e "\n${GREEN}[📅 РУССКАЯ ДАТА]${NC}"
    
    # Временно устанавливаем русскую локаль только для этой команды
    LANG=ru_RU.UTF-8 date
    echo ""
    read -p "Нажмите Enter, чтобы продолжить..."
}

# 6. Анализ русских букв в файле
analyze_russian_chars() {
    echo -e "\n${GREEN}[🔍 АНАЛИЗ РУССКИХ БУКВ]${NC}"
    echo -e "${CYAN}Эта функция покажет строки, содержащие русские буквы.${NC}"
    echo -n -e "${CYAN}Введите путь к файлу: ${NC}"
    read filepath
    
    if [ -f "$filepath" ]; then
        echo -e "${GREEN}Строки с русскими буквами:${NC}"
        grep -P '[а-яА-ЯёЁ]' "$filepath"
    else
        echo -e "${RED}❌ Файл не найден.${NC}"
    fi
    read -p "Нажмите Enter, чтобы продолжить..."
}

# --- СИСТЕМНЫЕ ФУНКЦИИ ---

# Системный монитор
system_monitor() {
    echo -e "\n${GREEN}[🖥️ СИСТЕМНЫЙ МОНИТОР]${NC}"
    
    echo -e "${YELLOW}Информация о системе:${NC}"
    echo -e "${BLUE}-----------------------${NC}"
    echo -e "${CYAN}ОС:${NC} $(uname -o)"
    echo -e "${CYAN}Версия ядра:${NC} $(uname -r)"
    echo -e "${CYAN}Архитектура:${NC} $(uname -m)"
    echo ""
    
    echo -e "${YELLOW}Использование памяти (RAM):${NC}"
    free -h
    echo ""
    
    echo -e "${YELLOW}Информация о диске:${NC}"
    df -h /
    echo ""
    
    echo -e "${YELLOW}Топ 5 процессов по использованию CPU:${NC}"
    ps aux --sort=-%cpu | head -6
    echo ""
    
    echo -n -e "${CYAN}Сохранить отчёт в файл? (y/N): ${NC}"
    read save_report
    if [[ "$save_report" =~ ^[Yy]$ ]]; then
        report_file="system_report_$(date +%Y%m%d_%H%M%S).txt"
        {
            echo "=== СИСТЕМНЫЙ ОТЧЁТ DEXTER ==="
            echo "Дата: $(date)"
            echo ""
            echo "--- ОС и ядро ---"
            echo "ОС: $(uname -o)"
            echo "Версия ядра: $(uname -r)"
            echo "Архитектура: $(uname -m)"
            echo ""
            echo "--- Память ---"
            free -h
            echo ""
            echo "--- Диск ---"
            df -h /
            echo ""
            echo "--- Процессы ---"
            ps aux --sort=-%cpu | head -10
        } > "$report_file"
        echo -e "${GREEN}✅ Отчёт сохранён в $report_file${NC}"
    fi
    
    read -p "Нажмите Enter, чтобы продолжить..."
}

# Очистка системы
total_cleanup() {
    echo -e "\n${GREEN}[🧹 ТОТАЛЬНАЯ УБОРКА]${NC}"
    echo -e "${RED}ВНИМАНИЕ: Это действие очистит кэш и временные файлы.${NC}"
    read -p "Вы уверены? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Очистка отменена."
        read -p "Нажмите Enter, чтобы продолжить..."
        return
    fi

    # Очистка кэша apt
    echo -ne "${CYAN}Очистка кэша пакетов apt...${NC}"
    sudo apt clean && sudo apt autoclean -y > /dev/null 2>&1
    echo -e " ${GREEN}Готово${NC}"

    # Очистка временных файлов
    echo -ne "${CYAN}Очистка временных каталогов (/tmp, ~/.cache)...${NC}"
    rm -rf /tmp/* 2>/dev/null
    rm -rf ~/.cache/* 2>/dev/null
    echo -e " ${GREEN}Готово${NC}"

    # Очистка логов
    echo -ne "${CYAN}Очистка системных логов...${NC}"
    sudo rm -rf /var/log/* 2>/dev/null
    echo -e " ${GREEN}Готово${NC}"

    # Анализ неиспользуемых пакетов
    echo -e "${CYAN}Поиск неиспользуемых пакетов...${NC}"
    sudo apt autoremove --dry-run

    echo -e "${GREEN}Очистка завершена!${NC}"
    read -p "Нажмите Enter, чтобы продолжить..."
}

# Резервное копирование
smart_backup() {
    echo -e "\n${GREEN}[💾 УМНЫЙ БЭКАП]${NC}"
    backup_dir="/sdcard/dexter_backups"
    mkdir -p "$backup_dir" 2>/dev/null
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_file="$backup_dir/termux_backup_$timestamp.tar.gz"

    echo -e "${CYAN}Будет создан архив: ${backup_file}${NC}"
    echo -e "${YELLOW}В него войдут ваши домашняя директория (~) и все установленные пакеты.${NC}"
    read -p "Начать резервное копирование? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Бэкап отменен."
        read -p "Нажмите Enter, чтобы продолжить..."
        return
    fi

    echo -e "${CYAN}Создание резервной копии...${NC}"
    tar -czf "$backup_file" -C ~ . 2>/dev/null

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Бэкап успешно создан: ${backup_file}${NC}"
        
        # Проверка целостности архива
        echo -e "${CYAN}Проверка целостности архива...${NC}"
        if tar -tzf "$backup_file" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Архив цел и не повреждён.${NC}"
            ls -lh "$backup_file"
        else
            echo -e "${RED}❌ Архив повреждён! Попробуйте создать бэкап заново.${NC}"
        fi
    else
        echo -e "${RED}❌ Ошибка при создании бэкапа.${NC}"
    fi
    read -p "Нажмите Enter, чтобы продолжить..."
}

# Аудит сети
network_audit() {
    echo -e "\n${GREEN}[🌐 АУДИТ СЕТИ]${NC}"
    
    # Определение IP и подсети
    local_ip=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)
    
    if [ -z "$local_ip" ]; then
        echo -e "${RED}Не удалось определить IP-адрес. Убедитесь, что Wi-Fi включен.${NC}"
    else
        # Проверка установки nmap
        if ! command -v nmap &> /dev/null; then
            echo -e "${YELLOW}Установка nmap...${NC}"
            sudo apt install -y nmap
        fi
        
        network=$(echo "$local_ip" | cut -d. -f1-3)
        echo -e "${CYAN}Ваш IP: ${local_ip}${NC}"
        echo -e "${CYAN}Сканирование сети ${network}.0/24...${NC}"
        echo -e "${YELLOW}Активные устройства в сети:${NC}"
        nmap -sn "${network}.0/24" | grep -E "Nmap scan report for|MAC" | sed 's/Nmap scan report for/Host:/'
    fi
    read -p "Нажмите Enter, чтобы продолжить..."
}

# Анализ диска
disk_usage() {
    echo -e "\n${GREEN}[📊 АНАЛИЗ ДИСКА]${NC}"
    
    # Проверка установки ncdu
    if ! command -v ncdu &> /dev/null; then
        echo -e "${YELLOW}Установка ncdu...${NC}"
        sudo apt install -y ncdu
    fi
    
    echo -e "${CYAN}Какую директорию проанализировать?${NC}"
    echo "1) Домашняя директория (~)"
    echo "2) Вся система (/)"
    read -p "Ваш выбор (1-2): " disk_choice

    case $disk_choice in
        1) target_dir="$HOME" ;;
        2) target_dir="/" ;;
        *) echo -e "${RED}Неверный выбор.${NC}"; read -p "Нажмите Enter..."; return ;;
    esac

    echo -e "${YELLOW}Анализ ${target_dir}...${NC}"
    ncdu "$target_dir" --color dark -e
    
    read -p "Нажмите Enter, чтобы продолжить..."
}

# --- ГЛАВНОЕ МЕНЮ ---
show_banner() {
    clear
    echo -e "${CYAN}=============================================${NC}"
    echo -e "${PURPLE}     🦸‍♂️ ИНСТРУМЕНТАРИЙ DEXTER v2.0${NC}"
    echo -e "${CYAN}=============================================${NC}"
    echo -e "${BLUE}        Ваш помощник в мире Linux на Android${NC}"
    echo -e "${CYAN}=============================================${NC}"
    echo ""
}

while true; do
    show_banner
    echo -e "${CYAN}🇷🇺 РАБОТА С РУССКИМ ЯЗЫКОМ:${NC}"
    echo "1)  Настройка русского языка"
    echo "2)  Перевод текста (en↔ru)"
    echo "3)  Проверка орфографии в файле"
    echo "4)  Транслитерация (русская → латыница)"
    echo "5)  Русская дата"
    echo "6)  Анализ русских букв в файле"
    echo ""
    echo -e "${CYAN}🖥️ СИСТЕМНЫЕ ФУНКЦИИ:${NC}"
    echo "7)  Системный монитор"
    echo "8)  Тотальная уборка"
    echo "9)  Умный бэкап"
    echo "10) Аудит сети"
    echo "11) Анализ диска"
    echo ""
    echo "0)  ❌ Выход"
    echo ""
    read -p "Ваш выбор: " choice

    case $choice in
        1) setup_russian ;;
        2) translate_text ;;
        3) spell_check ;;
        4) transliterate ;;
        5) russian_date ;;
        6) analyze_russian_chars ;;
        7) system_monitor ;;
        8) total_cleanup ;;
        9) smart_backup ;;
        10) network_audit ;;
        11) disk_usage ;;
        0) echo -e "${GREEN}До свидания, DEXTER!${NC}"; exit 0 ;;
        *) echo -e "${RED}Неверный выбор. Попробуйте снова.${NC}"; sleep 1 ;;
    esac
done
