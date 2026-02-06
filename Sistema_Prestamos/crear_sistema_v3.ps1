# Script PowerShell para crear Sistema de Prestamos V3 (Soles & Totales)
# Incluye: Moneda PEN (S/.), Calculos de Totales Generales y Base de datos

# Crear objeto Excel
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$workbook = $excel.Workbooks.Add()

# ==========================================
# HOJA 1: SISTEMA_COBROS_V3 (Principal)
# ==========================================
$sheet = $workbook.Worksheets.Item(1)
$sheet.Name = "SISTEMA_COBROS_V3"

# --- 1. DASHBOARD FINANCIERO (TOTALES) ---
# Fondo oscuro para el header
$sheet.Range("A1:M4").Interior.Color = 2829099 

# Buscador de Fecha
$sheet.Cells.Item(1, 2).Value2 = "BUSCADOR DE FECHA:"
$sheet.Cells.Item(1, 2).Font.Color = 16777215
$sheet.Cells.Item(1, 2).Font.Bold = $true
$searchCell = $sheet.Cells.Item(1, 4)
$searchCell.NumberFormat = "yyyy-mm-dd"
$searchCell.Interior.Color = 65535
$searchCell.Value2 = (Get-Date).ToString("yyyy-MM-dd")

# --- NUEVO: CALCULOS DE TOTALES (En la parte superior) ---
# Etiqueta Capital
$sheet.Cells.Item(2, 6).Value2 = "CAPITAL TOTAL PRESTADO:"
$sheet.Cells.Item(2, 6).Font.Color = 16777215
$sheet.Cells.Item(2, 6).Font.Bold = $true
$sheet.Cells.Item(2, 6).HorizontalAlignment = -4152 # Right align

# Formula Capital (Suma de Columna D)
$sheet.Cells.Item(2, 7).Formula = "=SUM(D6:D1000)"
$sheet.Cells.Item(2, 7).NumberFormat = """S/."" #,##0.00"
$sheet.Cells.Item(2, 7).Font.Bold = $true
$sheet.Cells.Item(2, 7).Font.Size = 12
$sheet.Cells.Item(2, 7).Interior.Color = 16777215 # Blanco (resaltado)

# Etiqueta Ganancia
$sheet.Cells.Item(3, 6).Value2 = "GANANCIA TOTAL (INTERESES):"
$sheet.Cells.Item(3, 6).Font.Color = 65280 # Verde brillante texto
$sheet.Cells.Item(3, 6).Font.Bold = $true
$sheet.Cells.Item(3, 6).HorizontalAlignment = -4152

# Formula Ganancia (Suma de Columna E)
$sheet.Cells.Item(3, 7).Formula = "=SUM(E6:E1000)"
$sheet.Cells.Item(3, 7).NumberFormat = """S/."" #,##0.00"
$sheet.Cells.Item(3, 7).Font.Bold = $true
$sheet.Cells.Item(3, 7).Font.Size = 12
$sheet.Cells.Item(3, 7).Interior.Color = 13434828 # Verde suave fondo

# --- 2. TABLA PRINCIPAL DE DATOS ---
$startRow = 5
$headers = @(
    "ID",
    "FECHA INICIO",
    "NOMBRE CLIENTE", 
    "PRESTAMO (CAPITAL)", 
    "INTERES (20%)",
    "TOTAL A PAGAR", 
    "N CUOTAS",
    "VALOR CUOTA", 
    "FECHA FINAL",
    "TOTAL ABONADO",
    "SALDO PENDIENTE",
    "ESTADO",
    "ULTIMO PAGO"
)

# Estilos de encabezado
for ($i = 0; $i -lt $headers.Count; $i++) {
    $col = $i + 1
    $cell = $sheet.Cells.Item($startRow, $col)
    $cell.Value2 = $headers[$i]
    $cell.Interior.Color = 12611584
    $cell.Font.Color = 16777215
    $cell.Font.Bold = $true
    $cell.HorizontalAlignment = -4108
    $cell.Borders.Weight = 2
}

# --- 3. DATA Y FORMULAS (Filas 6 a 106) ---
# Primero: Generar lista de fechas en hoja oculta para el Dropdown (Simulacion Calendario)
$sheetDates = $workbook.Worksheets.Add()
$sheetDates.Name = "LISTA_FECHAS"
$sheetDates.Visible = 0 # xlSheetHidden
# Generar fechas desde 2026-01-01 hasta 2029-12-31 (aprox 1461 dias)
$startDate = Get-Date -Date "2026-01-01"
for ($i = 0; $i -lt 1461; $i++) {
    $d = $startDate.AddDays($i)
    $sheetDates.Cells.Item($i + 1, 1).Value2 = "'" + $d.ToString("yyyy-MM-dd") # Apostrofe para asegurar texto/formato
}

