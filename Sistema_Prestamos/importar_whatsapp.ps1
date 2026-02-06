# Script PowerShell para crear Sistema de Prestamos V5 (PREMIUM) + DATA IMPORTADA
# Características: Diseño Profesional, Status Automático, DATA DE WHATSAPP CARGADA.

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$workbook = $excel.Workbooks.Add()

# Colores (BGR)
$colorHeaderBg = 3289650
$colorSilver = 12632256
$colorGold = 52479
$colorWhite = 16777215
$colorGreen = 5287936
$colorRed = 255
$colorBlue = 12611584
$colorYellow = 65535

$sheet = $workbook.Worksheets.Item(1)
$sheet.Name = "CONTABILIDAD"

# --- 1. DASHBOARD SUPERIOR ---
$headerRange = $sheet.Range("A1:AZ4")
$headerRange.Interior.Color = $colorHeaderBg

$sheet.Cells.Item(1, 1).Value2 = "      CONTABILIDAD - GESTOR PREMIUM "
$sheet.Cells.Item(1, 1).Font.Size = 22
$sheet.Cells.Item(1, 1).Font.Bold = $true
$sheet.Cells.Item(1, 1).Font.Color = $colorWhite

$sheet.Cells.Item(2, 2).Value2 = "FECHA DE HOY:"
$sheet.Cells.Item(2, 2).Font.Color = $colorWhite
$todayCell = $sheet.Cells.Item(2, 4)
$todayCell.Value2 = (Get-Date).ToString("yyyy-MM-dd") # Cambiado a Hoy Real
$todayCell.NumberFormat = "yyyy-mm-dd"
$todayCell.Interior.Color = $colorYellow

$sheet.Cells.Item(1, 7).Value2 = "CAPITAL TOTAL"
$sheet.Cells.Item(1, 7).Font.Color = $colorSilver
$sheet.Cells.Item(2, 7).Formula = '=SUM(D6:D1000)'
$sheet.Cells.Item(2, 7).NumberFormat = '"S/. "#,##0'
$sheet.Cells.Item(2, 7).Font.Size = 14
$sheet.Cells.Item(2, 7).Font.Bold = $true
$sheet.Cells.Item(2, 7).Font.Color = $colorWhite

$sheet.Cells.Item(1, 9).Value2 = "GANANCIA TOTAL"
$sheet.Cells.Item(1, 9).Font.Color = $colorSilver
$sheet.Cells.Item(2, 9).Formula = '=SUM(E6:E1000)'
$sheet.Cells.Item(2, 9).NumberFormat = '"S/. "#,##0'
$sheet.Cells.Item(2, 9).Font.Size = 14
$sheet.Cells.Item(2, 9).Font.Bold = $true
$sheet.Cells.Item(2, 9).Font.Color = $colorGold

# --- 2. ENCABEZADOS ---
$headers = @("ID", "FECHA INICIO", "CLIENTE", "CAPITAL", "INTERES", "TOTAL", "CUOTAS", "VALOR DIA", "FECHA FIN", "TOTAL ABONADO", "SALDO", "ESTADO", "DIAS MORA")
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
$sheet.Range("A5:M5").AutoFilter()

# --- 3. CRONOGRAMA HORIZONTAL ---
$diasLetras = @("D", "L", "M", "Mi", "J", "V", "S")
$stHeader = Get-Date -Date "2026-01-01"
for ($i = 0; $i -le 100; $i++) {
    $dt = $stHeader.AddDays($i)
    $col = [int](14 + $i)
    $cell = $sheet.Cells.Item(5, $col)
    $cell.Value2 = $dt.ToString("dd-MMM") + " " + $diasLetras[[int]$dt.DayOfWeek]
    if ($dt.DayOfWeek -eq 0) { $cell.Interior.Color = $colorRed } else { $cell.Interior.Color = $colorGreen }
    $cell.Font.Color = $colorWhite
    $cell.Font.Bold = $true
    $cell.Font.Size = 8
    $sheet.Columns.Item($col).ColumnWidth = 8
}

