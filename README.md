# LanConnector

> **Твоя локальная сеть — где угодно.**

LanConnector — кроссплатформенный L2/L3 overlay VPN для объединения удалённых
компьютеров в одну «локальную сеть» поверх интернета. Прямой P2P-туннель, когда
это возможно, автоматический fallback на relay, шифрование WireGuard/Noise,
режим L2 для LAN-игр и broadcast/multicast-обнаружения.

| Компонент | Бинарник / артефакт | Назначение |
|---|---|---|
| LanConnector Client | `lanconnector` (GUI, Tauri) | Пользовательский интерфейс, трей, настройки |
| LanConnector Daemon | `lanconnd` | Фоновый сервис: туннели, крипто, NAT traversal |
| LanConnector CLI | `lanconn` | Управление из терминала |
| LanConnector Hub | `lanhub` | Signaling, реестр узлов, выдача ключей, NAT-координация |
| LanConnector Relay | `lanrelay` | Ретрансляция зашифрованного трафика (TURN-подобная) |
| LanConnector Console | `console` (web) | Администрирование: комнаты, ACL, статистика |

Виртуальная сеть в продукте называется **комната (Room)**.

## Документация

| Документ | Содержание |
|---|---|
| [docs/architecture.md](docs/architecture.md) | Архитектура, топология, диаграммы, потоки данных |
| [docs/protocol.md](docs/protocol.md) | Спецификация протокола: кадры, handshake, keepalive, rekey, invite |
| [docs/roadmap.md](docs/roadmap.md) | MVP → v1 → Production, критерии готовности |
| [docs/testing.md](docs/testing.md) | Unit / integration / NAT-эмуляция / fuzzing / нагрузка |
| [docs/risks.md](docs/risks.md) | Риски и способы их снятия |
| [docs/threat-model.md](docs/threat-model.md) | Модель угроз и границы доверия |
| [docs/licensing.md](docs/licensing.md) | Лицензионная модель и монетизация |
| [docs/branding.md](docs/branding.md) | Нейминг, env-переменные, метрики, URI-схема |
| [docs/adr/](docs/adr/) | Architecture Decision Records |

## Структура репозитория

```
lanconnector/
├── core/          # Rust: крипто-ядро, framing, path selection, MTU, NAT-логика
├── daemon/        # Rust: lanconnd (TUN/TAP, транспорт, IPC-сервер)
├── cli/           # Rust: lanconn (clap, gRPC-клиент к демону)
├── gui/           # Tauri v2 + React/TypeScript
├── client/        # Установщики, службы, URI-схема, автозапуск, обновления
├── hub/           # Go: signaling, registry, invites, ACL, метрики
├── relay/         # Go: UDP-релей с end-to-end шифрованием
├── console/       # React/TypeScript: админ-панель
├── proto/         # Protobuf-контракты (buf)
├── deploy/        # docker-compose, systemd, Prometheus-алерты
├── scripts/       # dev-скрипты
└── docs/          # архитектура, протокол, ADR
```

## Быстрый старт (dev)

```bash
# 1. Поднять Hub + Relay + Redis локально
docker compose up -d

# 2. Собрать клиентские бинарники
cargo build --workspace --release

# 3. Запустить демон (Linux: нужен CAP_NET_ADMIN)
sudo -E LANCONN_HUB_URL=http://127.0.0.1:8080 ./target/release/lanconnd

# 4. Создать комнату и пригласить второго участника
lanconn room create --name "home"
lanconn invite --room home          # lanconnector://join/<token>
lanconn status --watch
```

## Принципы

1. **Из коробки.** Один установщик, один клик «Создать комнату», ссылка-приглашение.
2. **P2P по умолчанию.** Relay — только fallback, а не режим работы.
3. **Крипто — не наша самоделка.** Noise IK / WireGuard-конструкции, libsodium-примитивы.
4. **Наблюдаемость.** Каждый компонент отдаёт `lanconnector_*` метрики и OTel-трейсы.
5. **Простота важнее гибкости.** Конфигурация по умолчанию должна работать.

## Лицензия

Apache-2.0 для ядра, клиента, демона, CLI, Hub и Relay (self-hosted).
Console и enterprise-функции — коммерческая лицензия. Подробнее:
[docs/licensing.md](docs/licensing.md).
