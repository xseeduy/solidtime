# DNS — track.xseed.com.uy

## Estrategia: CNAME desde el proveedor UY

> **Decisión:** El dominio `xseed.com.uy` **no se delega a Route53**. Se gestiona desde el panel del proveedor Uruguayo donde está registrado. Solo indicamos qué registro CNAME crear.

### ¿Por qué esta opción?

- ✅ Riesgo **cero** de romper registros existentes del dominio (correo, etc.)
- ✅ Se configura en **minutos** — sin esperar propagación de NS
- ✅ El proveedor UY solo necesita crear 1 CNAME — algo rutinario para ellos
- ❌ ACM validation será manual o por email (1 vez cada ~13 meses)
- ❌ No podemos automatizar DNS con Terraform

---

## Paso a Paso Humano

### FASE 1: Obtener el DNS name del ALB

> Esto se hace **después** del deploy de Terraform, no antes.

1. Ir a AWS Console → EC2 → Load Balancers
2. Seleccionar el ALB creado (ej: `xseed-solidtime-alb`)
3. Copiar el **DNS name**. Se ve así:
   ```
   xseed-solidtime-alb-123456789.us-east-1.elb.amazonaws.com
   ```
4. Guardar ese valor — lo necesitamos para el CNAME.

**Alternativa desde CLI:**
```bash
aws elbv2 describe-load-balancers \
  --names xseed-solidtime-alb \
  --query 'LoadBalancers[0].DNSName' \
  --output text \
  --profile xseed
```

---

### FASE 2: Crear el CNAME en el proveedor UY

Ir al panel de administración de DNS del proveedor donde está registrado `xseed.com.uy` y crear **1 registro** de tipo CNAME:

| Tipo | Nombre | TTL | Valor (destino) |
|:----:|--------|:---:|-----------------|
| **CNAME** | `track` | 300 (5 min) | `<ALB-DNS-NAME>` |

**Detalles importantes para llenar el formulario del proveedor UY:**

- **Nombre:** Solo `track` (no `track.xseed.com.uy` completo). El proveedor ya sabe que el dominio es `xseed.com.uy`.
- **Tipo:** CNAME (no A, no ALIAS)
- **TTL:** 300 segundos (5 minutos) — el mínimo recomendado. Si no acepta TTL bajo, poner 3600 (1 hora).
- **Valor/Destino:** Pegar el DNS name completo del ALB, **sin** `http://` ni `/` al final.
- **NO** borrar ningún registro existente. Solo agregar este nuevo.

**Ejemplo concreto (cuando tengamos el ALB):**

```
track     CNAME    300    xseed-solidtime-alb-123456789.us-east-1.elb.amazonaws.com.
```

---

### FASE 3: Validar SSL (ACM)

Necesitamos un certificado SSL para `track.xseed.com.uy` en AWS. ACM ofrece 2 métodos de validación:

#### Opción 3a: Validación por EMAIL (recomendada)

ACM envía un email de verificación a las siguientes direcciones para `xseed.com.uy`:

```
admin@xseed.com.uy
administrator@xseed.com.uy
hostmaster@xseed.com.uy
postmaster@xseed.com.uy
webmaster@xseed.com.uy
```

**Paso a paso:**
1. En AWS Console → ACM → Solicitar certificado
2. Dominio: `track.xseed.com.uy`
3. Método de validación: **Email**
4. AWS envía un email a las direcciones de arriba
5. Alguien con acceso al correo de `@xseed.com.uy` hace clic en el enlace de aprobación
6. Listo. El certificado se emite y auto-renueva cada 13 meses (el email se reenvía automáticamente)

> **Ventaja:** No requiere crear ningún registro DNS. **Desventaja:** Depende de que alguien revise y apruebe el email.

#### Opción 3b: Validación por DNS (manual)

Si se prefiere validación DNS, ACM genera un CNAME de validación. Ese CNAME también debe crearse en el panel del proveedor UY.

**Paso a paso:**
1. En AWS Console → ACM → Solicitar certificado
2. Dominio: `track.xseed.com.uy`
3. Método de validación: **DNS**
4. ACM muestra un CNAME como:
   ```
   _X1234.track.xseed.com.uy.  →  _Y5678.acm-validations.aws.
   ```
5. Ir al proveedor UY y crear un registro CNAME:
   | Tipo | Nombre | Valor |
   |:----:|--------|-------|
   | CNAME | `_X1234.track` | `_Y5678.acm-validations.aws.` |
6. Esperar 1-2 minutos. ACM valida automáticamente.

> **Ventaja:** No depende de correo. **Desventaja:** Hay que crear un registro DNS adicional cada ~13 meses al renovar.

---

### FASE 4: Verificar

Una vez creado el CNAME y emitido el certificado:

```bash
# Resolver el subdominio
dig track.xseed.com.uy +short
# Debería devolver: xseed-solidtime-alb-123456789.us-east-1.elb.amazonaws.com

# Verificar el certificado SSL
curl -I https://track.xseed.com.uy
# Debería responder con 200 OK y SSL válido
```

---

## Resumen Visual

```
┌─────────────────────────────────────────────────────┐
│            ¿QUÉ HAY QUE HACER? (checklist)          │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ☐ 1. Desplegar ALB con Terraform                   │
│  ☐ 2. Copiar ALB DNS name                           │
│  ☐ 3. Crear CNAME en proveedor UY:                  │
│        track  CNAME → <ALB-DNS>                     │
│  ☐ 4. Opción A (email): Aprobar email de ACM        │
│     Opción B (dns): Crear CNAME de validación       │
│  ☐ 5. Verificar con dig + curl                      │
│                                                      │
└─────────────────────────────────────────────────────┘

Tiempo estimado total: 10-15 minutos
```
