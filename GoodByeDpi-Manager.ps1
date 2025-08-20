#Requires -Version 5.1

<#
.SYNOPSIS
    GoodByeDPI Service Manager - Start/Stop DNS bypass service for Turkey
.DESCRIPTION
    This PowerShell script manages the GoodByeDPI service, providing options to:
    - Install and start the GoodByeDPI service with DNS bypass configuration
    - Stop and completely remove GoodByeDPI and related services (WinDivert)
.NOTES
    Author: PowerShell Conversion
    Version: 1.0
    Requires: Administrator privileges, Windows Service Control Manager
#>

# =============================================================================
# ADMINISTRATOR PRIVILEGE CHECK AND ELEVATION
# =============================================================================

function Test-IsAdmin {
    <#
    .SYNOPSIS
        Checks if the current PowerShell session is running with administrator privileges
    #>
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-AdminElevation {
    <#
    .SYNOPSIS
        Re-launches the script with administrator privileges
    #>
    Write-Host "`n" -ForegroundColor Yellow -NoNewline
    Write-Host "⚠️  Administrator privileges required!" -ForegroundColor Yellow
    Write-Host "   Attempting to elevate permissions..." -ForegroundColor Cyan
    
    try {
        $scriptPath = $MyInvocation.ScriptName
        if (-not $scriptPath) {
            $scriptPath = $PSCommandPath
        }
        
        Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs -Wait
        exit 0
    }
    catch {
        Write-Host "`n❌ Failed to elevate privileges: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please run this script manually as Administrator." -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# =============================================================================
# SYSTEM ARCHITECTURE DETECTION
# =============================================================================

function Get-SystemArchitecture {
    <#
    .SYNOPSIS
        Detects system architecture (x86 or x64) similar to the original batch logic
    #>
    $arch = "x86"
    
    # Check PROCESSOR_ARCHITECTURE environment variable
    if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
        $arch = "x86_64"
    }
    
    # Check PROCESSOR_ARCHITEW6432 (WOW64 scenario)
    if ($env:PROCESSOR_ARCHITEW6432) {
        $arch = "x86_64"
    }
    
    return $arch
}

# =============================================================================
# SERVICE MANAGEMENT FUNCTIONS
# =============================================================================

function Install-GoodByeDPIService {
    <#
    .SYNOPSIS
        Installs and starts the GoodByeDPI service with DNS bypass configuration
    #>
    param(
        [string]$ScriptDirectory,
        [string]$Architecture
    )
    
    Write-Host "`n" -ForegroundColor Green -NoNewline
    Write-Host "🚀 Installing GoodByeDPI Service" -ForegroundColor Green
    Write-Host ("=" * 50) -ForegroundColor Green
    
    # Define the executable path and service parameters
    $executablePath = Join-Path $ScriptDirectory "$Architecture\goodbyedpi.exe"
    $serviceArgs = "-5 --set-ttl 5 --dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253"
    $binPath = "`"$executablePath`" $serviceArgs"
    
    Write-Host "📁 Script Directory: $ScriptDirectory" -ForegroundColor Cyan
    Write-Host "🏗️  Architecture: $Architecture" -ForegroundColor Cyan
    Write-Host "📄 Executable: $executablePath" -ForegroundColor Cyan
    
    # Verify executable exists
    if (-not (Test-Path $executablePath)) {
        Write-Host "`n❌ Error: GoodByeDPI executable not found at: $executablePath" -ForegroundColor Red
        Write-Host "   Please ensure the GoodByeDPI files are in the correct directory structure." -ForegroundColor Yellow
        return $false
    }
    
    try {
        Write-Host "`n⏹️  Stopping existing GoodByeDPI service (if running)..." -ForegroundColor Yellow
        & sc.exe stop "GoodbyeDPI" 2>$null | Out-Null
        Start-Sleep -Seconds 2
        
        Write-Host "🗑️  Removing existing GoodByeDPI service (if exists)..." -ForegroundColor Yellow
        & sc.exe delete "GoodbyeDPI" 2>$null | Out-Null
        Start-Sleep -Seconds 1
        
        Write-Host "📝 Creating GoodByeDPI service..." -ForegroundColor Cyan
        $createResult = & sc.exe create "GoodbyeDPI" binPath= $binPath start= "auto"
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to create service. SC output: $createResult" -ForegroundColor Red
            return $false
        }
        
        Write-Host "📋 Setting service description..." -ForegroundColor Cyan
        & sc.exe description "GoodbyeDPI" "Turkiye icin DNS zorlamasini kaldirir." | Out-Null
        
        Write-Host "▶️  Starting GoodByeDPI service..." -ForegroundColor Green
        $startResult = & sc.exe start "GoodbyeDPI"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n✅ GoodByeDPI service successfully installed and started!" -ForegroundColor Green
            Write-Host "   The service is now running and will start automatically on system boot." -ForegroundColor Green
            Write-Host "   DNS bypass is now active for Turkey." -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "`n⚠️  Service created but failed to start. SC output: $startResult" -ForegroundColor Yellow
            Write-Host "   You may need to start it manually or check the system logs." -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "`n❌ Exception occurred while installing service: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Remove-GoodByeDPIService {
    <#
    .SYNOPSIS
        Stops and removes GoodByeDPI and related services (WinDivert)
    #>
    
    Write-Host "`n" -ForegroundColor Red -NoNewline
    Write-Host "🛑 Removing GoodByeDPI Service" -ForegroundColor Red
    Write-Host ("=" * 50) -ForegroundColor Red
    
    $servicesToRemove = @("GoodbyeDPI", "WinDivert", "WinDivert14")
    $removalSuccess = $true
    
    foreach ($serviceName in $servicesToRemove) {
        try {
            Write-Host "`n🔍 Processing service: $serviceName" -ForegroundColor Cyan
            
            # Check if service exists
            $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
            
            if ($service) {
                Write-Host "   ⏹️  Stopping service..." -ForegroundColor Yellow
                & sc.exe stop $serviceName 2>$null | Out-Null
                Start-Sleep -Seconds 2
                
                Write-Host "   🗑️  Deleting service..." -ForegroundColor Yellow
                $deleteResult = & sc.exe delete $serviceName
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "   ✅ Successfully removed $serviceName" -ForegroundColor Green
                }
                else {
                    Write-Host "   ⚠️  Warning: Could not remove $serviceName. Output: $deleteResult" -ForegroundColor Yellow
                    $removalSuccess = $false
                }
            }
            else {
                Write-Host "   ℹ️  Service $serviceName not found (already removed or never existed)" -ForegroundColor Gray
            }
        }
        catch {
            Write-Host "   ❌ Error processing $serviceName`: $($_.Exception.Message)" -ForegroundColor Red
            $removalSuccess = $false
        }
    }
    
    if ($removalSuccess) {
        Write-Host "`n✅ All GoodByeDPI services have been successfully removed!" -ForegroundColor Green
        Write-Host "   DNS bypass is now disabled." -ForegroundColor Green
    }
    else {
        Write-Host "`n⚠️  Some services could not be completely removed." -ForegroundColor Yellow
        Write-Host "   Please check Windows Services manually if needed." -ForegroundColor Yellow
    }
    
    return $removalSuccess
}

