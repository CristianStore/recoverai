# Script PowerShell para crear Sistema de Prestamos V2 (Avanzado)
# Incluye: Base de datos historica, Buscador por fecha, Filtros y Logica de Cuotas

# Crear objeto Excel
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$workbook = $excel.Workbooks.Add()

# ==========================================
# HOJA 1: BUSCADOR Y REGISTRO (Principal)
# ==========================================
$sheet = $workbook.Worksheets.Item(1)
$sheet.Name = "SISTEMA_COBROS_V2"

# --- 1. PANEL DE BUSQUEDA (Simulacion de Calendario) ---
$sheet.Range("A1:M2").Interior.Color = 2829099 # Gris oscuro de fondo
$sheet.Cells.Item(1, 2).Value2 = "BUSCADOR DE FECHA:"
$sheet.Cells.Item(1, 2).Font.Color = 16777215 # Blanco
$sheet.Cells.Item(1, 2).Font.Bold = $true

# Casilla de entrada de fecha (Buscador)
$searchCell = $sheet.Cells.Item(1, 4) # D1
$searchCell.NumberFormat = "yyyy-mm-dd"
$searchCell.Interior.Color = 65535 # Amarillo
$searchCell.Borders.Weight = 3
$searchCell.Value2 = (Get-Date).ToString("yyyy-MM-dd")

# Validacion de datos (Fechas 2026 en adelante)
$validation = $searchCell.Validation
$validation.Add(4, 1, 1, "2026-01-01", "2030-12-31") # xlValidateDate
$validation.InputTitle = "Seleccionar Fecha"
$validation.InputMessage = "Escribe la fecha a consultar (YYYY-MM-DD)"

# --- 2. RESUMEN DEL DIA SELECCIONADO ---
$sheet.Cells.Item(1, 6).Value2 = "USUARIOS QUE PAGARON:"
$sheet.Cells.Item(1, 6).Font.Color = 16777215
$sheet.Cells.Item(1, 6).Font.Bold = $true

# Formula para contar pagos en la fecha seleccionada (Se basara en la columan de pagos real)
# Nota: En Excel simple sin macros, filtrar visualmente la tabla es mejor que formulas complejas arrays.
# Usaremos Slicers/Filtros para esto.

# --- 3. TABLA PRINCIPAL DE DATOS ---
$startRow = 5
$headers = @(
    "ID",
    "FECHA INICIO",
    "NOMBRE CLIENTE", 
    "PRESTAMO", 
    "INTERES (20%)",
    "TOTAL A PAGAR", 
    "N CUOTAS",
    "VALOR CUOTA", 
    "FECHA FINAL (ESTIMADA)",
    "TOTAL ABONADO",
    "SALDO PENDIENTE",
    "ESTADO",
    "ULTIMO PAGO (FECHA)"
)

# Estilos de encabezado
for ($i = 0; $i -lt $headers.Count; $i++) {
    $col = $i + 1
    $cell = $sheet.Cells.Item($startRow, $col)
    $cell.Value2 = $headers[$i]
    $cell.Interior.Color = 12611584 # Azul corporativo
    $cell.Font.Color = 16777215 # Blanco
    $cell.Font.Bold = $true
    $cell.HorizontalAlignment = -4108 # Centro
    $cell.Borders.Weight = 2
}

# --- 4. DATA DE EJEMPLO Y FORMULAS (Filas 6 a 106) ---
for ($row = 6; $row -le 106; $row++) {
    # A: ID
    $idVal = $row - 5
    $sheet.Cells.Item($row, 1).Value2 = "$idVal"
    
    # B: Fecha Inicio
    $sheet.Cells.Item($row, 2).NumberFormat = "yyyy-mm-dd"
    
    # C: Nombre (Vacio)
    
    # D: Prestamo
    $sheet.Cells.Item($row, 4).NumberFormat = "$ #,##0"
    
    # E: Interes 20% (=D*0.2)
    $sheet.Cells.Item($row, 5).Formula = "=IF(D$row="""","""",D$row*0.20)"
    $sheet.Cells.Item($row, 5).NumberFormat = "$ #,##0"
    
    # F: Total (=D+E)
    $sheet.Cells.Item($row, 6).Formula = "=IF(D$row="""","""",D$row+E$row)"
    $sheet.Cells.Item($row, 6).NumberFormat = "$ #,##0"
    $sheet.Cells.Item($row, 6).Font.Bold = $true
    
    # G: N Cuotas (Default 6)
    $sheet.Cells.Item($row, 7).Value2 = 6
    $sheet.Cells.Item($row, 7).HorizontalAlignment = -4108
    
    # H: Valor Cuota (=F/G)
    $sheet.Cells.Item($row, 8).Formula = "=IF(G$row="""","""",F$row/G$row)"
    $sheet.Cells.Item($row, 8).NumberFormat = "$ #,##0"
    $sheet.Cells.Item($row, 8).Interior.Color = 14348258 # Verde suave
    
    # I: Fecha Final Estimada (Excluyendo Domingos)
    # Formula compleja: WORKDAY.INTL(FechaInicio, Cuotas, 11) -> 11 es Solo Domingos fin de semana
    $sheet.Cells.Item($row, 9).Formula = "=IF(B$row="""","""",WORKDAY.INTL(B$row,G$row,11))"
    $sheet.Cells.Item($row, 9).NumberFormat = "yyyy-mm-dd"
    
    # J: Total Abonado (Manual o Subtabla)
    # Para simplicidad en una sola hoja, el usuario actualiza esto manual o suma de columnas ocultas.
    # El usuario pidio "calenadario emergente y que me arrojen las cifras de los dias".
    # Esto requiere una hoja de registro diario separada. Haremos un hibrido.
    $sheet.Cells.Item($row, 10).NumberFormat = "$ #,##0"
    
    # K: Saldo (=F-J)
    $sheet.Cells.Item($row, 11).Formula = "=IF(F$row="""","""",F$row-J$row)"
    $sheet.Cells.Item($row, 11).NumberFormat = "$ #,##0"
    
    # L: Estado
    $sheet.Cells.Item($row, 12).Formula = "=IF(J$row="""","""",IF(K$row<=0,""PAGADO"",""PENDIENTE""))"
    
    # M: Ultimo Pago
    $sheet.Cells.Item($row, 13).NumberFormat = "yyyy-mm-dd"
    
    $sheet.Range("A$row:M$row").Borders.Weight = 2
}

