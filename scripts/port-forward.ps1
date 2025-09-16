# 🔗 Port Forwarding Script for Puchi Development

param(
    [switch]$Stop
)

$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Reset = "`e[0m"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = $Reset
    )
    Write-Host "${Color}${Message}${Reset}"
}

function Stop-PortForwarding {
    Write-ColorOutput "🛑 Stopping port forwarding..." $Yellow
    
    # Stop kubectl port-forward processes
    Get-Process | Where-Object { $_.ProcessName -eq "kubectl" -and $_.CommandLine -like "*port-forward*" } | Stop-Process -Force -ErrorAction SilentlyContinue
    
    Write-ColorOutput "✅ Port forwarding stopped" $Green
}

function Start-PortForwarding {
    Write-ColorOutput "🔗 Starting port forwarding..." $Blue
    
    # Stop any existing port forwarding
    Stop-PortForwarding
    
    Write-ColorOutput "Starting port forwarding for development access:" $Yellow
    Write-ColorOutput "- Frontend: http://localhost:3000" $Yellow
    Write-ColorOutput "- User Service: http://localhost:8080" $Yellow
    Write-ColorOutput "- PostgreSQL: localhost:5432" $Yellow
    Write-Host ""
    
    # Start port forwarding in background jobs
    Start-Job -ScriptBlock { kubectl port-forward service/puchi-fe 3000:80 -n puchi-dev } -Name "frontend-port-forward"
    Start-Job -ScriptBlock { kubectl port-forward service/user-service 8080:8080 -n puchi-dev } -Name "user-service-port-forward"
    Start-Job -ScriptBlock { kubectl port-forward service/postgres 5432:5432 -n puchi-dev } -Name "postgres-port-forward"
    
    # Wait a moment for port forwarding to start
    Start-Sleep -Seconds 3
    
    Write-ColorOutput "✅ Port forwarding started" $Green
    Write-Host ""
    Write-ColorOutput "🌐 Services available at:" $Blue
    Write-ColorOutput "- Frontend: http://localhost:3000" $Green
    Write-ColorOutput "- User Service: http://localhost:8080" $Green
    Write-ColorOutput "- PostgreSQL: localhost:5432" $Green
    Write-Host ""
    Write-ColorOutput "Press Ctrl+C to stop port forwarding" $Yellow
    
    # Keep script running and monitor jobs
    try {
        while ($true) {
            Start-Sleep -Seconds 5
            
            # Check if any job failed
            $failedJobs = Get-Job | Where-Object { $_.State -eq "Failed" }
            if ($failedJobs) {
                Write-ColorOutput "❌ Some port forwarding jobs failed:" $Red
                $failedJobs | ForEach-Object { Write-ColorOutput "  - $($_.Name)" $Red }
                break
            }
        }
    }
    catch {
        Write-ColorOutput "`n🛑 Stopping port forwarding..." $Yellow
        Stop-PortForwarding
    }
}

function Show-Status {
    $jobs = Get-Job | Where-Object { $_.Name -like "*port-forward*" }
    
    if ($jobs.Count -eq 0) {
        Write-ColorOutput "📋 No port forwarding jobs running" $Yellow
        return
    }
    
    Write-ColorOutput "📋 Port forwarding status:" $Blue
    foreach ($job in $jobs) {
        $status = switch ($job.State) {
            "Running" { $Green + "✅ Running" + $Reset }
            "Failed" { $Red + "❌ Failed" + $Reset }
            "Completed" { $Yellow + "⏹️ Completed" + $Reset }
            default { $Yellow + "❓ $($job.State)" + $Reset }
        }
        Write-Host "  - $($job.Name): $status"
    }
}

# Main execution
if ($Stop) {
    Stop-PortForwarding
}
else {
    Start-PortForwarding
}

# Cleanup function
function Cleanup {
    Stop-PortForwarding
    Get-Job | Where-Object { $_.Name -like "*port-forward*" } | Remove-Job -Force
}

# Register cleanup on script exit
Register-EngineEvent PowerShell.Exiting -Action { Cleanup }