# =============================================================================
# USER INTERFACE FUNCTIONS
# =============================================================================

function Show-Header {
    <#
    .SYNOPSIS
        Displays a professional header with application information
    #>
    Clear-Host
    Write-Host "`n"
    Write-Host ("=" * 70) -ForegroundColor Cyan
    Write-Host "              GoodByeDPI Service Manager v1.0" -ForegroundColor White
    Write-Host "          DNS Bypass Service for Turkey - PowerShell Edition" -ForegroundColor Gray
    Write-Host ("=" * 70) -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    <#
    .SYNOPSIS
        Displays the interactive menu options
    #>
    Write-Host "Please select an option:" -ForegroundColor White
    Write-Host ""
    Write-Host "  [0] " -ForegroundColor Green -NoNewline
    Write-Host "Install & Start GoodByeDPI Service" -ForegroundColor White
    Write-Host "      └─ Installs DNS bypass service with Turkey-specific configuration" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [1] " -ForegroundColor Red -NoNewline
    Write-Host "Stop & Remove GoodByeDPI Service" -ForegroundColor White
    Write-Host "      └─ Completely removes GoodByeDPI and related services" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [Q] " -ForegroundColor Yellow -NoNewline
    Write-Host "Quit" -ForegroundColor White
    Write-Host ""
}

function Get-UserChoice {
    <#
    .SYNOPSIS
        Prompts user for menu selection with input validation
    #>
    do {
        Write-Host "Enter your choice (0, 1, or Q): " -ForegroundColor Cyan -NoNewline
        $choice = Read-Host
        $choice = $choice.Trim().ToUpper()
        
        if ($choice -in @("0", "1", "Q")) {
            return $choice
        }
        else {
            Write-Host "❌ Invalid choice. Please enter 0, 1, or Q." -ForegroundColor Red
        }
    } while ($true)
}

# =============================================================================
# MAIN PROGRAM LOGIC
# =============================================================================

function Main {
    <#
    .SYNOPSIS
        Main program entry point
    #>
    
    # Check for administrator privileges first
    if (-not (Test-IsAdmin)) {
        Request-AdminElevation
        return
    }
    
    # Get script directory and system architecture
    $scriptDirectory = Split-Path -Parent $MyInvocation.ScriptName
    if (-not $scriptDirectory) {
        $scriptDirectory = Split-Path -Parent $PSCommandPath
    }
    if (-not $scriptDirectory) {
        $scriptDirectory = Get-Location
    }
    
    $architecture = Get-SystemArchitecture
    
    # Main program loop
    do {
        Show-Header
        
        Write-Host "🔧 System Information:" -ForegroundColor White
        Write-Host "   📁 Working Directory: $scriptDirectory" -ForegroundColor Gray
        Write-Host "   🏗️  Architecture: $architecture" -ForegroundColor Gray
        Write-Host "   👤 Running as: Administrator" -ForegroundColor Green
        Write-Host ""
        
        Show-Menu
        $choice = Get-UserChoice
        
        switch ($choice) {
            "0" {
                $success = Install-GoodByeDPIService -ScriptDirectory $scriptDirectory -Architecture $architecture
                Write-Host ""
                Write-Host "Press any key to return to menu..." -ForegroundColor Gray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            "1" {
                $success = Remove-GoodByeDPIService
                Write-Host ""
                Write-Host "Press any key to return to menu..." -ForegroundColor Gray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            "Q" {
                Write-Host "`n👋 Exiting GoodByeDPI Service Manager..." -ForegroundColor Yellow
                Start-Sleep -Seconds 1
                return
            }
        }
    } while ($true)
}

# =============================================================================
# SCRIPT EXECUTION ENTRY POINT
# =============================================================================

# Execute main function
try {
    Main
}
catch {
    Write-Host "`n❌ An unexpected error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Gray
    Read-Host "Press Enter to exit"
    exit 1
}
finally {
    # Cleanup if needed
    Write-Host "`nScript execution completed." -ForegroundColor Gray
}
