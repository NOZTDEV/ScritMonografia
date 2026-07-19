# 🛡️ Prototipo de Preservación Volátil - Respuesta a Infostealers

Este es un script en Batch (`.bat`) de respuesta a incidentes diseñado para la recolección automatizada de evidencia digital y datos volátiles en sistemas Windows. Su objetivo principal es preservar información crítica antes de que el equipo sea apagado, enfocándose en la detección de malware tipo *Infostealer*.

## ⚙️ Características y Recolección de Datos

El script crea una carpeta de evidencia fechada en el Escritorio del usuario y extrae automáticamente los siguientes artefactos:

1. **Conexiones de Red:** Registra las conexiones activas y los puertos en escucha (`netstat`).
2. **Caché DNS:** Extrae el historial de resolución de nombres de dominio (`ipconfig /displaydns`).
3. **Procesos en Memoria:** Captura todos los procesos en ejecución, sus IDs y las líneas de comando exactas que los iniciaron.
4. **Tareas Programadas:** Exporta la lista completa de tareas programadas del sistema en formato CSV.
5. **Detección Heurística:** Analiza procesos sospechosos ejecutándose desde directorios comunes de malware (como `Temp` y `AppData`).
6. **Volcado de Memoria RAM:** Utiliza `winpmem.exe` para generar una copia física completa de la memoria RAM (`.raw`).
7. **Cadena de Custodia (Integridad):** Genera automáticamente firmas criptográficas SHA-256 de todos los archivos recolectados para garantizar su validez forense.

## ⚠️ Requisitos previos

* **Privilegios de Administrador:** El script verificará y exigirá ejecución como Administrador para poder acceder a la memoria física y a las conexiones de red de bajo nivel.
* **Dependencias:** El ejecutable `winpmem.exe` debe estar ubicado en el mismo directorio desde donde se ejecuta el script.

## 🚀 Uso

1. Haz clic derecho sobre el archivo `.bat` (o `.exe` si está compilado).
2. Selecciona **"Ejecutar como administrador"**.
3. No cierres la ventana de la terminal. El proceso tomará varios minutos dependiendo de la cantidad de memoria RAM instalada en el equipo.
4. Al finalizar, entrega la carpeta generada en el Escritorio al equipo de ciberseguridad o análisis forense. **No abra ni modifique** los archivos internos para no alterar los hashes de integridad.