# Arquitectura de Infraestructura Distribuida sobre AWS

## Descripción General

Este proyecto implementa una infraestructura distribuida desplegada sobre una instancia EC2 en AWS utilizando tecnologías de virtualización ligera, automatización e infraestructura como código.

La plataforma está compuesta por:

- **Incus** como gestor de contenedores
- **OVN (Open Virtual Network)** para redes virtuales
- **Open vSwitch (OVS)** como plano de switching
- **OpenTofu** para aprovisionamiento IaC
- **Ansible** para automatización y configuración
- **Ceph** para almacenamiento distribuido
- **Prometheus y Grafana** para monitoreo y observabilidad

La arquitectura utiliza contenedores Linux distribuidos sobre una red OVN interna con NAT hacia una red bridge de salida.

---

## 1. Plataforma y Entorno

| Componente | Valor |
|---|---|
| Plataforma | AWS EC2 |
| Sistema Operativo | Ubuntu Server |
| Interfaz física | `enp39s0` |
| Virtualización | Incus |
| Overlay Network | OVN |
| Switching | Open vSwitch |

---

## 2. Arquitectura de Red

### 2.1 Redes Configuradas

#### Red Bridge Principal

| Parámetro | Valor |
|---|---|
| Nombre | `incusbr0` |
| Tipo | Bridge |
| Gateway | `10.200.200.1/24` |
| NAT | Habilitado |
| Función | Uplink y salida a internet |

#### Red OVN Interna

| Parámetro | Valor |
|---|---|
| Nombre | `ovn-net` |
| Tipo | OVN |
| Subred | `10.10.0.0/24` |
| Gateway | `10.10.0.1` |
| NAT externo | `10.200.200.100` |
| Uplink | `incusbr0` |

### 2.2 Arquitectura Lógica de Red

```
                            INTERNET
                                |
                                |
                        AWS EC2 HOST
                     172.31.x.x (AWS)
                                |
                        +----------------+
                        |    incusbr0    |
                        | 10.200.200.1   |
                        +----------------+
                                |
                OVN Logical Router / NAT
                     External IP:
                     10.200.200.100
                                |
                        +----------------+
                        |    ovn-net     |
                        | 10.10.0.0/24   |
                        +----------------+
           _____________|_______|______________
          |             |       |              |
      app-api       app-core   db-postgres   monitoring
      10.10.0.3     10.10.0.4  10.10.0.5    10.10.0.6
                                                |
                                            Grafana
                                            Prometheus

          ceph-node
          10.10.0.7

          node-control
          10.10.0.2

          frontend
          10.200.200.12
          (bridge directo sobre incusbr0)
```

---

## 3. Contenedores y Direccionamiento IP

| Contenedor | Dirección IP | Función |
|---|---|---|
| `node-control` | `10.10.0.2` | Nodo de control y automatización |
| `app-api` | `10.10.0.3` | Backend API |
| `app-core` | `10.10.0.4` | Servicios centrales de aplicación |
| `db-postgres` | `10.10.0.5` | Base de datos PostgreSQL |
| `monitoring` | `10.10.0.6` | Monitoreo y observabilidad |
| `ceph-node` | `10.10.0.7` | Nodo Ceph MON/MGR |
| `frontend` | `10.200.200.12` | Frontend Web |

---

## 4. Observabilidad

### 4.1 Grafana

| Parámetro | Valor |
|---|---|
| Servicio | Grafana |
| Contenedor | `monitoring` |
| Puerto | `3000/TCP` |
| Función | Visualización y dashboards |

### 4.2 Prometheus

| Parámetro | Valor |
|---|---|
| Servicio | Prometheus |
| Contenedor | `monitoring` |
| Puerto | `9090/TCP` |
| Función | Recolección de métricas |

### 4.3 Puertos Principales Utilizados

| Servicio | Puerto | Protocolo | Descripción |
|---|---|---|---|
| Grafana | `3000` | TCP | Dashboards |
| Prometheus | `9090` | TCP | Métricas |
| PostgreSQL | `5432` | TCP | Base de datos |
| WebUI | `8443` | TCP | INterfaz de Usuario |
| SSH | `22` | TCP | Administración remota |

---

## 5. Arquitectura Ceph

Actualmente la infraestructura Ceph se encuentra distribuida de la siguiente manera:

| Nodo | Rol |
|---|---|
| Host AWS | OSD |
| `ceph-node` | MON y MGR |

> Nota: La configuración detallada de Ceph, almacenamiento distribuido y replicación se documentará en un README independiente.

---

## 6. Automatización e Infraestructura como Código

### 6.1 OpenTofu

OpenTofu se utiliza para:

- Aprovisionamiento de infraestructura
- Gestión declarativa de recursos
- Automatización del despliegue

### 6.2 Ansible

Ansible se utiliza para:

- Configuración automática de contenedores
- Instalación de servicios
- Orquestación de componentes
- Gestión de configuración distribuida

### 6.3 Open Virtual Network (OVN)

La red virtual está implementada mediante OVN sobre Open vSwitch.

---

## 7. Componentes Principales

| Componente | Función |
|---|---|
| OVN Northbound DB | Configuración lógica |
| OVN Southbound DB | Estado distribuido |
| Open vSwitch | Switching virtual |
| Logical Router | Enrutamiento interno |
| Logical Switch | Segmentación virtual |

---

## 8. Flujo General de Comunicación

```text
Frontend
    |
    v
app-api
    |
    v
app-core
    |
    v
 db-postgres

Prometheus
    |
    v
Exporters / Métricas
    |
    v
Grafana Dashboards
```

---

## 9. Estado Actual de la Infraestructura

| Componente | Estado |
|---|---|
| Incus | Operativo |
| OVN | Operativo |
| Open vSwitch | Operativo |
| OpenTofu | Operativo |
| Ansible | Operativo |
| Prometheus | Operativo |
| Grafana | Operativo |
| Ceph | Ver Readme Ceph |

---

## 10. Objetivo del Proyecto

El objetivo principal de esta infraestructura es construir un entorno distribuido y automatizado orientado a:

- Virtualización ligera
- Redes definidas por software
- Observabilidad centralizada
- Infraestructura como código
- Automatización distribuida

