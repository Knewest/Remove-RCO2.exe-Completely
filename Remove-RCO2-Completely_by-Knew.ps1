param($inputResponse)

if ($inputResponse) {
    $userResponse = $inputResponse
}

Add-Type -AssemblyName System.Windows.Forms

$scriptPath = $MyInvocation.MyCommand.Path

$originalColor = $Host.UI.RawUI.ForegroundColor
$Host.UI.RawUI.ForegroundColor = "Green"
Write-Host "==========================================================================="
Write-Host "|               Version v2.0 of 'Remove RCO2.exe Completely'              |"
Write-Host "|      Source: https://github.com/Knewest/Remove-RCO2.exe-Completely      |"
Write-Host "|          Copyright (Boost Software License 1.0) 2023-2023 Knew          |"
Write-Host "==========================================================================="
$Host.UI.RawUI.ForegroundColor = $originalColor

$isAdmin = ([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "This script requires administrator privileges. Attempting to restart with elevated privileges..."

    $pwshPath = (Get-Command -Name pwsh -ErrorAction SilentlyContinue).Source

    if ($pwshPath) {
        Start-Process -FilePath $pwshPath -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -ArgumentList '$userResponse'" -Verb RunAs
    } else {
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -ArgumentList '$userResponse'" -Verb RunAs
    }
    
    Exit
}

Write-Host "Attempting to stop unwanted processes..."
$processNames = @('RCO2.exe', 'RCO.exe', 'RCO2-Patch-Kit.exe')
foreach ($processName in $processNames) {
    Get-Process -Name $processName -ErrorAction SilentlyContinue | Stop-Process -Force
}

Write-Host "Checking quarantine folder..."
$quarantineFolder = 'C:\RCO-Quarantine'
if (-not (Test-Path $quarantineFolder)) {
    New-Item -Path $quarantineFolder -ItemType Directory
}

Write-Host "Moving unwanted folders to quarantine..."
$folders = @(
    'C:\RClientOptimizer',
    'C:\RClientOptimizer2',
    'C:\RCO',
    'C:\RCO2',
    "$env:APPDATA\RClientOptimizer",
    'C:\Program Files (x86)\RCO',
    'C:\Program Files (x86)\RCO2',
    'C:\Program Files\RCO',
    'C:\Program Files\RCO2'
)

foreach ($folder in $folders) {
    if (Test-Path -Path $folder) {
        try {
            Move-Item -Path $folder -Destination $quarantineFolder
            Write-Host "Moved $folder to quarantine"
        } catch {
            Write-Host "Failed to move $folder to quarantine"
        }
    }
}

$openQuarantine = Read-Host -Prompt "Do you want to view the quarantined folder? (Y/N)"
if ($openQuarantine -eq 'Y' -or $openQuarantine -eq 'y') {
    Start-Process $quarantineFolder
}

$deleteFiles = Read-Host -Prompt "Do you want to delete the quarantined files? (Y/N)"

if ($deleteFiles -eq 'Y' -or $deleteFiles -eq 'y') {
    Write-Host "Deleting quarantined files..."
    Remove-Item -Path $quarantineFolder -Recurse -Force
} else {
    Write-Host "Restoring quarantined files..."
    $quarantinedItems = Get-ChildItem -Path $quarantineFolder
    foreach ($item in $quarantinedItems) {
        Move-Item -Path $item.FullName -Destination "C:\"
    }
    Remove-Item -Path $quarantineFolder
}

Write-Host "Attempting to remove unwanted registry keys..."
$registryKeys = @(
    'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\RCO',
    'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\RCO2'
)

foreach ($key in $registryKeys) {
    if (Test-Path $key) {
        try {
            Remove-Item -Path $key -Force
            Write-Host "Removed registry key $key"
        } catch {
            Write-Host "Failed to remove registry key $key"
        }
    }
}

$removeClientSettingsResponse = Read-Host -Prompt "Do you want to remove the current fflags you have set? This will remove all the changes RCO has made to your Roblox client (if any). (Y/N)"

if ($removeClientSettingsResponse -eq 'Y' -or $removeClientSettingsResponse -eq 'y') {
    $basePaths = @(
        "$env:LOCALAPPDATA\Roblox\Versions",
        "C:\Program Files (x86)\Roblox\Versions"
    )

    foreach ($basePath in $basePaths) {
        $versionDirectories = Get-ChildItem -Path $basePath -Directory -Filter "version-*" -ErrorAction SilentlyContinue

        foreach ($versionDir in $versionDirectories) {
            $clientSettingsPath = Join-Path -Path $versionDir.FullName -ChildPath "ClientSettings"
            if (Test-Path $clientSettingsPath) {
                Remove-Item -Path $clientSettingsPath -Recurse -Force
                Write-Host "Removed directory: $clientSettingsPath"
            }
        }
    }
}

$userResponse = Read-Host -Prompt "Do you want to scan the entire system for 'RCO2.exe', 'RCO.exe', and 'RCO2-Patch-Kit.exe' and subsequently remove all instances of it? (Y/N)"

$deletedFilesLog = 'C:\Deleted-RCO2-Files-Log.txt'

if (-not (Test-Path $deletedFilesLog)) {
    New-Item -Path $deletedFilesLog -ItemType File
}

$scanScriptBlock = {
    $queue = New-Object System.Collections.Queue
    $scannedDirs = @{}
    $targetExes = @('RCO2.exe', 'RCO.exe', 'RCO2-Patch-Kit.exe')
    $drives = Get-PSDrive -PSProvider 'FileSystem'
    
    foreach ($drive in $drives) {
        $queue.Enqueue($drive.Root)
        $scannedDirs[$drive.Root] = $true
    }

    while($queue.Count -gt 0) {
        $currentDir = $queue.Dequeue()
        Write-Host "Scanning directory: $currentDir"
        $items = Get-ChildItem -Path $currentDir -ErrorAction SilentlyContinue

        foreach ($item in $items) {
            if ($item.PSIsContainer -and !$scannedDirs[$item.FullName]) {
                $queue.Enqueue($item.FullName)
                $scannedDirs[$item.FullName] = $true
            } elseif ($targetExes -contains $item.Name) {
                try {
                    $process = Get-Process -Name $item.BaseName -ErrorAction SilentlyContinue
                    if($process){
                        $process | Stop-Process -Force
                    }
                    
                    Remove-Item -Path $item.FullName -Force
                    Write-Host "Deleted file: '$($item.FullName)'"
                    "$($item.FullName)" | Out-File -Append -LiteralPath $using:deletedFilesLog
                }
                catch {
                    Write-Output "`nUnable to delete the file: '$($item.FullName)'."
                }
            }
        }
    }
}

if ($userResponse -eq "Y" -or $userResponse -eq "y")
{
    Write-Host "`nScanning... please be patient. This may take several minutes and CPU, memory, and disk usage will be higher than normal during the scan. The scan may take up to several hours (depending on the size of your system).`n"
    Write-Host "`nYou can press [ALT + F4] at any time to cancel the scan.`n"
    
    $fullCommand = '& { ' + $scanScriptBlock + ' } C:\'
    
    $pwshPath = (Get-Command -Name pwsh -ErrorAction SilentlyContinue).Source

    if ($pwshPath) {
        $consoleProcess = Start-Process -FilePath $pwshPath -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command $fullCommand" -NoNewWindow:$false -PassThru
    } else {
        $consoleProcess = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command $fullCommand" -NoNewWindow:$false -PassThru
    }

    $consoleProcess.WaitForExit()
    Start-Process $deletedFilesLog
    
    [System.Windows.Forms.MessageBox]::Show("Scan has finished. 'RCO2.exe', 'RCO.exe', and 'RCO2-Patch-Kit.exe' should no longer be on the system.`n_________________________________________________________________________`n`n© Knew (2023-2023)`nThis program is licensed under Boost Software License 1.0.`n_________________________________________________________________________`n`nSource: https://github.com/Knewest")
}
else
{
    [System.Windows.Forms.MessageBox]::Show("No scan was performed. `n'RCO2.exe', 'RCO.exe', and 'RCO2-Patch-Kit.exe' might still be on the system but you have removed the main RCO2 directories/files.`n_________________________________________________________________________`n`n© Knew (2023-2023)`nThis program is licensed under Boost Software License 1.0.`n_________________________________________________________________________`n`nSource: https://github.com/Knewest")
}


# Version v2.0 of 'Remove RCO2.exe Completely'
# Source: https://github.com/Knewest/Remove-RCO2.exe-Completely
# Copyright (Boost Software License 1.0) 2023-2023 Knew