==========================================================================================

SCRIPT DE AUTOMATIZACIÓN DE WINDOWS: DESCARGA, ANÓNIMIZACIÓN Y CIFRADO (AES-256) DIARIO

==========================================================================================

REQUISITOS:

1. Este archivo debe guardarse como "actualizar_datos.ps1" en tu ordenador.

2. Configurar la clave y la URL directa de OneDrive abajo.

3. Para programar su ejecución a las 8:00 AM, usa el "Programador de Tareas" de Windows.

==========================================================================================

--- CONFIGURACIÓN DE PARÁMETROS ---

$ClaveMaestra = "TuClaveSuperSegura123"  # Esta es la contraseña de desbloqueo web
$URL_OneDrive = "https://onedrive.live.com/download?cid=XXXXXX&resid=XXXXXX&authkey=XXXXXX" # Tu enlace de descarga directa
$PathLocalCSV = ".\reparaciones_temp.csv"
$PathSalidaCifrada = ".\datos.enc"

Write-Host "[+] Iniciando descarga de la base de datos de OneDrive..." -ForegroundColor Cyan

1. DESCARGA AUTOMÁTICA DEL ARCHIVO DE ONEDRIVE

try {
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($URL_OneDrive, $PathLocalCSV)
Write-Host "[+] Archivo descargado de manera exitosa." -ForegroundColor Green
} catch {
Write-Host "[!] Error crítico al descargar de OneDrive: $_" -ForegroundColor Red
Exit
}

2. PROCESAMIENTO DE SEGURIDAD (CUMPLIMIENTO DE LOPD / GDPR)

Este proceso lee el archivo, elimina las columnas personales y crea una versión limpia

Write-Host "[+] Aplicando filtro de seguridad y anonimización de datos corporativos..." -ForegroundColor Cyan

if (Test-Path $PathLocalCSV) {
# Importamos el archivo CSV descargado
$Datos = Import-Csv -Path $PathLocalCSV -Encoding UTF8

# Creamos un nuevo objeto con las columnas NO sensibles de manera controlada
$DatosAnonimizados = $Datos | Select-Object "NUMERO DE EXPEDIENTE", "MUNICIPIO", "PROVINCIA", "CONTENIDO RECLAMACIÓN", "FECHA DE PETICIÓN DE PRESUPUESTO", "PROVEEDOR", "FECHA PRESUPUESTO CEION", "BASE PRESUPUESTO CEION", "ESTADO OBRA", "ESTADO SERVEO", "BASE PRESUPUESTO SERVEO", "PRIORITARIO", "% MARGEN BRUTO POR OFERTA"

# Exportamos el archivo ya anonimizado a memoria (evitamos guardar nombres/teléfonos en el disco duro sin encriptar)
$CSVLimpioTexto = $DatosAnonimizados | ConvertTo-Csv -NoTypeInformation | Out-String

# Eliminamos el temporal con datos sensibles de inmediato
Remove-Item $PathLocalCSV -Force


} else {
Write-Host "[!] El archivo de descarga no pudo ser procesado." -ForegroundColor Red
Exit
}

3. MOTOR DE ENCRIPTACIÓN AES-256 (Compatible con index.html)

Write-Host "[+] Generando encriptación matemática de alta seguridad..." -ForegroundColor Cyan

Derivación simétrica de la clave (SHA256)

$Hasher = [System.Security.Cryptography.SHA256]::Create()
$KeyBytes = $Hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($ClaveMaestra))

Derivación simétrica del IV (Primeros 16 bytes de SHA256)

$IVBytes = New-Object Byte[] 16
[Array]::Copy($KeyBytes, 0, $IVBytes, 0, 16)

Preparación de datos para el encriptador AES

$DatosEnBytes = [System.Text.Encoding]::UTF8.GetBytes($CSVLimpioTexto)

$AES = [System.Security.Cryptography.Aes]::Create()
$AES.Key = $KeyBytes
$AES.IV = $IVBytes
$AES.Mode = [System.Security.Cryptography.CipherMode]::CBC
$AES.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

$Encryptor = $AES.CreateEncryptor()
$ResultadoCifrado = $Encryptor.TransformFinalBlock($DatosEnBytes, 0, $DatosEnBytes.Length)

Conversión a formato Base64 para guardarlo de manera estructurada en texto plano en GitHub

$Base64TextoCifrado = [Convert]::ToBase64String($ResultadoCifrado)

Guardamos el archivo final cifrado (datos.enc)

Set-Content -Path $PathSalidaCifrada -Value $Base64TextoCifrado -NoNewline
Write-Host "[+] Archivo 'datos.enc' generado correctamente y asegurado." -ForegroundColor Green

4. SUBIDA AUTOMÁTICA OPCIONAL A GITHUB (Git Push)

Si ejecutas el script dentro de tu carpeta de repositorio local clonado, descomenta las líneas de abajo:

Write-Host "[+] Enviando actualizaciones al repositorio de GitHub..." -ForegroundColor Cyan

git add datos.enc

git commit -m "Actualizacion automatica diaria del Plan de Reparaciones"

git push origin main

Write-Host "[+] Sistema desplegado en la web." -ForegroundColor Green