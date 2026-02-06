# Script PowerShell para crear Sistema de Prestamos V5 (PREMIUM - Version Estable)
# Diseño Profesional, Status Automático, Salto de Domingos, Cuotas 1-30.

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$workbook = $excel.Workbooks.Add()

# Colores (BGR Format for Excel COM)
$colorHeaderBg = 3289650
$colorSilver = 12632256
$colorGold = 52479
$colorWhite = 16777215
$colorGreen = 5287936
$colorRed = 255
$colorBlue = 12611584
$colorYellow = 65535

# ==========================================
# HOJA 1: SISTEMA_PRESTAMOS_V5
# ==========================================
$sheet = $workbook.Worksheets.Item(1)
$sheet.Name = "SISTEMA_V5_PREMIUM"

# --- 1. DASHBOARD SUPERIOR ---
$headerRange = $sheet.Range("A1:AZ4")
$headerRange.Interior.Color = $colorHeaderBg

# Titulo
$sheet.Cells.Item(1, 1).Value2 = "      CONTABILIDAD "
$sheet.Cells.Item(1, 1).Font.Size = 22
$sheet.Cells.Item(1, 1).Font.Bold = $true
$sheet.Cells.Item(1, 1).Font.Color = $colorWhite

# Fecha Actual
$sheet.Cells.Item(2, 2).Value2 = "FECHA DE HOY (SISTEMA):"
$sheet.Cells.Item(2, 2).Font.Color = $colorWhite
$sheet.Cells.Item(2, 2).Font.Bold = $true
$todayCell = $sheet.Cells.Item(2, 4)
$todayCell.Value2 = (Get-Date).ToString("yyyy-MM-dd")
$todayCell.NumberFormat = "yyyy-mm-dd"
$todayCell.Interior.Color = $colorYellow
$todayCell.Font.Bold = $true

# Totales
$sheet.Cells.Item(1, 7).Value2 = "CAPITAL TOTAL"
$sheet.Cells.Item(1, 7).Font.Color = $colorSilver
$sheet.Cells.Item(2, 7).Formula = '=SUM(D6:D1000)'
$sheet.Cells.Item(2, 7).NumberFormat = '"S/." #,##0'
$sheet.Cells.Item(2, 7).Font.Size = 14
$sheet.Cells.Item(2, 7).Font.Bold = $true
$sheet.Cells.Item(2, 7).Font.Color = $colorWhite

$sheet.Cells.Item(1, 9).Value2 = "GANANCIA ESPERADA"
$sheet.Cells.Item(1, 9).Font.Color = $colorSilver
$sheet.Cells.Item(2, 9).Formula = '=SUM(E6:E1000)'
$sheet.Cells.Item(2, 9).NumberFormat = '"S/." #,##0'
$sheet.Cells.Item(2, 9).Font.Size = 14
$sheet.Cells.Item(2, 9).Font.Bold = $true
$sheet.Cells.Item(2, 9).Font.Color = $colorGold

# --- 2. ENCABEZADOS TABLA ---
$headers = @(
    "ID", "FECHA INICIO", "CLIENTE", "CAPITAL", "INTERES", 
    "TOTAL", "CUOTAS", "VALOR DIA", "FECHA FIN", 
    "TOTAL ABONADO", "SALDO", "ESTADO", "DIAS MORA"
)

for ($i = 0; $i -lt $headers.Count; $i++) {
    $col = [int]($i + 1)
    $cell = $sheet.Cells.Item(5, $col)
    $cell.Value2 = $headers[$i]
    $cell.Interior.Color = $colorBlue
    $cell.Font.Color = $colorWhite
    $cell.Font.Bold = $true
    $cell.HorizontalAlignment = -4108
    $cell.Borders.Weight = 2
}

# --- 3. CRONOGRAMA HORIZONTAL ---
$diasLetras = @("D", "L", "M", "Mi", "J", "V", "S")
$stHeader = Get-Date -Date "2026-02-01"
for ($i = 0; $i -le 60; $i++) {
    $dt = $stHeader.AddDays($i)
    $col = [int](14 + $i)
    $cell = $sheet.Cells.Item(5, $col)
    
    $diaS = $diasLetras[[int]$dt.DayOfWeek]
    $cell.Value2 = $dt.ToString("dd-MMM") + " " + $diaS
    
    if ($dt.DayOfWeek -eq 0) {
        $cell.Interior.Color = $colorRed
    } else {
        $cell.Interior.Color = $colorGreen
    }
    $cell.Font.Color = $colorWhite
    $cell.Font.Bold = $true
    $cell.Font.Size = 8
    $sheet.Columns.Item($col).ColumnWidth = 8
}

# --- 4. DATOS OCULTOS ---
$sheetD = $workbook.Worksheets.Add()
$sheetD.Name = "LISTA_V5"
$sheetD.Visible = 0
$lDate = Get-Date -Date "2026-01-01"
for ($i = 0; $i -lt 1461; $i++) {
    $sheetD.Cells.Item($i + 1, 1).Value2 = "'" + $lDate.AddDays($i).ToString("yyyy-MM-dd")
}
for ($i = 1; $i -le 30; $i++) {
    $sheetD.Cells.Item($i, 2).Value2 = [int]$i
}
$sheet.Activate()

