# 🚀 Pharos Testnet - Полное решение для развертывания

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.13+](https://img.shields.io/badge/python-3.13+-blue.svg)](https://www.python.org/downloads/)
[![Docker](https://img.shields.io/badge/docker-ready-blue.svg)](https://www.docker.com/)
[![Ubuntu](https://img.shields.io/badge/ubuntu-20.04+-orange.svg)](https://ubuntu.com/)

Полный набор скриптов и документации для развертывания Pharos тестнета как локально, так и на удаленном VPS Ubuntu.

## 🌟 Особенности

- ✅ **Автоматическая установка** - все зависимости устанавливаются автоматически
- ✅ **Локальная разработка** - готовое окружение для разработки
- ✅ **VPS развертывание** - полная автоматизация для Ubuntu
- ✅ **Docker контейнеры** - Ganache, Grafana, мониторинг
- ✅ **Безопасность** - firewall, непривилегированные пользователи
- ✅ **Мониторинг** - Grafana дашборды, метрики
- ✅ **Тестирование** - полный набор тестов
- ✅ **Документация** - подробные инструкции

## 📋 Быстрый старт

### 🖥️ Локальная установка

```bash
# Клонирование репозитория
git clone https://github.com/Sergiogsv/pharos-testnet.git
cd pharos-testnet

# Запуск установки
./pharos-testnet-setup.sh

# Запуск узла
python start_node.py

# Тестирование
./run_tests.sh
```

### ☁️ VPS развертывание

```bash
# На VPS Ubuntu (одна команда)
curl -sSL https://raw.githubusercontent.com/Sergiogsv/pharos-testnet/main/quick-github-deploy.sh | bash -s -- -u Sergiogsv

# Запуск сервисов
sudo /opt/pharos-testnet/manage.sh start

# Проверка статуса
sudo /opt/pharos-testnet/manage.sh status
```

## 📁 Структура проекта

```
pharos-testnet/
├── 🚀 pharos-testnet-setup.sh      # Локальная установка
├── 🚀 pharos-vps-setup.sh          # VPS развертывание
├── 🚀 quick-github-deploy.sh       # Быстрая загрузка с GitHub
├── ⚙️ manage.sh                    # Управление сервисами (VPS)
├── 🐍 start_node.py                # Python узел
├── 🧪 tests/                       # Тесты
├── 🐳 docker-compose.yml           # Docker контейнеры
├── ⚙️ config.yaml                  # Конфигурация
├── 📄 genesis.json                 # Genesis блок
├── 📋 requirements.txt             # Python зависимости
└── 📚 README.md                    # Документация
```

## 🌐 Доступные интерфейсы

| Сервис | Локально | VPS | Описание |
|--------|----------|-----|----------|
| **RPC API** | `http://localhost:8545` | `http://your-vps-ip:8545` | JSON-RPC API |
| **WebSocket** | `ws://localhost:8546` | `ws://your-vps-ip:8546` | WebSocket API |
| **Grafana** | `http://localhost:3000` | `http://your-vps-ip:3000` | Мониторинг (admin/admin) |

## 🔧 Управление

### Локально
```bash
python start_node.py          # Запуск узла
./run_tests.sh               # Запуск тестов
```

### На VPS
```bash
sudo pharos-manage start|stop|restart|status|logs
sudo pharos-setup            # Установка
```

## 🧪 Тестирование

```bash
# Базовые тесты
python -m pytest tests/ -v

# API тесты
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

## 📊 Мониторинг

- **Grafana**: Дашборды для визуализации метрик
- **Системные метрики**: CPU, RAM, диск
- **Сетевые метрики**: Блоки, транзакции, газ
- **Логирование**: journald и файловые логи

## 🔒 Безопасность

- **UFW firewall** с настроенными правилами
- **Непривилегированные пользователи** для сервисов
- **Systemd сервисы** для автозапуска
- **Логирование** всех операций

## 📈 Масштабирование

### Локально
- Увеличьте ресурсы системы
- Настройте swap файл
- Оптимизируйте конфигурацию

### На VPS
- Увеличьте план VPS
- Добавьте больше RAM/CPU
- Настройте мониторинг ресурсов

## 🐛 Устранение неполадок

### Частые проблемы
1. **Порты заняты**: Проверьте `netstat -tlnp`
2. **Docker не запускается**: `sudo systemctl restart docker`
3. **Firewall блокирует**: `sudo ufw status`
4. **Недостаточно места**: `df -h`

### Полезные команды
```bash
# Проверка статуса
sudo /opt/pharos-testnet/manage.sh status

# Просмотр логов
sudo /opt/pharos-testnet/manage.sh logs

# Перезапуск
sudo /opt/pharos-testnet/manage.sh restart
```

## 🔄 Обновление

### Локально
```bash
git pull
./pharos-testnet-setup.sh
```

### На VPS
```bash
sudo /opt/pharos-testnet/manage.sh stop
# Обновите код
sudo /opt/pharos-testnet/manage.sh start
```

## 🤝 Вклад в проект

1. Форкните репозиторий
2. Создайте ветку для новой функции (`git checkout -b feature/amazing-feature`)
3. Зафиксируйте изменения (`git commit -m 'Add amazing feature'`)
4. Отправьте в ветку (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

## 📄 Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE](LICENSE) для деталей.

## 📞 Поддержка

- 📧 **Email**: support@pharos.network
- 💬 **Discord**: https://discord.gg/pharos
- 📖 **Документация**: https://docs.pharos.network
- 🐛 **Issues**: https://github.com/Sergiogsv/pharos-testnet/issues

## ⭐ Звезды

Если этот проект помог вам, поставьте звезду! ⭐

---

**🎉 Спасибо за использование Pharos Testnet!**

Теперь вы можете:
- 🧪 Тестировать смарт-контракты
- 📊 Мониторить производительность
- 🔗 Подключать dApps
- 👥 Приглашать разработчиков
- 🚀 Масштабировать инфраструктуру
