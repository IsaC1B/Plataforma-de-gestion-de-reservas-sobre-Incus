# Guía de Uso - Plataforma Distribuida sobre AWS

## Descripción

Esta guía describe el acceso y la operación básica de la infraestructura distribuida desplegada sobre AWS utilizando:

- Incus
- OVN
- OpenTofu
- Ansible
- Prometheus
- Grafana
- Ceph
- PostgreSQL

La plataforma se encuentra desplegada sobre una instancia EC2 y expone distintos servicios internos mediante puertos específicos.

## Acceso al Servidor AWS

La administración principal de la infraestructura se realiza mediante SSH hacia la instancia EC2.

### Conexión SSH

```bash
ssh -i ./sdkey.pem ubuntu@3.18.239.206
```

### Parámetros

| Parámetro | Descripción |
|---|---|
| `sdkey.pem` | Llave privada SSH |
| `ubuntu` | Usuario del sistema |
| `3.18.239.206` | IP pública de la instancia AWS |



## Servicios Disponibles

### Dashboard de Monitoreo - Grafana

Grafana permite visualizar métricas y dashboards del sistema distribuido.

#### Acceso

http://3.18.239.206:3000

#### Puerto utilizado

| Servicio | Puerto |
|---|---|
| Grafana | `3000` |

#### Credenciales

- Usuario: `admin`
- Contraseña: `Sisdis2026`

### Prometheus

Prometheus se encarga de la recolección de métricas del entorno distribuido.

#### Acceso

http://3.18.239.206:9090

#### Puerto utilizado

| Servicio | Puerto |
|---|---|
| Prometheus | `9090` |
