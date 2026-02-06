# Script PowerShell para crear Sistema de Prestamos Diario
# Excel con logica de cobros, calculo de interes 20% y vista semanal

# Crear objeto Excel
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$workbook = $excel.Workbooks.Add()

# === HOJA 1: CONTROL DE COBROS ===
$sheet = $workbook.Worksheets.Item(1)
$sheet.Name = "CONTROL_COBROS"

# --- 1. CONFIGURACION DE FECHA (CALENDARIO) ---
$sheet.Cells.Item(1, 1).Value2 = "FECHA INICIO DE SEMANA (LUNES):"
$sheet.Cells.Item(1, 1).Font.Bold = $true
$sheet.Range("A1").Interior.Color = 49407 # Naranja suave
$sheet.Range("B1").NumberFormat = "yyyy-mm-dd"
$sheet.Range("B1").Value2 = (Get-Date).ToString("yyyy-MM-dd") # Fecha actual por defecto

# --- 2. ENCABEZADOS DE LA TABLA PRINCIPAL ---
$startRow = 4
$headers = @(
    "NOMBRE CLIENTE", 
    "PRESTAMO INICIAL", 
    "TOTAL A PAGAR (+20%)", 
    "CUOTA DIARIA (/6)", 
    "LUNES", 
    "MARTES", 
    "MIERCOLES", 
    "JUEVES", 
    "VIERNES", 
    "SABADO", 
    "TOTAL PAGADO", 
    "SALDO PENDIENTE", 
    "ESTADO"
)

# Estilos de encabezado
for ($i = 0; $i -lt $headers.Count; $i++) {
    $col = $i + 1
    $cell = $sheet.Cells.Item($startRow, $col)
    $cell.Value2 = $headers[$i]
    $cell.Font.Bold = $true
    $cell.Font.Color = 16777215 # Blanco
    $cell.Interior.Color = 12611584 # Azul oscuro
    $cell.HorizontalAlignment = -4108 # Centro
    $cell.VerticalAlignment = -4108
    $cell.Borders.Weight = 2
}

# --- 3. FORMULAS Y FORMATO PARA 50 CLIENTES ---
for ($row = 5; $row -le 55; $row++) {
    # Columna A: Nombre (Texto)
    
    # Columna B: Prestamo Inicial (Moneda)
    $sheet.Cells.Item($row, 2).NumberFormat = "$ #,##0"
    
    # Columna C: Total con Interes 20% (=B*1.2)
    $sheet.Cells.Item($row, 3).Formula = "=IF(B$row="""","""",B$row*1.20)"
    $sheet.Cells.Item($row, 3).NumberFormat = "$ #,##0"
    $sheet.Cells.Item($row, 3).Interior.Color = 15132390 # Gris claro
    
    # Columna D: Cuota Diaria (=C/6)
    $sheet.Cells.Item($row, 4).Formula = "=IF(C$row="""","""",C$row/6)"
    $sheet.Cells.Item($row, 4).NumberFormat = "$ #,##0"
    $sheet.Cells.Item($row, 4).Font.Bold = $true
    $sheet.Cells.Item($row, 4).Interior.Color = 14348258 # Verde claro
    
    # Columnas E-J: Dias de Pago (Input)
    for ($d = 5; $d -le 10; $d++) {
        $sheet.Cells.Item($row, $d).NumberFormat = "$ #,##0"
    }

    # Columna K: Total Pagado (Suma Dias)
    $sheet.Cells.Item($row, 11).Formula = "=SUM(E$row:J$row)"
    $sheet.Cells.Item($row, 11).NumberFormat = "$ #,##0"
    
    # Columna L: Saldo Pendiente (=Total - Pagado)
    $sheet.Cells.Item($row, 12).Formula = "=IF(C$row="""","""",C$row-K$row)"
    $sheet.Cells.Item($row, 12).NumberFormat = "$ #,##0"
    
    # Columna M: Estado
    $sheet.Cells.Item($row, 13).Formula = "=IF(B$row="""","""",IF(L$row<=0,""PAGADO"",""PENDIENTE""))"
    
    # Bordes para toda la fila
    $sheet.Range("A$row:M$row").Borders.Weight = 2
}

# --- 4. FECHAS DINAMICAS EN ENCABEZADOS DE DIAS ---
# Usamos formulas para que los titulos de Lunes-Sabado muestren la fecha segun B1
$sheet.Cells.Item($startRow - 1, 5).Formula = "=B1" # Lunes
$sheet.Cells.Item($startRow - 1, 6).Formula = "=B1+1" # Martes
$sheet.Cells.Item($startRow - 1, 7).Formula = "=B1+2"
$sheet.Cells.Item($startRow - 1, 8).Formula = "=B1+3"
$sheet.Cells.Item($startRow - 1, 9).Formula = "=B1+4"
$sheet.Cells.Item($startRow - 1, 10).Formula = "=B1+5" # Sabado

# Formato de fecha en los dia
$sheet.Range("E3:J3").NumberFormat = "dd/mm"
$sheet.Range("E3:J3").HorizontalAlignment = -4108
$sheet.Range("E3:J3").Font.Bold = $true
$sheet.Range("E3:J3").Font.Color = 8421504 # Gris oscuro

# --- 5. AJUSTE DE ANCHOS ---
$sheet.Columns.Item(1).ColumnWidth = 25 # Nombre
$sheet.Columns.Item(2).ColumnWidth = 15 # Prestamo
$sheet.Columns.Item(3).ColumnWidth = 18 # Total
$sheet.Columns.Item(4).ColumnWidth = 15 # Cuota
for ($c = 5; $c -le 10; $c++) { $sheet.Columns.Item($c).ColumnWidth = 12 } # Dias
$sheet.Columns.Item(11).ColumnWidth = 15 # Total Pagado
$sheet.Columns.Item(12).ColumnWidth = 15 # Saldo
$sheet.Columns.Item(13).ColumnWidth = 12 # Estado

# --- 6. INSTRUCCIONES EMERGENTES (COMENTARIOS) ---
$comm = $sheet.Range("B1").AddComment("Ingresa aqui la fecha del Lunes de esta semana para actualizar las fechas de las columnas.")
$comm.Shape.TextFrame.Characters().Font.Bold = $true

# --- 7. GUARDAR ---
$path = "d:\RecoverAI\Sistema_Prestamos\Sistema_Cobro_Diario.xlsx"
$workbook.SaveAs($path)
$workbook.Close()
$excel.Quit()

# Limpieza
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sheet) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
[System.GC]::Collect()

Write-Host "Sistema de Prestamos Creado en: $path"
