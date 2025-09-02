#!/bin/bash

# 🚀 Скрипт развертывания Pharos тестнета на VPS Ubuntu
# Автор: Pharos Team
# Версия: 2.0 (исправленная)

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функции логирования
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка root прав
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Этот скрипт должен быть запущен с правами root (sudo)"
        exit 1
    fi
}

# Проверка системы
check_system() {
    log_info "Проверка системы..."
    
    if [[ ! -f /etc/os-release ]]; then
        log_error "Неподдерживаемая система"
        exit 1
    fi
    
    source /etc/os-release
    
    if [[ "$ID" != "ubuntu" ]]; then
        log_error "Этот скрипт предназначен для Ubuntu. Обнаружена: $ID"
        exit 1
    fi
    
    UBUNTU_VERSION=$(echo "$VERSION_ID" | cut -d'.' -f1)
    if [[ "$UBUNTU_VERSION" -lt 20 ]]; then
        log_error "Требуется Ubuntu 20.04+. Обнаружена: $VERSION_ID"
        exit 1
    fi
    
    log_success "✅ Обнаружена Ubuntu $VERSION_ID"
}

# Обновление системы
update_system() {
    log_info "Обновление системы..."
    apt update && apt upgrade -y
    log_success "✅ Система обновлена"
}

# Установка зависимостей
install_dependencies() {
    log_info "Установка зависимостей..."
    
    # Основные пакеты
    apt install -y curl wget git unzip software-properties-common \
                   build-essential libssl-dev libffi-dev python3-dev \
                   python3-pip python3-venv
    
    # Python 3.13+ (если доступен)
    if ! python3 --version | grep -q "3.1[3-9]\|3\.[2-9][0-9]"; then
        log_info "Установка Python 3.13+..."
        add-apt-repository ppa:deadsnakes/ppa -y
        apt update
        apt install -y python3.13 python3.13-venv python3.13-dev
        update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 1
        update-alternatives --install /usr/bin/python3 python3.13 /usr/bin/python3.13 1
    fi
    
    # Node.js для Ganache
    log_info "Установка Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt install -y nodejs
    
    # Docker
    log_info "Установка Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker $SUDO_USER
    
    # Docker Compose
    log_info "Установка Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # UFW
    log_info "Установка UFW..."
    apt install -y ufw
    
    log_success "✅ Зависимости установлены"
}

# Создание пользователя
create_user() {
    log_info "Создание пользователя pharos..."
    
    if ! id "pharos" &>/dev/null; then
        useradd -r -s /bin/bash -d /opt/pharos-testnet -m pharos
        log_success "✅ Пользователь pharos создан"
    else
        log_info "Пользователь pharos уже существует"
    fi
}

# Создание проекта
create_project() {
    log_info "Создание проекта..."
    
    PROJECT_DIR="/opt/pharos-testnet"
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"
    
    # Создание виртуального окружения
    log_info "Создание Python виртуального окружения..."
    python3 -m venv venv
    source venv/bin/activate
    
    # Установка Python зависимостей
    log_info "Установка Python зависимостей..."
    pip install --upgrade pip
    pip install flask flask-cors psutil
    
    # Создание requirements.txt
    cat > requirements.txt << EOF
# Основные зависимости для Pharos тестнета
requests>=2.28.0
web3>=6.0.0
eth-account>=0.8.0
eth-utils>=2.0.0
pytest>=7.0.0
pytest-asyncio>=0.21.0
aiohttp>=3.8.0
asyncio-mqtt>=0.11.0
cryptography>=3.4.0
pyyaml>=6.0
click>=8.0.0
rich>=12.0.0
flask>=2.3.0
flask-cors>=4.0.0
psutil>=5.9.0
EOF
    
    pip install -r requirements.txt
    
    # Создание конфигурации
    log_info "Создание конфигурации..."
    cat > config.yaml << EOF
# Конфигурация Pharos тестнета
network:
  name: "Pharos Testnet"
  chain_id: 1337
  rpc_url: "http://0.0.0.0:8545"
  ws_url: "ws://0.0.0.0:8546"
  
node:
  host: "0.0.0.0"
  rpc_port: 8545
  ws_port: 8546
  data_dir: "/opt/pharos-testnet/data"
  
mining:
  enabled: true
  difficulty: 1
  gas_limit: 8000000
  
accounts:
  - name: "Alice"
    private_key: "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    balance: "1000000000000000000000"
  - name: "Bob"
    private_key: "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"
    balance: "1000000000000000000000"
EOF
    
    # Создание genesis блока
    log_info "Создание genesis блока..."
    cat > genesis.json << EOF
{
  "config": {
    "chainId": 1337,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "berlinBlock": 0,
    "londonBlock": 0
  },
  "difficulty": "1",
  "gasLimit": "8000000",
  "alloc": {
    "0x70997970C51812dc3A010C7d01b50e0d17dc79C8": {
      "balance": "1000000000000000000000"
    },
    "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC": {
      "balance": "1000000000000000000000"
    }
  }
}
EOF
    
    # Создание Docker Compose
    log_info "Создание Docker Compose..."
    cat > docker-compose.yml << EOF
version: '3.8'

services:
  ganache:
    image: trufflesuite/ganache:latest
    container_name: pharos-ganache
    ports:
      - "8545:8545"
      - "8546:8546"
    environment:
      - GANACHE_DB=/data/ganache-db
      - GANACHE_DETERMINISTIC=true
      - GANACHE_MNEMONIC="test test test test test test test test test test test test junk"
      - GANACHE_NETWORK_ID=1337
      - GANACHE_CHAIN_ID=1337
      - GANACHE_GAS_LIMIT=8000000
      - GANACHE_GAS_PRICE=20000000000
      - GANACHE_ACCOUNTS=10
      - GANACHE_DEFAULT_BALANCE_ETHER=1000
    volumes:
      - ./data/ganache:/data
    networks:
      - pharos-network

  grafana:
    image: grafana/grafana:latest
    container_name: pharos-grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - ./data/grafana:/var/lib/grafana
    networks:
      - pharos-network

networks:
  pharos-network:
    driver: bridge
EOF
    
    # Создание директорий
    mkdir -p data/ganache data/grafana logs
    
    # Установка прав доступа
    chown -R pharos:pharos "$PROJECT_DIR"
    chmod +x *.sh 2>/dev/null || true
    
    log_success "✅ Проект создан"
}

