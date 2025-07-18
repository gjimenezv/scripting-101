<#
.SYNOPSIS
    Automatiza la creación de usuarios temporales desde CSV.
.DESCRIPTION
    Crea cuentas locales con contraseñas seguras y asigna privilegios.
#>

# Configuración
$RutaCSV = Join-Path $PSScriptRoot "..\data\empleados.csv"
$LogFile = Join-Path $PSScriptRoot "..\logs\usuarios_$(Get-Date -Format 'yyyyMMdd').log"
$DominioEmail = "@tiendairsig02.com"

# Crear directorios necesarios
$dataDir = Join-Path $PSScriptRoot "..\data"
$logsDir = Join-Path $PSScriptRoot "..\logs"

if (-not (Test-Path $dataDir)) { New-Item -ItemType Directory -Path $dataDir -Force | Out-Null }
if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir -Force | Out-Null }

# Función para generar contraseña segura
function New-SecurePassword {
    $Caracteres = 'abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@#$%&*?'
    return -join (1..12 | ForEach-Object { $Caracteres[(Get-Random -Maximum $Caracteres.Length)] })
}

# Función para acortar descripción
function Get-ShortDescription {
    param (
        [string]$Puesto,
        [string]$Departamento,
        [string]$FechaInicio,
        [string]$FechaFin
    )
    $fechaInicioShort = (Get-Date $FechaInicio -Format "MM/dd")
    $fechaFinShort = (Get-Date $FechaFin -Format "MM/dd")
    return "Temp:$($Puesto.Substring(0,3)) $($Departamento.Substring(0,3)) $fechaInicioShort-$fechaFinShort"
}

# Iniciar registro de actividades
Start-Transcript -Path $LogFile -Append
Write-Output "=== INICIO DE PROCESO: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ==="

try {
    # Importar datos desde CSV
    if (-not (Test-Path $RutaCSV)) {
        throw "Archivo CSV no encontrado en $RutaCSV"
    }

    $Empleados = Import-Csv -Path $RutaCSV -Encoding UTF8

    foreach ($Empleado in $Empleados) {
        try {
            # Generar credenciales
            $Username = "$($Empleado.Nombre.Substring(0,1))$($Empleado.Apellido)".ToLower() -replace '[^\w]', ''
            $Email = "$Username$DominioEmail"
            $Password = New-SecurePassword
            $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

            # Crear descripción corta (máximo 48 caracteres)
            $Descripcion = Get-ShortDescription -Puesto $Empleado.Puesto -Departamento $Empleado.Departamento -FechaInicio $Empleado.FechaInicio -FechaFin $Empleado.FechaFin

            # Crear usuario local
            $userParams = @{
                Name = $Username
                FullName = "$($Empleado.Nombre) $($Empleado.Apellido)"
                Password = $SecurePassword
                AccountNeverExpires = $false
                Description = $Descripcion
                ErrorAction = 'Stop'
            }
            
            New-LocalUser @userParams

            # Asignar a grupos según el puesto
            $group = if ($Empleado.Puesto -match "Supervisor|Gerente|Admin") { "Administradores" } else { "Usuarios" }
            Add-LocalGroupMember -Group $group -Member $Username -ErrorAction SilentlyContinue

            # Configurar fecha de expiración
            try {
                $ExpiryDate = [datetime]::Parse($Empleado.FechaFin)
                Set-LocalUser -Name $Username -AccountExpires $ExpiryDate -ErrorAction SilentlyContinue
            }
            catch {
                Write-Output ("[ADVERTENCIA] Fecha invalida para " + $Username + ": " + $Empleado.FechaFin)
            }

            # Registrar creación exitosa
            Write-Output "[EXITO] Usuario creado: $Username"
            Write-Output "        Nombre: $($Empleado.Nombre) $($Empleado.Apellido)"
            Write-Output "        Email: $Email"
            Write-Output "        Contraseña: $Password"
            Write-Output "        Puesto: $($Empleado.Puesto)"
            Write-Output "        Grupo: $group"
            Write-Output "        Vigencia: $($Empleado.FechaInicio) al $($Empleado.FechaFin)"
            Write-Output "----------------------------------------"
        }
        catch {
            Write-Output ("[ERROR] Fallo al crear " + $Username + ": " + $_.Exception.Message)
        }
    }
}
catch {
    Write-Output "[ERROR CRITICO] $($_.Exception.Message)"
}
finally {
    Write-Output "=== FIN DE PROCESO: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ==="
    Stop-Transcript
}