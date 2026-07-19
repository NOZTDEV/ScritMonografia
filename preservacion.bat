@echo off
TITLE Prototipo de Preservacion Volatil - Respuesta a Infostealers
color 4F

:: 1. VERIFICACION DE PRIVILEGIOS DE ADMINISTRADOR
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :inicio
) else (
    color 4F
    echo ===============================================================
    echo ERROR: PRIVILEGIOS INSUFICIENTES
    echo ===============================================================
    echo.
    echo Para realizar el volcado de memoria RAM y preservar la
    echo evidencia, este archivo NECESITA permisos de Administrador.
    echo.
    echo Por favor, cierre esta ventana, haga CLIC DERECHO sobre el 
    echo archivo .exe y seleccione "Ejecutar como administrador".
    echo.
    pause
    exit
)

:inicio
color 1F

:: === REGISTRO DE TIEMPO DE INICIO ===
for /f "tokens=*" %%a in ('powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"') do set "start_date=%%a"
for /f "tokens=*" %%b in ('powershell -NoProfile -Command "[DateTimeOffset]::Now.ToUnixTimeSeconds()"') do set "start_secs=%%b"

echo ===============================================================
echo      INICIANDO PRESERVACION DE EVIDENCIA: INFOSTEALERS
echo ===============================================================
echo [*] Fecha y hora de inicio: %start_date%
echo.
echo Por favor, no cierre esta ventana. 
echo NOTA: El proceso completo tomara varios minutos debido al 
echo volcado de memoria fisica (RAM Dump).
echo.

:: 2. CREACION DE CARPETA EN EL ESCRITORIO
for /f "tokens=*" %%I in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Date -Format 'yyyyMMdd_HHmmss'"') do set datetime=%%I
set "folder=%USERPROFILE%\Desktop\Evidencia_Infostealer_%datetime%"

mkdir "%folder%"
echo [*] Carpeta de preservacion creada en su Escritorio.

:: 3. EXTRACCION DE EVIDENCIA DE ALTA VOLATILIDAD
echo [*] Extrayendo conexiones de red activas...
netstat -anob > "%folder%\01_conexiones_red.txt"

echo [*] Extrayendo historial de resolucion DNS...
ipconfig /displaydns > "%folder%\02_cache_dns.txt"

echo [*] Extrayendo procesos en memoria RAM y lineas de comandos...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Process | Select-Object Name, ProcessId, ParentProcessId, CommandLine | Export-Csv -Path '%folder%\03_procesos_memoria.csv' -NoTypeInformation -Encoding UTF8"

echo [*] Extrayendo tareas programadas...
schtasks /query /fo csv /v > "%folder%\04_tareas_programadas.csv"

:: 4. MODULO DE DETECCION HEURISTICA
echo [*] Analizando procesos sospechosos en rutas de perfil de usuario...
echo ===================================================================== > "%folder%\05_alerta_posibles_infostealers.txt"
echo             REPORTE DE HALLAZGOS SOSPECHOSOS (INFOSTEALERS)          >> "%folder%\05_alerta_posibles_infostealers.txt"
echo ===================================================================== >> "%folder%\05_alerta_posibles_infostealers.txt"
echo. >> "%folder%\05_alerta_posibles_infostealers.txt"
echo Los Infostealers suelen ejecutarse de forma oculta desde las carpetas Temp o AppData. >> "%folder%\05_alerta_posibles_infostealers.txt"
echo Si aparecen procesos listados a continuacion, el equipo podria estar comprometido: >> "%folder%\05_alerta_posibles_infostealers.txt"
echo Algunos procesos listados pueden no ser Perfudiciales. >> "%folder%\05_alerta_posibles_infostealers.txt"
echo REVISE cada proceso o contacte con un personal capacitado. >> "%folder%\05_alerta_posibles_infostealers.txt"
echo. >> "%folder%\05_alerta_posibles_infostealers.txt"

powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -like '*Temp*' -or $_.ExecutablePath -like '*AppData*' } | Select-Object Name, ProcessId, ExecutablePath | Format-Table | Out-String" >> "%folder%\05_alerta_posibles_infostealers.txt" 2>NUL

echo. >> "%folder%\05_alerta_posibles_infostealers.txt"
echo Busqueda completada. Revise este archivo para confirmar infecciones activas. >> "%folder%\05_alerta_posibles_infostealers.txt"

:: 5. VOLCADO FISICO DE LA MEMORIA RAM
echo.
echo ===============================================================
echo [*] INICIANDO VOLCADO FISICO DE MEMORIA RAM (DUMP)
echo ===============================================================
echo [*] NO INTERRUMPA EL PROCESO...
echo.

