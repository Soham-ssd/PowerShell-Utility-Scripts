#On each target server, ensure that PowerShell Remoting is enabled
#Enable-PSRemoting -Force
#Create a text file (servers.txt) with the names or IPs of the servers you want to run the script on, one per line.

#Replace C:\Path\To\DiskUsageAnalyzer.ps1 with the actual path to the script.
#Update the target directory (C:\TargetDirectory) and MinSize as needed.
#Use a shared location for the export path, or aggregate locally and then move the file to the desired location.
#Invoke-Command -ComputerName $Server -Credential (Get-Credential) -ScriptBlock { ... }

# Script block to execute DiskUsageAnalyzer.ps1 on a target server
-ScriptBlock {
    param ($RemoteScriptPath, $Directory, $MinSize)

    # Load the script
    if (-Not (Test-Path $RemoteScriptPath)) {
        throw "Script file not found at $RemoteScriptPath"
    }
    . $RemoteScriptPath

    # Execute the script function
    DiskUsageAnalyzer -Directory $Directory -MinSize $MinSize
}



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