# --- 5. FILAS ---
for ($row = 6; $row -le 106; $row++) {
    $rs = [string]$row
    
    $sheet.Cells.Item($row, 1).Value2 = [int]($row - 5)
    
    # Dropdown Fecha
    $sheet.Cells.Item($row, 2).NumberFormat = "yyyy-mm-dd"
    $v1 = $sheet.Cells.Item($row, 2).Validation
    $v1.Delete()
    $v1.Add(3, 1, 1, '=LISTA_V5!$A$1:$A$1461')
    
    # Capital
    $sheet.Cells.Item($row, 4).NumberFormat = '"S/." #,##0'
    
    # Interes
    $sheet.Cells.Item($row, 5).Formula = '=IF(D' + $rs + '="","",ROUND(D' + $rs + '*0.20,0))'
    $sheet.Cells.Item($row, 5).NumberFormat = '"S/." #,##0'
    
    # Total
    $sheet.Cells.Item($row, 6).Formula = '=IF(D' + $rs + '="","",D' + $rs + '+E' + $rs + ')'
    $sheet.Cells.Item($row, 6).NumberFormat = '"S/." #,##0'
    
    # Dropdown Cuotas
    $sheet.Cells.Item($row, 7).Value2 = 6
    $v2 = $sheet.Cells.Item($row, 7).Validation
    $v2.Delete()
    $v2.Add(3, 1, 1, '=LISTA_V5!$B$1:$B$30')
    $v2.InCellDropdown = $true
    
    # Cuota Dia
    $sheet.Cells.Item($row, 8).Formula = '=IF(G' + $rs + '="","",ROUND(F' + $rs + '/G' + $rs + ',0))'
    $sheet.Cells.Item($row, 8).NumberFormat = '"S/." #,##0'
    $sheet.Cells.Item($row, 8).Interior.Color = 14348258
    
    # Fecha Fin
    $sheet.Cells.Item($row, 9).Formula = '=IF(B' + $rs + '="","",WORKDAY.INTL(B' + $rs + ',G' + $rs + ',11))'
    $sheet.Cells.Item($row, 9).NumberFormat = "yyyy-mm-dd"
    
    # Abonado
    $sheet.Cells.Item($row, 10).Formula = '=SUM(N' + $rs + ':BN' + $rs + ')'
    $sheet.Cells.Item($row, 10).NumberFormat = '"S/." #,##0'
    
    # Saldo
    $sheet.Cells.Item($row, 11).Formula = '=IF(F' + $rs + '="","",F' + $rs + '-J' + $rs + ')'
    $sheet.Cells.Item($row, 11).NumberFormat = '"S/." #,##0'
    
    # Dias de mora (Dinamico: Lo que deberian pagar vs lo que han pagado)
    # NETWORKDAYS.INTL(B, D2, 11) son los dias que han pasado.
    # J/H son las cuotas pagadas.
    $sheet.Cells.Item($row, 13).Formula = '=IF(OR(D' + $rs + '="",B' + $rs + '=""),"",MAX(0,NETWORKDAYS.INTL(B' + $rs + ',$D$2,11) - ROUND(J' + $rs + '/H' + $rs + ',0)))'
    
    # Estado (Formula mejorada sin emojis para evitar problemas de encoding)
    $f = '=IF(OR(D' + $rs + '="",B' + $rs + '=""),"",IF(K' + $rs + '<=0,"PAGADO",IF(M' + $rs + '<=0,"AL DIA",IF(M' + $rs + '<=1,"PENDIENTE","EN MORA"))))'
    $sheet.Cells.Item($row, 12).Formula = $f
    
    # Estilo Fila
    $sheet.Range("A" + $rs + ":M" + $rs).Borders.Weight = 2
}

# --- 6. FORMATO CONDICIONAL ---
$statRange = $sheet.Range("L6:L106")
# Mora
$c1 = $statRange.FormatConditions.Add(1, 3, '="EN MORA"')
$c1.Font.Color = $colorRed
$c1.Font.Bold = $true
# Pendiente
$c2 = $statRange.FormatConditions.Add(1, 3, '="PENDIENTE"')
$c2.Font.Color = 16744448
$c2.Font.Bold = $true
# Al dia
$c3 = $statRange.FormatConditions.Add(1, 3, '="AL DIA"')
$c3.Font.Color = $colorGreen
$c3.Font.Bold = $true
# Pagado
$c4 = $statRange.FormatConditions.Add(1, 3, '="PAGADO"')
$c4.Font.Color = $colorBlue
$c4.Font.Bold = $true

# Paneles
$sheet.Activate()
$sheet.Cells.Item(6, 14).Select()
$excel.ActiveWindow.FreezePanes = $true

# Guardar
$oPath = "d:\RecoverAI\Sistema_Prestamos\Sistema_Prestamos_V5_Premium.xlsx"
$workbook.SaveAs($oPath)
$workbook.Close()
$excel.Quit()

Write-Host "V5 Premium Creado Exitosamente: $oPath"