if exist winpmem.exe (
    winpmem.exe acquire "%folder%\06_volcado_memoria.raw"
    echo.
    echo [*] Volcado de memoria finalizado exitosamente.
) else (
    color 4F
    echo [!] ERROR CRITICO: El ejecutable winpmem.exe no se extrajo correctamente.
    color 1F
)

:: === REGISTRO DE TIEMPO Y ESCRITURA FINAL EN REPORTE ===
for /f "tokens=*" %%c in ('powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"') do set "end_date=%%c"
for /f "tokens=*" %%d in ('powershell -NoProfile -Command "[DateTimeOffset]::Now.ToUnixTimeSeconds()"') do set "end_secs=%%d"
set /a duration=end_secs - start_secs

:: Se añade la informacion y el aviso forense al TXT antes de generar los hashes
echo. >> "%folder%\05_alerta_posibles_infostealers.txt"
echo ===================================================================== >> "%folder%\05_alerta_posibles_infostealers.txt"
echo [*] METRICAS DE EJECUCION Y CADENA DE CUSTODIA >> "%folder%\05_alerta_posibles_infostealers.txt"
echo ===================================================================== >> "%folder%\05_alerta_posibles_infostealers.txt"
echo Fecha y hora de inicio : %start_date% >> "%folder%\05_alerta_posibles_infostealers.txt"
echo Fecha y hora de fin    : %end_date% >> "%folder%\05_alerta_posibles_infostealers.txt"
echo Tiempo de recoleccion  : %duration% segundos >> "%folder%\05_alerta_posibles_infostealers.txt"
echo. >> "%folder%\05_alerta_posibles_infostealers.txt"
echo [!] AVISO IMPORTANTE PARA EL USUARIO: >> "%folder%\05_alerta_posibles_infostealers.txt"
echo Por favor, contacte a los expertos en ciberseguridad inmediatamente. >> "%folder%\05_alerta_posibles_infostealers.txt"
echo NO modifique, abra ni toque los archivos de esta carpeta. >> "%folder%\05_alerta_posibles_infostealers.txt"
echo Hacerlo alterara los hashes de integridad e invalidara la evidencia. >> "%folder%\05_alerta_posibles_infostealers.txt"
echo ===================================================================== >> "%folder%\05_alerta_posibles_infostealers.txt"

:: 6. CALCULO DE HASHES (INTEGRIDAD DE LA EVIDENCIA)
echo.
echo ===============================================================
echo [*] GENERANDO HASHES DE INTEGRIDAD (SHA-256)
echo ===============================================================
echo [*] Calculando... Esto tomara unos minutos dependiendo del
echo [*] tamano del volcado de memoria. NO CIERRE LA VENTANA.
echo.

:: Se extrae el nombre del archivo desde la propiedad Path usando Split-Path para evitar el error de nombres vacíos
powershell -NoProfile -ExecutionPolicy Bypass -Command "$outfile = '%folder%\07_hashes_integridad.txt'; 'ALGORITMO SHA-256                                                ARCHIVO' | Out-File $outfile -Encoding UTF8; '================================================================ ============================' | Out-File $outfile -Append -Encoding UTF8; Get-ChildItem -Path '%folder%' -File | Where-Object { $_.FullName -ne $outfile } | Get-FileHash -Algorithm SHA256 | ForEach-Object { $fname = Split-Path $_.Path -Leaf; '{0}  {1}' -f $_.Hash, $fname } | Out-File $outfile -Append -Encoding UTF8"

echo [*] Firmas de integridad generadas con exito.

:: 7. FINALIZACION
echo.
echo ===============================================================
echo                 PRESERVACION COMPLETADA CON EXITO
echo ===============================================================
echo.
echo [*] Inicio del proceso : %start_date%
echo [*] Fin del proceso    : %end_date%
echo [*] Tiempo de volcado  : %duration% segundos
echo.
echo Toda la evidencia tecnica ha sido guardada en su Escritorio:
echo %folder%
echo.
echo 1. Verifique "05_alerta_posibles_infostealers.txt" para ver detecciones.
echo 2. El archivo "07_hashes_integridad.txt" garantiza la validez legal.
echo 3. Entregue la carpeta completa a su analista forense.
echo.
echo ===============================================================
echo [!] AVISO IMPORTANTE: Contacte a los expertos de inmediato.
echo [!] NO modifique, abra ni toque NINGUNO de los archivos 
echo [!] generados. Hacerlo invalidara la evidencia recolectada.
echo ===============================================================
echo.
echo Puede cerrar esta ventana con seguridad.
pause > NUL