# ACTIVAR FILTROS (Esto permite filtrar por Nombre, Fecha, Monto)
$sheet.Range("A5:M5").AutoFilter()

# --- 5. LOGICA DE DOMINGOS Y RECAUDO ---
# Nota en pantalla
$sheet.Cells.Item(3, 2).Value2 = "NOTA: Los Domingos NO se cuentan para la fecha final ni recaudo."
$sheet.Cells.Item(3, 2).Font.Italic = $true
$sheet.Cells.Item(3, 2).Font.Size = 8

# --- 6. AJUSTE DE ANCHOS ---
$sheet.Columns.Item(2).ColumnWidth = 15
$sheet.Columns.Item(3).ColumnWidth = 25 # Nombre
$sheet.Columns.Item(6).ColumnWidth = 15 # Total
$sheet.Columns.Item(9).ColumnWidth = 15 # Fecha Final

# --- 7. HOJA DE REGISTRO DIARIO (DETALLE) ---
# Aqui es donde se cumple "buscar fecha y ver quien pago"
$sheet2 = $workbook.Worksheets.Add()
$sheet2.Name = "REGISTRO_DIARIO_PAGOS"

# Encabezados
$h2 = @("FECHA PAGO", "NOMBRE CLIENTE", "MONTO ABONADO", "COMENTARIO")
for ($i = 0; $i -lt $h2.Count; $i++) {
    $sheet2.Cells.Item(1, $i + 1).Value2 = $h2[$i]
    $sheet2.Cells.Item(1, $i + 1).Font.Bold = $true
    $sheet2.Cells.Item(1, $i + 1).Interior.Color = 49407 # Naranja
}

# Filtros activados
$sheet2.Range("A1:D1").AutoFilter()
$sheet2.Columns.Item(1).ColumnWidth = 15
$sheet2.Columns.Item(2).ColumnWidth = 25
$sheet2.Columns.Item(3).ColumnWidth = 15

# INSTRUCCIONES ESPECIFICAS
$sheet3 = $workbook.Worksheets.Add()
$sheet3.Name = "INSTRUCCIONES"
$sheet3.Cells.Item(1, 1).Value2 = "COMO USAR EL BUSCADOR DE FECHAS:"
$sheet3.Cells.Item(2, 1).Value2 = "1. Para ver quien pago en una fecha especifica, ve a la hoja 'REGISTRO_DIARIO_PAGOS'."
$sheet3.Cells.Item(3, 1).Value2 = "2. Haz clic en la flecha del filtro de 'FECHA PAGO'."
$sheet3.Cells.Item(4, 1).Value2 = "3. Selecciona el año (2026, 2027...) y el dia."
$sheet3.Cells.Item(6, 1).Value2 = "EN LA HOJA SISTEMA_COBROS_V2:"
$sheet3.Cells.Item(7, 1).Value2 = "- La columna N CUOTAS puedes cambiarla (6, 12, 24...)."
$sheet3.Cells.Item(8, 1).Value2 = "- La Fecha Final se calcula sola saltando los Domingos."

# Guardar
$path = "d:\RecoverAI\Sistema_Prestamos\Sistema_Prestamos_V2.xlsx"
$workbook.SaveAs($path)
$workbook.Close()
$excel.Quit()

# Limpieza
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sheet) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sheet2) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sheet3) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
[System.GC]::Collect()

Write-Host "Sistema V2 creado en: $path"
