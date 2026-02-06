# Script PowerShell para crear archivo Excel con calendario
# Registro de Datos Semanal - Lunes a Sabado

# Crear objeto Excel
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$workbook = $excel.Workbooks.Add()

# === HOJA 1: Registro Semanal ===
$sheet1 = $workbook.Worksheets.Item(1)
$sheet1.Name = "Registro Semanal"

# Configurar encabezados de filas (mas descriptivos)
$headers = @("FECHA (YYYY-MM-DD)", "NOMBRE COMPLETO", "MONTO EN PESOS ($)", "PORCENTAJE (%)")
for ($i = 0; $i -lt $headers.Count; $i++) {
    $row = $i + 1
    $cell = $sheet1.Cells.Item($row, 1)
    $cell.Value2 = $headers[$i]
    $cell.Font.Bold = $true
    $cell.Font.Color = 16777215  # Blanco
    $cell.Interior.Color = 4474084  # Azul
    $cell.HorizontalAlignment = -4108  # Centro
    $cell.VerticalAlignment = -4108
    $cell.Borders.Weight = 2
}

# Configurar dias de la semana (Lunes a Sabado)
$dias = @("LUNES", "MARTES", "MIERCOLES", "JUEVES", "VIERNES", "SABADO")
for ($i = 0; $i -lt $dias.Count; $i++) {
    $col = $i + 2  # Columna B en adelante
    $cell = $sheet1.Cells.Item(5, $col)
    $cell.Value2 = $dias[$i]
    $cell.Font.Bold = $true
    $cell.Font.Color = 16777215  # Blanco
    $cell.Interior.Color = 7385087  # Verde
    $cell.HorizontalAlignment = -4108
    $cell.VerticalAlignment = -4108
    $cell.Borders.Weight = 2
}

# Ajustar anchos de columna
$sheet1.Columns.Item(1).ColumnWidth = 15
for ($col = 2; $col -le 7; $col++) {
    $sheet1.Columns.Item($col).ColumnWidth = 18
}

# Configurar celdas de datos (Filas 1-4, Columnas B-G)
for ($row = 1; $row -le 4; $row++) {
    for ($col = 2; $col -le 7; $col++) {
        $cell = $sheet1.Cells.Item($row, $col)
        $cell.Borders.Weight = 2
        $cell.HorizontalAlignment = -4108
        $cell.VerticalAlignment = -4108
        
        # Formato para Dinero (fila 3)
        if ($row -eq 3) {
            $cell.NumberFormat = "$#,##0.00"
        }
        
        # Formato para Porcentaje (fila 4)
        if ($row -eq 4) {
            $cell.NumberFormat = "0.00%"
        }
    }
}

# Area de busqueda por fecha
$sheet1.Cells.Item(7, 1).Value2 = "BUSCAR FECHA AQUI:"
$sheet1.Cells.Item(7, 1).Font.Bold = $true
$sheet1.Cells.Item(7, 1).Font.Size = 11
$sheet1.Cells.Item(7, 2).NumberFormat = "yyyy-mm-dd"
$sheet1.Cells.Item(7, 2).Value2 = (Get-Date).ToString("yyyy-MM-dd")


# === HOJA 2: Historial Completo ===
$sheet2 = $workbook.Worksheets.Add()
$sheet2.Name = "Historial Completo"

$headersData = @("FECHA", "DIA DE SEMANA", "NOMBRE", "MONTO ($)", "PORCENTAJE (%)")
for ($i = 0; $i -lt $headersData.Count; $i++) {
    $col = $i + 1
    $cell = $sheet2.Cells.Item(1, $col)
    $cell.Value2 = $headersData[$i]
    $cell.Font.Bold = $true
    $cell.Font.Color = 16777215
    $cell.Interior.Color = 4474084
    $cell.HorizontalAlignment = -4108
    $cell.Borders.Weight = 2
    $sheet2.Columns.Item($col).ColumnWidth = 18
}

# === HOJA 3: Guia de Uso ===
$sheet3 = $workbook.Worksheets.Add()
$sheet3.Name = "Guia de Uso"

$instrucciones = @(
    "GUIA RAPIDA - COMO USAR ESTE ARCHIVO",
    "",
    "1. LLENAR DATOS DE LA SEMANA:",
    "   - Abre la hoja 'Registro Semanal'",
    "   - Veras 6 columnas: una para cada dia (Lunes a Sabado)",
    "   - En cada columna llena:",
    "     * FECHA: Escribe la fecha en formato 2026-02-04",
    "     * NOMBRE COMPLETO: Escribe el nombre de la persona",
    "     * MONTO EN PESOS: Escribe solo el numero (ej: 1500.50)",
    "     * PORCENTAJE: Escribe como decimal (ej: 0.15 para 15%)",
    "",
    "2. BUSCAR INFORMACION POR FECHA:",
    "   - En la hoja 'Registro Semanal', ve a la celda B7",
    "   - Escribe la fecha que buscas",
    "   - Luego busca esa fecha en la hoja 'Historial Completo'",
    "",
    "3. GUARDAR REGISTROS ANTIGUOS:",
    "   - Abre la hoja 'Historial Completo'",
    "   - Copia los datos de la semana que quieras guardar",
    "   - Pega una nueva fila con toda la informacion",
    "   - Usa los filtros de Excel para buscar datos especificos",
    "",
    "4. TIPS IMPORTANTES:",
    "   - Guarda el archivo frecuentemente (presiona Ctrl+S)",
    "   - El dinero se muestra automaticamente con simbolo $",
    "   - Los porcentajes se muestran automaticamente con simbolo %",
    "   - Puedes agregar todas las filas que necesites en 'Historial Completo'"
)

for ($i = 0; $i -lt $instrucciones.Count; $i++) {
    $row = $i + 1
    $cell = $sheet3.Cells.Item($row, 1)
    $cell.Value2 = $instrucciones[$i]
    
    if ($instrucciones[$i] -like "*COMO USAR*") {
        $cell.Font.Bold = $true
        $cell.Font.Size = 14
        $cell.Font.Color = 4474084
    }
    elseif ($instrucciones[$i] -match "^\d+\.") {
        $cell.Font.Bold = $true
        $cell.Font.Size = 11
    }
}

$sheet3.Columns.Item(1).ColumnWidth = 80

# Guardar archivo
$outputPath = "d:\RecoverAI\GestorDatos\Registro_Semanal.xlsx"
$workbook.SaveAs($outputPath)
$workbook.Close()
$excel.Quit()

# Liberar objetos COM
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sheet1) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sheet2) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sheet3) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

Write-Host "ARCHIVO EXCEL CREADO CON EXITO!" -ForegroundColor Green
Write-Host "Ubicacion: $outputPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "El archivo contiene 3 hojas:" -ForegroundColor Yellow
Write-Host "  1. Registro Semanal - Para llenar datos de Lunes a Sabado" -ForegroundColor White
Write-Host "  2. Historial Completo - Para guardar registros antiguos" -ForegroundColor White
Write-Host "  3. Guia de Uso - Instrucciones detalladas" -ForegroundColor White


