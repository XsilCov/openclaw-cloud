# OpenClaw Cloud Deployment

## Налаштування на Railway

1. Підключи цей репозиторій до Railway
2. Railway автоматично виявить docker-compose.yml
3. Налаштуй змінні середовища (Variables):

### Обов'язкові змінні:
```
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_GATEWAY_BIND=lan
```

### Опціональні (додай в Railway → Variables):
- `OPENCLAW_GATEWAY_TOKEN` - твій gateway token
- `TELEGRAM_BOT_TOKEN` - Telegram bot token
- `GOOGLE_API_KEY` - Google API key

## Після деплою:
1. Railway згенерує домен (наприклад: openclaw.railway.app)
2. Налаштуй Telegram webhook на цей URL
3. Готово! 🤖
