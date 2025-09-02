#!/bin/bash

# 🚀 Быстрая загрузка Pharos Testnet с GitHub на VPS
# Использование: curl -sSL https://raw.githubusercontent.com/USERNAME/pharos-testnet/main/quick-github-deploy.sh | bash -s -- -u USERNAME

set -e

# Цвета
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Парсинг аргументов
GITHUB_USERNAME=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--username)
            GITHUB_USERNAME="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

if [[ -z "$GITHUB_USERNAME" ]]; then
    log_error "Использование: $0 -u USERNAME"
    exit 1
fi

log_info "🚀 Быстрая загрузка Pharos Testnet с GitHub"
log_info "Пользователь: $GITHUB_USERNAME"

# Проверка root
if [[ $EUID -ne 0 ]]; then
    log_error "Запустите с sudo"
    exit 1
fi

# Обновление системы
log_info "Обновление системы..."
apt update -y

# Установка git
log_info "Установка Git..."
apt install -y git

# Создание директории
INSTALL_DIR="/opt/pharos-testnet"
log_info "Создание директории $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Клонирование репозитория
GITHUB_URL="https://github.com/$GITHUB_USERNAME/pharos-testnet.git"
log_info "Клонирование с $GITHUB_URL..."
if git clone "$GITHUB_URL" .; then
    log_success "✅ Репозиторий клонирован"
else
    log_error "❌ Ошибка клонирования"
    exit 1
fi

# Установка прав
chmod +x *.sh

# Создание пользователя
if ! id "pharos" &>/dev/null; then
    useradd -r -s /bin/bash -d "$INSTALL_DIR" -m pharos
fi

chown -R pharos:pharos "$INSTALL_DIR"

# Создание символических ссылок
ln -sf "$INSTALL_DIR/pharos-vps-setup.sh" /usr/local/bin/pharos-setup
ln -sf "$INSTALL_DIR/manage.sh" /usr/local/bin/pharos-manage

log_success "🎉 Загрузка завершена!"
echo ""
echo "📋 Следующие шаги:"
echo "  1. Запустите установку: sudo pharos-setup"
echo "  2. Запустите сервисы: sudo pharos-manage start"
echo "  3. Проверьте статус: sudo pharos-manage status"
echo ""
echo "📚 Документация: $INSTALL_DIR/README.md"
