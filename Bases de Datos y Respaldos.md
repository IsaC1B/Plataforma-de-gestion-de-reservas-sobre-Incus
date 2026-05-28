# README: Gestión de Base de Datos PostgreSQL - Sistema de Reservas

## Descripción General

Este documento describe cómo conectarse, operar y realizar respaldos de la base de datos PostgreSQL del sistema de reservas alojada en el contenedor `db-postgres` de Incus.

### Verificar Estado de Conexión con Ceph

Antes de realizar cualquier operación, verifica que la conexión con Ceph esté activa:

```bash
sudo /usr/local/bin/ceph-lab-restore.sh && sleep 10 && sudo /usr/local/bin/ceph-check.sh
```

Este comando:
1. Ejecuta el script de restauración de laboratorio Ceph
2. Espera 10 segundos para estabilizar conexiones
3. Verifica el estado de la conexión con Ceph

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




### 5.8 Respaldo mejorado con Ceph

Para crear respaldos automáticos con timestamp y almacenarlos en el pool de Ceph:

```bash
incus exec db-postgres -- bash -c "
FECHA=\$(date +%Y%m%d_%H%M%S)
PGPASSWORD=Sisdis2026 pg_dump -U sisdisreservas -h 10.10.0.5 -d reservasdb -f /tmp/reservasdb_\${FECHA}.sql
rados -p reservas-pool put backup/reservasdb_\${FECHA}.sql /tmp/reservasdb_\${FECHA}.sql
echo 'Backup guardado:'
rados -p reservas-pool ls | grep backup
rm -f /tmp/reservasdb_\${FECHA}.sql
"
```

**Nota:** Este comando utiliza:
- `PGPASSWORD`: Contraseña del usuario sisdisreservas
- `pg_dump`: Exporta la base de datos
- `rados`: Envía el respaldo al pool de Ceph `reservas-pool`
- Limpia archivos temporales después de transferir

### 5.9 Borrar/Limpiar Base de Datos

**ADVERTENCIA:** Este comando elimina todas las tablas. Realiza un respaldo primero.

```bash
incus exec db-postgres -- bash -c "
PGPASSWORD=Sisdis2026 psql -U sisdisreservas -h 10.10.0.5 -d reservasdb << 'SQL'
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS reservations CASCADE;
DROP TABLE IF EXISTS resources CASCADE;
DROP TABLE IF EXISTS users CASCADE;
SELECT table_name FROM information_schema.tables WHERE table_schema='public';
SQL
"
```

---

## 6. Monitoreo y Mantenimiento

### 6.1 Ver tamaño de la base de datos

```bash
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c \"SELECT pg_size_pretty(pg_database_size('reservasdb'));\""
```

### 6.2 Verificar conexiones activas

```bash
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c 'SELECT * FROM pg_stat_activity;'"
```

### 6.3 Vacío y análisis de la base de datos

```bash
incus exec db-postgres -- su - postgres -c "psql -d reservasdb -c 'VACUUM ANALYZE;'"
```

---

## 7. Mejores Prácticas

- Realizar respaldos regularmente
- Probar restauraciones de respaldos periódicamente
- Monitorear el tamaño de la base de datos
- Limpiar respaldos antiguos para ahorrar espacio
- Mantener logs de eventos para auditoría
- No eliminar datos sin antes hacer un respaldo
- No cambiar contraseñas sin documentar los cambios

---

## 8. Solución de Problemas

### Conexión rechazada

```bash
# Verificar si el contenedor está corriendo
incus list | grep db-postgres

# Reiniciar el contenedor si es necesario
incus restart db-postgres
```

### Respaldo muy lento


- Verifica el espacio disponible en disco


## 9. Persistencia con Ceph

La base de datos PostgreSQL utiliza **Ceph** para almacenar respaldos de forma distribuida y redundante. Esto proporciona persistencia a largo plazo y recuperación ante desastres.

### 9.1 Entendimiento de la Arquitectura

- **Pool de Ceph:** `reservas-pool` - Pool dedicado para respaldos de la base de datos
- **Usuario PostgreSQL:** `sisdisreservas`
- **Host PostgreSQL:** `10.10.0.5`
- **Base de datos:** `reservasdb`

### 9.2 Listar Backups en Ceph

Ver todos los backups disponibles en el pool de Ceph:

```bash
incus exec db-postgres -- rados -p reservas-pool ls | grep backup
```

---

### 9.3 Crear Respaldo en Ceph

Crear un nuevo respaldo con timestamp:

```bash
incus exec db-postgres -- bash -c "
FECHA=\$(date +%Y%m%d_%H%M%S)
PGPASSWORD=Sisdis2026 pg_dump -U sisdisreservas -h 10.10.0.5 -d reservasdb -f /tmp/reservasdb_\${FECHA}.sql
rados -p reservas-pool put backup/reservasdb_\${FECHA}.sql /tmp/reservasdb_\${FECHA}.sql
echo 'Backup guardado:'
rados -p reservas-pool ls | grep backup
rm -f /tmp/reservasdb_\${FECHA}.sql
"
```

### 9.4 Restaurar desde Ceph

Proceso automatizado para restaurar el backup más reciente desde Ceph:

```bash
incus exec db-postgres -- bash -c "
# Ver backups disponibles
echo 'Backups en Ceph:'
rados -p reservas-pool ls | grep backup
echo '---'
# Tomar el más reciente
BACKUP=\$(rados -p reservas-pool ls | grep backup | sort | tail -1)
echo 'Restaurando: '\$BACKUP
rados -p reservas-pool get \$BACKUP /tmp/restore.sql
PGPASSWORD=Sisdis2026 psql -U sisdisreservas -h 10.10.0.5 -d reservasdb -f /tmp/restore.sql
echo 'Restauración completada'
rm -f /tmp/restore.sql
"
```

### 9.5 Restaurar desde un Backup Específico

Si necesitas restaurar desde un backup específico :

```bash
incus exec db-postgres -- bash -c "
# Listar y seleccionar
rados -p reservas-pool ls | grep backup
# Reemplazar 'BACKUP_NAME' con el nombre deseado
rados -p reservas-pool get backup/reservasdb_YYYYMMDD_HHMMSS.sql /tmp/restore.sql
PGPASSWORD=Sisdis2026 psql -U sisdisreservas -h 10.10.0.5 -d reservasdb -f /tmp/restore.sql
rm -f /tmp/restore.sql
"
```

### 9.6 Gestión de Espacio en Ceph

**Ver tamaño de los backups:**

```bash
rados -p reservas-pool ls | grep backup | xargs -I {} rados -p reservas-pool stat {}
```

**Eliminar backups antiguos (ejemplo: mantener últimos 5):**

```bash
rados -p reservas-pool ls | grep backup | sort | head -n -5 | xargs -I {} rados -p reservas-pool rm {}
```

### 9.7 Ventajas de Usar Ceph

-  **Redundancia:** Los datos se replican automáticamente
-  **Escalabilidad:** Crece conforme aumentan los backups
-  **Confiabilidad:** Recuperación ante fallos de discos
-  **Acceso distribuido:** Backups accesibles desde cualquier nodo
-  **Compresión:** Ahorro de espacio automático

### 9.8 Monitoreo de Health Ceph

Desde el cluster Ceph, verificar estado:

```bash
ceph status
ceph osd status
ceph pg stat
```

---

**Última actualización:** 28 de mayo de 2026
