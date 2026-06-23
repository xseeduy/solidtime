# infra/adhoc/

Operaciones **one-time** o que no se trackean en el backend de Terraform.

## Propósito

Este directorio contiene scripts, configuraciones y documentación para tareas que se ejecutan una sola vez o que quedan fuera del ciclo de vida de Terraform:

- **Registros DNS** que deben crearse en Route53 o delegarse desde el proveedor UY
- **Validación de certificados ACM**
- **Configuración inicial de Secrets Manager** (seed de secretos)
- **Comandos CLI de SolidTime** (generación de keys, OAuth clients, admin user)
- **Tareas de migración** o bootstrap manual

## Estructura

```
adhoc/
├── README.md           # Este archivo
├── dns/                # Registros DNS y delegación
│   ├── README.md       # Documentación de registros
│   └── create-records.sh
├── solidtime-setup/    # Setup inicial de la app SolidTime
│   ├── README.md
│   └── ...
└── ...
```

## Buenas prácticas

- Cada subdirectorio debe tener un `README.md` explicando qué hace y cómo ejecutarlo.
- Los scripts deben ser **idempotentes** en lo posible.
- Si una operación se repite, debe migrarse a un módulo de Terraform.
- No almacenar secretos en estos scripts — usar referencias a Secrets Manager.