# --- 4. DATA IMPORTADA (WhatsApp) ---
# Formato: @("Fecha", "Nombre", Amount, Cuotas)
$loansData = @(
    @("2026-02-02", "Laine Pérez", 1000, 20),
    @("2026-01-16", "Laine Pérez", 400, 20),
    @("2026-02-02", "Juan Velasquez", 200, 24),
    @("2026-01-30", "Juan", 1000, 24),
    @("2026-01-27", "Juan", 500, 24),
    @("2026-01-24", "Juan", 400, 24),
    @("2026-01-19", "Juan", 500, 24),
    @("2026-02-02", "Marlene torrez", 400, 24),
    @("2026-02-02", "Lorena Matas", 500, 24),
    @("2026-01-29", "Lorena", 400, 24),
    @("2026-01-28", "Lorena", 100, 24),
    @("2026-01-22", "Lorena", 100, 24),
    @("2026-01-23", "Lorena", 600, 24),
    @("2026-02-02", "Samir Olivares", 400, 24),
    @("2026-02-02", "Esposa", 1000, 24),
    @("2026-02-02", "chachito", 300, 24),
    @("2026-01-15", "chachito", 300, 24),
    @("2026-01-13", "Zuñiga", 600, 24),
    @("2026-01-14", "Jesús Arrieche", 200, 24),
    @("2026-01-22", "Jesús", 300, 24),
    @("2026-02-02", "Jessica Espinosa", 1000, 20),
    @("2026-02-02", "Raul Landaeta", 200, 24),
    @("2026-02-02", "Ismenia Villareal", 1200, 24),
    @("2026-02-02", "Maribel Palacios", 400, 24),
    @("2026-01-27", "Maribel Palacios", 600, 24),
    @("2026-01-21", "Maribel Palacios", 600, 24),
    @("2026-01-13", "Kevin Ramírez", 300, 24),
    @("2026-01-29", "Crosty", 200, 24),
    @("2026-01-12", "Crosty", 100, 24),
    @("2026-01-20", "Crosty", 200, 24),
    @("2026-01-13", "Génesis", 600, 24),
    @("2026-01-09", "Génesis", 300, 24),
    @("2026-02-02", "Susan Tekello", 700, 20),
    @("2026-01-23", "Susan Tekello", 200, 20),
    @("2026-01-16", "Rocio Flores", 600, 20),
    @("2026-01-24", "Rocío Florez", 800, 20),
    @("2026-01-30", "Pablo", 400, 20),
    @("2026-01-31", "Félix solorsano", 300, 24),
    @("2026-01-27", "Feliz", 200, 24),
    @("2026-01-16", "Feliz", 200, 24),
    @("2026-01-22", "Feliz", 300, 24),
    @("2026-02-03", "Zuñiga", 500, 24)
)

# Hoja de soporte
$sheetL = $workbook.Worksheets.Add()
$sheetL.Name = "LISTA_SISTEMA"
$sheetL.Visible = 0
$ld = Get-Date -Date "2026-01-01"
for ($i = 0; $i -lt 1461; $i++) { $sheetL.Cells.Item($i + 1, 1).Value2 = "'" + $ld.AddDays($i).ToString("yyyy-MM-dd") }
for ($i = 1; $i -le 30; $i++) { $sheetL.Cells.Item($i, 2).Value2 = [int]$i }
$sheet.Activate()