# Настройка systemd сервисов
setup_systemd() {
    log_info "Настройка systemd сервисов..."
    
    # Сервис для Docker Compose
    cat > /etc/systemd/system/pharos-docker.service << EOF
[Unit]
Description=Pharos Testnet Docker Services
After=network-online.target docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
User=pharos
Group=pharos
WorkingDirectory=/opt/pharos-testnet
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    # Включение сервиса
    systemctl daemon-reload
    systemctl enable pharos-docker
    
    log_success "✅ Systemd сервисы настроены"
}

# Настройка firewall
setup_firewall() {
    log_info "Настройка UFW firewall..."
    
    # Сброс правил
    ufw --force reset
    
    # Базовые правила
    ufw default deny incoming
    ufw default allow outgoing
    
    # SSH
    ufw allow ssh
    
    # Pharos порты
    ufw allow 8545/tcp  # RPC
    ufw allow 8546/tcp  # WebSocket
    ufw allow 3000/tcp  # Grafana
    
    # Включение firewall
    ufw --force enable
    
    log_success "✅ Firewall настроен"
}

# Создание скрипта управления
create_management_script() {
    log_info "Создание скрипта управления..."
    
    cat > manage.sh << 'EOF'
#!/bin/bash

# 🚀 Скрипт управления Pharos тестнетом
# Автор: Pharos Team

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_usage() {
    echo "🚀 Управление Pharos тестнетом"
    echo ""
    echo "Использование: $0 [команда]"
    echo ""
    echo "Команды:"
    echo "  start     - Запуск сервисов"
    echo "  stop      - Остановка сервисов"
    echo "  restart   - Перезапуск сервисов"
    echo "  status    - Статус сервисов"
    echo "  logs      - Просмотр логов"
    echo "  test      - Запуск тестов"
    echo "  help      - Показать эту справку"
    echo ""
}

case "${1:-help}" in
    start)
        log_info "Запуск Pharos тестнета..."
        systemctl start pharos-docker
        log_success "✅ Сервисы запущены"
        ;;
    stop)
        log_info "Остановка Pharos тестнета..."
        systemctl stop pharos-docker
        log_success "✅ Сервисы остановлены"
        ;;
    restart)
        log_info "Перезапуск Pharos тестнета..."
        systemctl restart pharos-docker
        log_success "✅ Сервисы перезапущены"
        ;;
    status)
        log_info "Статус Pharos тестнета..."
        systemctl status pharos-docker --no-pager -l
        echo ""
        log_info "Статус Docker контейнеров:"
        docker ps --filter "name=pharos-*"
        ;;
    logs)
        log_info "Логи Pharos тестнета..."
        journalctl -u pharos-docker -f
        ;;
    test)
        log_info "Запуск тестов..."
        cd /opt/pharos-testnet
        source venv/bin/activate
        python -m pytest tests/ -v
        ;;
    help|*)
        show_usage
        ;;
esac
EOF
    
    chmod +x manage.sh
    
    # Создание символической ссылки
    ln -sf /opt/pharos-testnet/manage.sh /usr/local/bin/pharos-manage
    
    log_success "✅ Скрипт управления создан"
}

# Основная функция
main() {
    log_info "🚀 Начинаем развертывание Pharos тестнета на VPS Ubuntu"
    
    check_root
    check_system
    update_system
    install_dependencies
    create_user
    create_project
    setup_systemd
    setup_firewall
    create_management_script
    
    log_success "🎉 Развертывание Pharos тестнета завершено!"
    echo ""
    echo "📋 Что установлено:"
    echo "  ✅ Python 3.13+ с виртуальным окружением"
    echo "  ✅ Node.js для Ganache"
    echo "  ✅ Docker и Docker Compose"
    echo "  ✅ UFW firewall с правилами"
    echo "  ✅ Systemd сервисы"
    echo "  ✅ Пользователь pharos"
    echo "  ✅ Ganache (Ethereum клиент)"
    echo "  ✅ Grafana (мониторинг)"
    echo ""
    echo "🚀 Доступные команды:"
    echo "  pharos-manage start    - Запуск сервисов"
    echo "  pharos-manage stop     - Остановка сервисов"
    echo "  pharos-manage status   - Статус сервисов"
    echo "  pharos-manage logs     - Просмотр логов"
    echo ""
    echo "🌐 Доступные интерфейсы:"
    echo "  RPC API:     http://YOUR_VPS_IP:8545"
    echo "  WebSocket:   ws://YOUR_VPS_IP:8546"
    echo "  Grafana:     http://YOUR_VPS_IP:3000 (admin/admin)"
    echo ""
    echo "🔒 Безопасность:"
    echo "  Firewall настроен для портов 22, 8545, 8546, 3000"
    echo "  Сервисы запускаются под пользователем pharos"
    echo ""
    log_success "✅ Готово к использованию!"
}

# Запуск
main "$@"
