# Script PowerShell para crear Sistema de Prestamos V4 (Version Estable)
# Formato: Soles S/. sin decimales, 1-30 cuotas individuales, Salto de Domingos, Estados Dinamicos

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$workbook = $excel.Workbooks.Add()

# ==========================================
# HOJA 1: SISTEMA_PRESTAMOS_V4
# ==========================================
$sheet = $workbook.Worksheets.Item(1)
$sheet.Name = "SISTEMA_V4"

# --- 1. DASHBOARD DE TOTALES (Header) ---
$headerRange = $sheet.Range("A1:AZ4")
$headerRange.Interior.Color = 2829099 

# Buscador / Fecha Actual
$sheet.Cells.Item(1, 2).Value2 = "FECHA DE HOY:"
$sheet.Cells.Item(1, 2).Font.Color = 16777215
$sheet.Cells.Item(1, 2).Font.Bold = $true
$todayCell = $sheet.Cells.Item(1, 4)
$todayCell.Value2 = (Get-Date).ToString("yyyy-MM-dd")
$todayCell.NumberFormat = "yyyy-mm-dd"
$todayCell.Interior.Color = 65535 # Amarillo

# Totales
$sheet.Cells.Item(2, 6).Value2 = "CAPITAL TOTAL:"
$sheet.Cells.Item(2, 6).Font.Color = 16777215
$sheet.Cells.Item(2, 7).Formula = "=SUM(D6:D1000)"
$sheet.Cells.Item(2, 7).NumberFormat = """S/."" #,##0"
$sheet.Cells.Item(2, 7).Font.Bold = $true

$sheet.Cells.Item(3, 6).Value2 = "INTERESES TOTALES:"
$sheet.Cells.Item(3, 6).Font.Color = 65280
$sheet.Cells.Item(3, 7).Formula = "=SUM(E6:E1000)"
$sheet.Cells.Item(3, 7).NumberFormat = """S/."" #,##0"
$sheet.Cells.Item(3, 7).Font.Bold = $true

# --- 2. TABLA PRINCIPAL ---
$headers = @(
    "ID", "FECHA INICIO", "NOMBRE CLIENTE", "CAPITAL", "INTERES (20%)", 
    "TOTAL A PAGAR", "N CUOTAS", "CUOTA DIARIA", "FECHA FINAL", 
    "TOTAL ABONADO", "SALDO", "ESTADO", "ULTIMO PAGO"
)

for ($i = 0; $i -lt $headers.Count; $i++) {
    $col = [int]($i + 1)
    $cell = $sheet.Cells.Item(5, $col)
    $cell.Value2 = $headers[$i]
    $cell.Interior.Color = 12611584
    $cell.Font.Color = 16777215
    $cell.Font.Bold = $true
    $cell.HorizontalAlignment = -4108 # xlCenter
    $cell.Borders.Weight = 2
}

# --- 3. SEGUIMIENTO DIARIO (CRONOGRAMA HORIZONTAL) ---
$diasLetras = @("D", "L", "M", "Mi", "J", "V", "S")
$startDateHeader = Get-Date -Date "2026-02-01"
for ($i = 0; $i -le 60; $i++) {
    $date = $startDateHeader.AddDays($i)
    $col = [int](14 + $i)
    $cell = $sheet.Cells.Item(5, $col)
    
    $diaSemana = $diasLetras[[int]$date.DayOfWeek]
    $headerTxt = $date.ToString("dd-MMM") + " " + $diaSemana
    $cell.Value2 = $headerTxt
    
    if ($date.DayOfWeek -eq 0) {
        $cell.Interior.Color = 255 # Rojo
    }
    else {
        $cell.Interior.Color = 7385087 # Verde
    }
    $cell.Font.Color = 16777215
    $cell.Font.Bold = $true
    $sheet.Columns.Item($col).ColumnWidth = 10
}

# --- 4. LISTA DE DATOS (Hoja Oculta) ---
$sheetDates = $workbook.Worksheets.Add()
$sheetDates.Name = "LISTA_DATOS"
$sheetDates.Visible = 0
$listDate = Get-Date -Date "2026-01-01"
for ($i = 0; $i -lt 1461; $i++) {
    $rowIdx = [int]($i + 1)
    $d = $listDate.AddDays($i)
    $sheetDates.Cells.Item($rowIdx, 1).Value2 = "'" + $d.ToString("yyyy-MM-dd")
}
# Lista de Numeros 1-30 para las Cuotas
for ($i = 1; $i -le 30; $i++) {
    $rowIdx = [int]$i
    $sheetDates.Cells.Item($rowIdx, 2).Value2 = [int]$i
}
$sheet.Activate()