for ($row = 6; $row -le (5 + $loansData.Count + 50); $row++) {
    $rs = [string]$row
    $idx = $row - 6
    $sheet.Cells.Item($row, 1).Value2 = [int]($row - 5)
    
    # Llenar data si existe
    if ($idx -lt $loansData.Count) {
        # Parse date and add 1 day
        $dateStr = $loansData[$idx][0]
        $dateObj = Get-Date -Date $dateStr
        $newDate = $dateObj.AddDays(1)

        $sheet.Cells.Item($row, 2).Value2 = $newDate.ToString("yyyy-MM-dd")
        $sheet.Cells.Item($row, 3).Value2 = $loansData[$idx][1]
        $sheet.Cells.Item($row, 4).Value2 = [double]$loansData[$idx][2]
        $sheet.Cells.Item($row, 7).Value2 = [double]$loansData[$idx][3]
    }
    else {
        $sheet.Cells.Item($row, 7).Value2 = 6
    }
    
    # Validaciones y Formulas
    $sheet.Cells.Item($row, 2).NumberFormat = "yyyy-mm-dd"
    $v1 = $sheet.Cells.Item($row, 2).Validation
    $v1.Delete(); $v1.Add(3, 1, 1, '=LISTA_SISTEMA!$A$1:$A$1461')
    
    $sheet.Cells.Item($row, 4).NumberFormat = '"S/. "#,##0'
    $sheet.Cells.Item($row, 5).Formula = '=IF(D' + $rs + '="","",ROUND(D' + $rs + '*0.20,0))'
    $sheet.Cells.Item($row, 5).NumberFormat = '"S/. "#,##0'
    $sheet.Cells.Item($row, 6).Formula = '=IF(D' + $rs + '="","",D' + $rs + '+E' + $rs + ')'
    $sheet.Cells.Item($row, 6).NumberFormat = '"S/. "#,##0'
    
    $v2 = $sheet.Cells.Item($row, 7).Validation
    $v2.Delete(); $v2.Add(3, 1, 1, '=LISTA_SISTEMA!$B$1:$B$30'); $v2.InCellDropdown = $true
    
    $sheet.Cells.Item($row, 8).Formula = '=IF(G' + $rs + '="","",ROUND(F' + $rs + '/G' + $rs + ',0))'
    $sheet.Cells.Item($row, 8).NumberFormat = '"S/. "#,##0'
    $sheet.Cells.Item($row, 8).Interior.Color = 14348258
    
    $sheet.Cells.Item($row, 9).Formula = '=IF(B' + $rs + '="","",WORKDAY.INTL(B' + $rs + ',G' + $rs + ',11))'
    $sheet.Cells.Item($row, 9).NumberFormat = "yyyy-mm-dd"
    
    $sheet.Cells.Item($row, 10).Formula = '=SUM(N' + $rs + ':CZ' + $rs + ')'
    $sheet.Cells.Item($row, 10).NumberFormat = '"S/. "#,##0'
    
    $sheet.Cells.Item($row, 11).Formula = '=IF(F' + $rs + '="","",F' + $rs + '-J' + $rs + ')'
    $sheet.Cells.Item($row, 11).NumberFormat = '"S/. "#,##0'
    
    $sheet.Cells.Item($row, 13).Formula = '=IF(OR(D' + $rs + '="",B' + $rs + '=""),"",MAX(0,NETWORKDAYS.INTL(B' + $rs + ',$D$2,11) - ROUND(J' + $rs + '/H' + $rs + ',0)))'
    
    $sheet.Cells.Item($row, 12).Formula = '=IF(OR(D' + $rs + '="",B' + $rs + '=""),"",IF(K' + $rs + '<=0,"PAGADO",IF(M' + $rs + '<=0,"AL DIA",IF(M' + $rs + '<=1,"PENDIENTE","EN MORA"))))'
    
    $sheet.Range("A" + $rs + ":M" + $rs).Borders.Weight = 2

    # --- SIMULACION DE PAGOS (AL DIA) ---
    if ($idx -lt $loansData.Count) {
        $dailyVal = [Math]::Round(([double]$loansData[$idx][2] * 1.20) / [double]$loansData[$idx][3])
        $simStartDate = $newDate
        $simEndDate = Get-Date # Today
        $simRefDate = Get-Date -Date "2026-01-01"

        while ($simStartDate -lt $simEndDate) {
            if ($simStartDate.DayOfWeek -ne 'Sunday') {
                $pDays = ($simStartDate - $simRefDate).Days
                $pCol = 14 + $pDays
                # Ensure column is within our header range (approx 100 days generated)
                if ($pCol -ge 14 -and $pCol -le 114) {
                    $sheet.Cells.Item($row, $pCol).Value2 = [string]$dailyVal
                    $sheet.Cells.Item($row, $pCol).NumberFormat = '"S/. "#,##0'
                }
            }
            $simStartDate = $simStartDate.AddDays(1)
        }
    }
}

# Formato Condicional
$statRange = $sheet.Range("L6:L1000")
$c1 = $statRange.FormatConditions.Add(1, 3, '="EN MORA"'); $c1.Font.Color = $colorRed; $c1.Font.Bold = $true
$c2 = $statRange.FormatConditions.Add(1, 3, '="PENDIENTE"'); $c2.Font.Color = 16744448; $c2.Font.Bold = $true
$c3 = $statRange.FormatConditions.Add(1, 3, '="AL DIA"'); $c3.Font.Color = $colorGreen; $c3.Font.Bold = $true
$c4 = $statRange.FormatConditions.Add(1, 3, '="PAGADO"'); $c4.Font.Color = $colorBlue; $c4.Font.Bold = $true

$sheet.Activate(); $sheet.Cells.Item(6, 14).Select(); $excel.ActiveWindow.FreezePanes = $true
$sheet.Columns.Item(3).ColumnWidth = 25
$sheet.Columns.Item(12).ColumnWidth = 15

$finalPath = "d:\RecoverAI\Sistema_Prestamos\Sistema_Contabilidad_WhatsApp.xlsx"
$workbook.SaveAs($finalPath)
$workbook.Close(); $excel.Quit()
Write-Host "Excel con data de WhatsApp creado: $finalPath"