# Volver a hoja principal
$sheet.Activate()

for ($row = 6; $row -le 106; $row++) {
    # A: ID
    $idVal = $row - 5
    $sheet.Cells.Item($row, 1).Value2 = "$idVal"
    
    # B: Fecha (CON DROPDOWN TIPO CALENDARIO)
    $sheet.Cells.Item($row, 2).NumberFormat = "yyyy-mm-dd"
    $val = $sheet.Cells.Item($row, 2).Validation
    $val.Delete()
    $val.Add(3, 1, 1, '=LISTA_FECHAS!$A$1:$A$1461') # 3 = xlValidateList
    $val.IgnoreBlank = $true
    $val.InCellDropdown = $true
    $val.InputTitle = "Seleccionar Fecha"
    $val.InputMessage = "Elige de la lista o escribe (YYYY-MM-DD)"
    $val.ShowInput = $true
    
    # D: Prestamo (Moneda Peru S/.)
    $sheet.Cells.Item($row, 4).NumberFormat = """S/."" #,##0.00"
    
    # E: Interes 20%
    $sheet.Cells.Item($row, 5).Formula = "=IF(D$row="""","""",D$row*0.20)"
    $sheet.Cells.Item($row, 5).NumberFormat = """S/."" #,##0.00"
    $sheet.Cells.Item($row, 5).Font.Color = 32768 # Verde oscuro
    
    # F: Total
    $sheet.Cells.Item($row, 6).Formula = "=IF(D$row="""","""",D$row+E$row)"
    $sheet.Cells.Item($row, 6).NumberFormat = """S/."" #,##0.00"
    $sheet.Cells.Item($row, 6).Font.Bold = $true
    
    # G: Cuotas (Default 6)
    $sheet.Cells.Item($row, 7).Value2 = 6
    $sheet.Cells.Item($row, 7).HorizontalAlignment = -4108
    
    # H: Valor Cuota
    $sheet.Cells.Item($row, 8).Formula = "=IF(G$row="""","""",F$row/G$row)"
    $sheet.Cells.Item($row, 8).NumberFormat = """S/."" #,##0.00"
    
    # I: Fecha Final (Sin Domingos)
    $sheet.Cells.Item($row, 9).Formula = "=IF(B$row="""","""",WORKDAY.INTL(B$row,G$row,11))"
    $sheet.Cells.Item($row, 9).NumberFormat = "yyyy-mm-dd"
    
    # J: Abonado
    $sheet.Cells.Item($row, 10).NumberFormat = """S/."" #,##0.00"
    
    # K: Saldo
    $sheet.Cells.Item($row, 11).Formula = "=IF(F$row="""","""",F$row-J$row)"
    $sheet.Cells.Item($row, 11).NumberFormat = """S/."" #,##0.00"
    $sheet.Cells.Item($row, 11).Font.Color = 255 # Rojo
    
    # L: Estado
    $sheet.Cells.Item($row, 12).Formula = "=IF(J$row="""","""",IF(K$row<=0,""PAGADO"",""PENDIENTE""))"
    
    $sheet.Range("A$row:M$row").Borders.Weight = 2
}

$sheet.Range("A5:M5").AutoFilter()

# Ajuste de anchos
$sheet.Columns.Item(3).ColumnWidth = 25 # Nombre
$sheet.Columns.Item(4).ColumnWidth = 18 # Prestamo
$sheet.Columns.Item(5).ColumnWidth = 15 # Interes
$sheet.Columns.Item(6).ColumnWidth = 18 # Total
$sheet.Columns.Item(7).ColumnWidth = 10 # Cuotas

# --- HOJA 2: REGISTRO DIARIO ---
$sheet2 = $workbook.Worksheets.Add()
$sheet2.Name = "REGISTRO_DIARIO"
$h2 = @("FECHA PAGO", "NOMBRE CLIENTE", "MONTO QUE DIO (S/.)", "NOTA")
for ($i = 0; $i -lt $h2.Count; $i++) {
    $sheet2.Cells.Item(1, $i + 1).Value2 = $h2[$i]
    $sheet2.Cells.Item(1, $i + 1).Font.Bold = $true
    $sheet2.Cells.Item(1, $i + 1).Interior.Color = 49407
}
$sheet2.Columns.Item(3).NumberFormat = """S/."" #,##0.00"
$sheet2.Columns.Item(2).ColumnWidth = 25
$sheet2.Range("A1:D1").AutoFilter()

# Guardar
$path = "d:\RecoverAI\Sistema_Prestamos\Sistema_Prestamos_V3_Soles.xlsx"
$workbook.SaveAs($path)
$workbook.Close()
$excel.Quit()

# Limpieza
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sheet) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sheet2) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
[System.GC]::Collect()

Write-Host "Sistema V3 (SOLES) creado en: $path"
