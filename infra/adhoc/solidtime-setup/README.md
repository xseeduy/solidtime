# Setup Inicial de SolidTime

Comandos one-time para configurar la instancia de SolidTime post-deploy.

## Pre-requisitos

- App desplegada en ECS Fargate
- Base de datos migrada (AUTO_DB_MIGRATE=true o `php artisan migrate --force`)
- Acceso al scheduler task para ejecutar comandos CLI

## 1. Generar Keys

```bash
# Ejecutar en el scheduler task
php artisan self-host:generate-keys
```

## 2. Crear Usuario Admin

```bash
php artisan admin:user:create "Nombre" "email@domain.com" --verify-email
```

## 3. Crear OAuth Clients

```bash
# Desktop client
php artisan passport:client --name=desktop \
  --redirect_uri=solidtime://oauth/callback --public -n

# Browser extension
php artisan passport:client --name=browser-extension \
  --redirect_uri=https://3369f72567118d8c03fb34880e9d6378d3b0c569.extensions.allizom.org/,https://hpanifeankiobmgbemnhjmhpjeebdhdd.chromiumapp.org/ \
  --public -n

# Personal API tokens
php artisan passport:client --personal --name="API"
```

## Ejecución en ECS

Para ejecutar comandos en el scheduler task de Fargate:

```bash
aws ecs run-task \
  --cluster xseed-solidtime \
  --task-definition solidtime-scheduler \
  --network-configuration "awsvpcConfiguration={subnets=<private-subnet-ids>,securityGroups=<sg-id>}" \
  --overrides '{ "containerOverrides": [{ "name": "scheduler", "command": ["php", "artisan", "self-host:generate-keys"] }] }' \
  --profile xseed
```

O usar ECS Exec si está habilitado:

```bash
aws ecs execute-command \
  --cluster xseed-solidtime \
  --task <task-id> \
  --container scheduler \
  --command "php artisan self-host:generate-keys" \
  --interactive \
  --profile xseed
```
