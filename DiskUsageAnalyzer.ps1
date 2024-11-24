$Servers = Get-Content -Path "servers.txt"
$ExportPath = "C:\Reports\ConsolidatedDiskUsageReport.csv"
$Results = @()

foreach ($Server in $Servers) {
    Write-Host "Running analysis on server: $Server" -ForegroundColor Cyan
    
    try {
        $Output = Invoke-Command -ComputerName $Server -ScriptBlock {
            param ($Directory, $MinSize)
            # Import the script
            . C:\Path\To\DiskUsageAnalyzer.ps1
            # Call the script with parameters
            DiskUsageAnalyzer -Directory $Directory -MinSize $MinSize
        } -ArgumentList "C:\TargetDirectory", 10

        $Results += $Output
    } catch {
        Write-Warning "Failed to run analysis on server: $Server. Error: $_"
    }
}

# Export consolidated results
if ($Results) {
    $Results | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
    Write-Host "Consolidated report exported to: $ExportPath" -ForegroundColor Green
} else {
    Write-Warning "No results to export."
}
