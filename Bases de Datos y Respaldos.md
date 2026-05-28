# README: Gestión de Base de Datos PostgreSQL - Sistema de Reservas

## Descripción General

Este documento describe cómo conectarse, operar y realizar respaldos de la base de datos PostgreSQL del sistema de reservas alojada en el contenedor `db-postgres` de Incus.

---

## 1. Conexión a la Base de Datos

### Acceder a la consola PostgreSQL

Para acceder a la base de datos PostgreSQL desde el contenedor Incus:

```bash
incus exec db-postgres -- su - postgres -c "psql -d reservasdb"
```

---

## 2. Listar Tablas

Para ver todas las tablas disponibles en la base de datos:

```bash
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c '\dt'"
```

**Salida esperada:** Lista de todas las tablas con sus esquemas y propietarios.

---

## 3. Visualizar Datos de las Tablas

### Tabla: users (Usuarios)

```bash
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c 'SELECT * FROM users;'"
```

### Tabla: resources (Recursos)

```bash
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c 'SELECT * FROM resources;'"
```

### Tabla: reservations (Reservaciones)

```bash
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c 'SELECT * FROM reservations;'"
```

### Tabla: event_logs (Registro de Eventos)

```bash
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c 'SELECT * FROM event_logs;'"
```

---

## 4. Operaciones Comunes en la Base de Datos

### 4.1 Contar registros por tabla

```bash
# Contar usuarios
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c 'SELECT COUNT(*) FROM users;'"

# Contar recursos
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c 'SELECT COUNT(*) FROM resources;'"

# Contar reservaciones
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c 'SELECT COUNT(*) FROM reservations;'"
```

### 4.2 Buscar registros específicos

```bash
# Búsqueda por usuario
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c 'SELECT * FROM users WHERE id = 1;'"

# Búsqueda por recurso
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c 'SELECT * FROM resources WHERE id = 1;'"
```

### 4.3 Ver estructura de una tabla

```bash
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c '\d+ users'"
```

---

## 5. Respaldos de Base de Datos

### 5.1 Crear un respaldo completo

Para crear un respaldo (dump) de toda la base de datos en formato SQL:

```bash
incus exec db-postgres -- su - postgres -c "pg_dump -d reservasdb > /var/lib/postgresql/respaldo_$(date +%Y%m%d_%H%M%S).sql"
```

### 5.2 Crear respaldo en formato binario (más eficiente)

```bash
incus exec db-postgres -- su - postgres -c "pg_dump -Fc -d reservasdb > /var/lib/postgresql/respaldo_$(date +%Y%m%d_%H%M%S).dump"
```

### 5.3 Listar respaldos existentes

```bash
incus exec db-postgres -- ls -lh /var/lib/postgresql/respaldo_*
```

### 5.4 Restaurar desde un respaldo SQL

```bash
incus exec db-postgres -- su - postgres -c "psql -d reservasdb < /var/lib/postgresql/respaldo_YYYYMMDD_HHMMSS.sql"
```

### 5.5 Restaurar desde un respaldo binario

```bash
incus exec db-postgres -- su - postgres -c "pg_restore -d reservasdb /var/lib/postgresql/respaldo_YYYYMMDD_HHMMSS.dump"
```

### 5.6 Descargar respaldo a máquina local

```bash
incus file pull db-postgres/var/lib/postgresql/respaldo_YYYYMMDD_HHMMSS.sql ./respaldo_local.sql
```

### 5.7 Automatizar respaldos diarios (Opción: Crear script)

Crear archivo `/home/user/backup_db.sh`:

```bash
#!/bin/bash
BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
incus exec db-postgres -- su - postgres -c "pg_dump -Fc -d reservasdb > /var/lib/postgresql/respaldo_${TIMESTAMP}.dump"
echo "Respaldo creado: respaldo_${TIMESTAMP}.dump"
```

Luego agregar al crontab:

```bash
0 2 * * * /home/user/backup_db.sh
```

---

## 6. Monitoreo y Mantenimiento

### 6.1 Ver tamaño de la base de datos

```bash
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c 'SELECT pg_size_pretty(pg_database_size(''reservasdb''));'"
```

### 6.2 Verificar conexiones activas

```bash
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c 'SELECT * FROM pg_stat_activity;'"
```

### 6.3 Vacío y análisis de la base de datos

```bash
incus exec db-postgres -- su - postgres -c "VACUUM ANALYZE;"
```

---

## 7. Mejores Prácticas

- ✅ Realizar respaldos regularmente (diariamente recomendado)
- ✅ Probar restauraciones de respaldos periódicamente
- ✅ Monitorear el tamaño de la base de datos
- ✅ Limpiar respaldos antiguos para ahorrar espacio
- ✅ Mantener logs de eventos para auditoría
- ❌ No eliminar datos sin antes hacer un respaldo
- ❌ No cambiar contraseñas sin documentar los cambios

---

## 8. Troubleshooting

### Conexión rechazada

```bash
# Verificar si el contenedor está corriendo
incus list | grep db-postgres

# Reiniciar el contenedor si es necesario
incus restart db-postgres
```

### Respaldo muy lento

- Considera usar formato binario (`-Fc`) en lugar de SQL
- Verifica el espacio disponible en disco

### No se puede restaurar

- Asegúrate que el archivo existe: `incus exec db-postgres -- ls -la /var/lib/postgresql/`
- Verifica permisos del usuario postgres
- Intenta con `--clean` para limpiar datos anteriores

---

**Última actualización:** 28 de mayo de 2026
