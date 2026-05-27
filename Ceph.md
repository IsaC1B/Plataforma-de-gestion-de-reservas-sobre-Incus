# Ceph Lab – Arquitectura híbrida (MON/MGR en contenedor + OSD en host)

## 1. Descripción general del problema

Durante la implementación del clúster Ceph en entorno Incus sobre Amazon Web Services, se intentó inicialmente ejecutar toda la pila Ceph dentro del contenedor ceph-node.

Sin embargo, este enfoque presentó múltiples fallos críticos:

- El OSD no podía mantenerse estable dentro del contenedor
- Errores constantes con device-mapper (dmsetup)
- Problemas de acceso a dispositivos de bloque (/dev/nvme1n1)
- Fallos de permisos sobre dispositivos físicos
- Inestabilidad del almacenamiento persistente en contenedores
- Problemas de inicialización de LVM para Ceph (ceph-volume lvm create)
- Errores de conectividad interna del OSD con BlueStore

Ejemplo de error crítico:

Failure to communicate with kernel device-mapper driver
Incompatible libdevmapper and kernel driver

## 2. Causa raíz del problema

El problema principal fue arquitectónico.

### Intento inicial incorrecto

Ejecutar TODO Ceph dentro del contenedor:

- MON
- MGR
- OSD
- LVM / BlueStore

### Problemas detectados

- Los contenedores Incus no manejan bien acceso directo a block devices
- Device-mapper no funciona correctamente en este entorno aislado
- OSD requiere control directo del kernel
- BlueStore necesita acceso real al dispositivo físico
- OVN aislaba redes entre host y contenedor

## 3. Decisión de arquitectura (solución final)

Se adoptó una arquitectura híbrida separando responsabilidades.

| Componente | Ubicación |
|---|---|
| MON | Contenedor ceph-node |
| MGR | Contenedor ceph-node |
| OSD | HOST (AWS instance) |
| Disco físico | AWS EBS 10GB |
| Red | OVN + puente host |

## 4. Motivo de la separación

### Estabilidad del kernel

El OSD requiere:

- acceso directo a block devices
- soporte completo de device-mapper
- control de LVM y BlueStore

Esto NO es confiable dentro de contenedores Incus en modo OVN.

### Persistencia real del almacenamiento

Se creó un volumen de 10GB en AWS EBS para:

- Garantizar persistencia del OSD
- Evitar corrupción de datos en contenedor
- Permitir recreación del contenedor sin perder storage

### Compatibilidad Ceph

Ceph recomienda que OSD tenga:

- acceso directo al hardware
- sin abstracción de filesystem del contenedor

## 5. Implementación del OSD en el HOST

Se ejecutó directamente en el host:

- wipefs -a /dev/nvme1n1
- sgdisk --zap-all /dev/nvme1n1
- dd if=/dev/zero of=/dev/nvme1n1 bs=1M count=100

Creación del OSD:

- ceph-volume lvm create --data /dev/nvme1n1

Resultado:

- OSD creado correctamente
- BlueStore activo
- OSD registrado como osd.0
- Estado: up/in

## 6. Conectividad MON/MGR ↔ OSD

El contenedor ceph-node mantiene:

- MON daemon
- MGR daemon
- configuración del cluster

El host mantiene:

- OSD daemon

La comunicación se realiza por red interna OVN + red AWS.

Validación:

- 
c -zv 172.31.16.184 6800
- 
c -zv 172.31.16.184 6801
- 
c -zv 172.31.16.184 6802
- 
c -zv 172.31.16.184 6803
-
Puertos OSD accesibles desde el contenedor.

## 7. Estado final del clúster

- HEALTH_OK / HEALTH_WARN (sin replicación configurada)
- mon: 1 (ceph-node container)
- mgr: 1 (ceph-node container)
- osd: 1 (host AWS)

## 8. Problema resuelto (clave del laboratorio)

### Antes

- OSD dentro de contenedor
- LVM fallando
- device-mapper no funcional
- acceso bloqueado a /dev/nvme*

### Ahora

- OSD en host con acceso kernel directo
- MON/MGR aislados en contenedor
- red OVN conectando ambos
- almacenamiento persistente en EBS

## 9. Integración con proyecto

Ceph se usa como backend de persistencia para:

- Backups de PostgreSQL
- almacenamiento de snapshots
- repositorio de objetos del laboratorio

Pool utilizado:

- 
eservas-pool

## 10. Conclusión

La arquitectura híbrida fue necesaria porque:

- Los OSD requieren acceso directo al hardware y al kernel, lo cual no es confiable dentro de contenedores Incus con red OVN.

Separar responsabilidades permitió:

- estabilidad del clúster
- persistencia real del almacenamiento
- compatibilidad con AWS EBS
- comunicación funcional entre MON/MGR y OSD
- integración con servicios del proyecto