# --- 5. LOGICA DE FILAS ---
for ($row = 6; $row -le 106; $row++) {
    $r = [string]$row
    
    # ID
    $sheet.Cells.Item($row, 1).Value2 = [int]($row - 5)
    
    # FECHA INICIO
    $sheet.Cells.Item($row, 2).NumberFormat = "yyyy-mm-dd"
    $val = $sheet.Cells.Item($row, 2).Validation
    $val.Delete()
    $val.Add(3, 1, 1, '=LISTA_DATOS!$A$1:$A$1461')
    
    # CAPITAL
    $sheet.Cells.Item($row, 4).NumberFormat = """S/."" #,##0"
    
    # INTERES
    $sheet.Cells.Item($row, 5).Formula = "=IF(D$r="""","""",ROUND(D$r*0.20,0))"
    $sheet.Cells.Item($row, 5).NumberFormat = """S/."" #,##0"
    
    # TOTAL
    $sheet.Cells.Item($row, 6).Formula = "=IF(D$r="""","""",D$r+E$r)"
    $sheet.Cells.Item($row, 6).NumberFormat = """S/."" #,##0"
    
    # N CUOTAS (DROPDOWN 1-30)
    $sheet.Cells.Item($row, 7).Value2 = 6
    $valC = $sheet.Cells.Item($row, 7).Validation
    $valC.Delete()
    $valC.Add(3, 1, 1, '=LISTA_DATOS!$B$1:$B$30')
    $valC.InCellDropdown = $true
    
    # CUOTA DIARIA
    $sheet.Cells.Item($row, 8).Formula = "=IF(G$r="""","""",ROUND(F$r/G$r,0))"
    $sheet.Cells.Item($row, 8).NumberFormat = """S/."" #,##0"
    $sheet.Cells.Item($row, 8).Interior.Color = 14348258
    
    # FECHA FINAL
    $sheet.Cells.Item($row, 9).Formula = "=IF(B$r="""","""",WORKDAY.INTL(B$r,G$r,11))"
    $sheet.Cells.Item($row, 9).NumberFormat = "yyyy-mm-dd"
    
    # TOTAL ABONADO
    $sheet.Cells.Item($row, 10).Formula = "=SUM(N$r:BN$r)"
    $sheet.Cells.Item($row, 10).NumberFormat = """S/."" #,##0"
    
    # SALDO
    $sheet.Cells.Item($row, 11).Formula = "=IF(F$r="""","""",F$r-J$r)"
    $sheet.Cells.Item($row, 11).NumberFormat = """S/."" #,##0"
    
    # ESTADO (Dinamico simplificado para evitar errores de HRESULT)
    # NETWORKDAYS.INTL(Inicio, Hoy, 11) cuenta dias laborables (sin domingos)
    $fStatus = "=IF(D$r="""","""",IF(K$r<=0,""PAGADO"",IF(J$r<(NETWORKDAYS.INTL(B$r,`$D`$1,11)*H$r),""EN MORA"",""AL DIA"")))"
    # Re-limpieza de la formula para PowerShell
    $fStatus = "=IF(D" + $r + "="""","""",IF(K" + $r + "<=0,""PAGADO"",IF(J" + $r + "<(NETWORKDAYS.INTL(B" + $r + ",`$D`$1,11)*H" + $r + "),""EN MORA"",""AL DIA"")))"
    # Usando el truco de reemplazar la comilla invertida por el escape correcto
    $fStatus = $fStatus.Replace("`$D`$1", "`$D`$1") # Sin cambios, solo asegurando
    # En PowerShell, `$ se escapa como `$
    $fStatus = "=IF(D$r="""","""",IF(K$r<=0,""PAGADO"",IF(J$r<(NETWORKDAYS.INTL(B$r,`$D`$1,11)*H$r),""EN MORA"",""AL DIA"")))"
    
    $sheet.Cells.Item($row, 12).Formula = $fStatus
    
    # Bordes
    $rowRange = $sheet.Range("A$r:M$r")
    $rowRange.Borders.Weight = 2
    
    # Formato de celdas de pago
    $pagoRange = $sheet.Range("N$r:BN$r")
    $pagoRange.Borders.Weight = 2
    $pagoRange.NumberFormat = "#,##0"
}

# Ajustes finales
$sheet.Columns.Item(3).ColumnWidth = 25 # Nombre
$sheet.Columns.Item(12).ColumnWidth = 15 # Estado

# Guardar
$path = "d:\RecoverAI\Sistema_Prestamos\Sistema_Prestamos_V4_Final.xlsx"
$workbook.SaveAs($path)
$workbook.Close()
$excel.Quit()

# Limpieza
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($sheet) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
[System.GC]::Collect()

Write-Host "Sistema V4 Finalizado en: $path"
