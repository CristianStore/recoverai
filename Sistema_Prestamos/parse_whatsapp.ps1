
# Force UTF-8 for console output to see characters correctly
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$rawData = Get-Content "d:\RecoverAI\Sistema_Prestamos\raw_whatsapp_data.txt" -Encoding UTF8
$uniqueEntries = @()
$parsedStrings = @()

foreach ($line in $rawData) {
    # Regex pattern to extract relevant fields
    # Matches: [Timestamp stuff] CARTA: (Date) (Name) (Amount) (?:a )?(Days) d.as (dot matches accent or not)
    if ($line -match "CARTA:\s*(\d{2}/\d{2}/\d{2})\s+(.+?)\s+(\d+)\s*(?:a\s*)?(\d+)\s*d.as") {
        $dateStr = $matches[1]
        $name = $matches[2].Trim()
        $amount = $matches[3]
        $days = $matches[4]

        # Convert date from dd/MM/yy to yyyy-MM-dd
        $dateParts = $dateStr -split "/"
        $day = $dateParts[0]
        $month = $dateParts[1]
        $year = "20" + $dateParts[2]
        $formattedDate = "$year-$month-$day"

        # Special case correction for Susan Tekello
        if ($name -match "Susan Tekello" -and $days -eq "24" -and $dateStr -eq "02/02/26") {
            $days = "20"
        }

        # Create a unique key for deduplication
        $key = "$formattedDate|$name|$amount|$days"
        
        if ($uniqueEntries -notcontains $key) {
            $uniqueEntries += $key
            # Use single quotes for name to avoid variable expansion issues
            $parsedStrings += "    @(`"$formattedDate`", `"$name`", $amount, $days),"
        }
    }
}

Write-Host "`$loansData = @("
$parsedStrings | ForEach-Object { Write-Host $_ }
Write-Host ")"
