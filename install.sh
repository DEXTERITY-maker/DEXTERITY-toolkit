#!/bin/bash
# Универсальный установщик DEXTERITY v4.0

set -e  # Останавливаем скрипт при любой ошибке

# --- Переменные ---
REPO_URL="https://github.com/DEXTERITY-maker/DEXTERITY-toolkit"
BOT_NAME="dexterity"
INSTALL_DIR="/usr/local/bin"

# --- Цвета для красивого вывода ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Функции для красивого вывода ---
print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# --- Функция установки зависимостей для Linux ---
install_dependencies_linux() {
    print_status "Проверка и установка зависимостей (gum, ncdu, nmap)..."
    
    # Обновляем списки пакетов
    sudo apt-get update > /dev/null 2>&1 || true
    
    # Устанавливаем пакеты, если их нет
    for pkg in gum ncdu nmap; do
        if ! command -v $pkg &> /dev/null; then
            print_status "Установка $pkg..."
            sudo apt-get install -y $pkg > /dev/null 2>&1 || print_warning "Не удалось установить $pkg. Некоторые функции могут не работать."
        fi
    done
    
    # Специальная проверка для gum, т.к. его может не быть в репозиториях
    if ! command -v gum &> /dev/null; then
        print_warning "Gum не найден в стандартных репозиториях. Пытаемся установить из стороннего PPA..."
        sudo add-apt-repository -y ppa:charm-dev/stable > /dev/null 2>&1
        sudo apt-get update > /dev/null 2>&1
        sudo apt-get install -y gum > /dev/null 2>&1 || print_warning "Не удалось установить Gum. Интерфейс может работать некорректно."
    fi
}

# --- Основной процесс установки ---
print_status "Начинаю установку DEXTERITY v4.0..."

# 1. Установка зависимостей
install_dependencies_linux

# 2. Скачивание последней версии скрипта
print_status "Загрузка последней версии скрипта из репозитория..."
sudo wget -q -O "$INSTALL_DIR/$BOT_NAME" "$REPO_URL/raw/main/dexter.sh" || print_error "Не удалось загрузить скрипт. Проверьте соединение с интернетом."

# 3. Делаем скрипт исполняемым
sudo chmod +x "$INSTALL_DIR/$BOT_NAME"

print_success "DEXTERITY v4.0 успешно установлен!"
print_success "Теперь вы можете запустить его, просто набрав в терминале: $BOT_NAME"
echo ""
print_warning "Примечание: При первом запуске могут потребоваться дополнительные настройки."
