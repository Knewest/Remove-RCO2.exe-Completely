param($inputResponse)

if ($inputResponse) {
    $userResponse = $inputResponse
}

Add-Type -AssemblyName System.Windows.Forms

$scriptPath = $MyInvocation.MyCommand.Path

$isAdmin = ([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin)
{
    Write-Host "This script requires administrator privileges because 'C:\Program Files (x86)\RCO2' is locked behind permissions. `nPlease provide your password to the computer to continue. `nIf you have no password and this doesn't automatically go away, just press enter with nothing entered.`n"

    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -ArgumentList '$userResponse'" -Verb RunAs
    Exit
}

$folderPath = "C:\Program Files (x86)\RCO2"

if (Test-Path -Path $folderPath)
{
    try
    {
        $process = Get-Process -Name "RCO2" -ErrorAction SilentlyContinue
        if($process){
            $process | Stop-Process -Force
        }
        Remove-Item -Path $folderPath -Recurse -Force
        Write-Output "`nThe folder $folderPath was found and has been deleted.`n"
    }
    catch
    {
        Write-Output "`nUnable to delete the folder $folderPath. This means you already removed it or never had it to begin with.`n"
    }
}
else
{
    Write-Output "`nThe folder $folderPath could not be found. This means you already removed it or never had it to begin with.`n"
}

$userResponse = Read-Host -Prompt "Do you want to scan the entire system for RCO2.exe and remove all instances of it? (Y/N)"

$scanScriptBlock = {
    param($Path)
    $queue = New-Object System.Collections.Queue
    $scannedDirs = @{}

    $queue.Enqueue($Path)
    $scannedDirs[$Path] = $true

    while($queue.Count -gt 0) {
        $currentDir = $queue.Dequeue()
        Write-Host "Scanning directory: $currentDir"
        $items = Get-ChildItem -Path $currentDir -ErrorAction SilentlyContinue

        foreach ($item in $items) {
            if ($item.PSIsContainer -and !$scannedDirs[$item.FullName]) {
                $queue.Enqueue($item.FullName)
                $scannedDirs[$item.FullName] = $true
            } elseif ($item.Name -eq 'RCO2.exe') {
                try {
                    $process = Get-Process -Name "RCO2" -ErrorAction SilentlyContinue
                    if($process){
                        $process | Stop-Process -Force
                    }
                    Remove-Item -Path $item.FullName -Force
                }
                catch {
                    Write-Output "`nUnable to delete the file $($item.FullName)."
                }
            }
        }
    }
}

if ($userResponse -eq "Y" -or $userResponse -eq "y")
{
    Write-Host "`nScanning... please be patient. This may take several minutes and CPU/memory/disk usage will be higher than normal during the scan.`n"
    Write-Host "`nYou can press [ALT + F4] at any time to cancel the scan.`n"
    $fullCommand = '& { ' + $scanScriptBlock + ' } C:\'
    $consoleProcess = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command $fullCommand" -NoNewWindow:$false -PassThru
    $consoleProcess.WaitForExit()

    [System.Windows.Forms.MessageBox]::Show("Scan has finished. RCO2.exe is no longer on the system.`n_________________________________________________________________________`n`n© Knew (2023-2023)`nThis program is licensed under Boost Software License 1.0.`n_________________________________________________________________________`n`nSource: https://github.com/Knewest")
}
else
{
    [System.Windows.Forms.MessageBox]::Show("No scan was performed. `nRCO2.exe might still be on the system but you have removed the main RCO2 folder directory.`n_________________________________________________________________________`n`n© Knew (2023-2023)`nThis program is licensed under Boost Software License 1.0.`n_________________________________________________________________________`n`nSource: https://github.com/Knewest")
}

# Version v1.2 of Remove RCO2.exe Completely
# Source: https://github.com/Knewest/Remove-RCO2.exe-Completely
# Copyright (Boost Software License 1.0) 2023-2023 Knewparam($inputResponse)

if ($inputResponse) {
    $userResponse = $inputResponse
}

Add-Type -AssemblyName System.Windows.Forms

$scriptPath = $MyInvocation.MyCommand.Path

$isAdmin = ([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin)
{
    Write-Host "This script requires administrator privileges because 'C:\Program Files (x86)\RCO2' is locked behind permissions. `nPlease provide your password to the computer to continue. `nIf you have no password and this doesn't automatically go away, just press enter with nothing entered.`n"

    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -ArgumentList '$userResponse'" -Verb RunAs
    Exit
}

$folderPath = "C:\Program Files (x86)\RCO2"

if (Test-Path -Path $folderPath)
{
    try
    {
        $process = Get-Process -Name "RCO2" -ErrorAction SilentlyContinue
        if($process){
            $process | Stop-Process -Force
        }
        Remove-Item -Path $folderPath -Recurse -Force
        Write-Output "`nThe folder $folderPath was found and has been deleted.`n"
    }
    catch
    {
        Write-Output "`nUnable to delete the folder $folderPath. This means you already removed it or never had it to begin with.`n"
    }
}
else
{
    Write-Output "`nThe folder $folderPath could not be found. This means you already removed it or never had it to begin with.`n"
}

$userResponse = Read-Host -Prompt "Do you want to scan the entire system for RCO2.exe and remove all instances of it? (Y/N)"

$scanScriptBlock = {
    param($Path)
    $queue = New-Object System.Collections.Queue
    $scannedDirs = @{}

    $queue.Enqueue($Path)
    $scannedDirs[$Path] = $true

    while($queue.Count -gt 0) {
        $currentDir = $queue.Dequeue()
        Write-Host "Scanning directory: $currentDir"
        $items = Get-ChildItem -Path $currentDir -ErrorAction SilentlyContinue

        foreach ($item in $items) {
            if ($item.PSIsContainer -and !$scannedDirs[$item.FullName]) {
                $queue.Enqueue($item.FullName)
                $scannedDirs[$item.FullName] = $true
            } elseif ($item.Name -eq 'RCO2.exe') {
                try {
                    $process = Get-Process -Name "RCO2" -ErrorAction SilentlyContinue
                    if($process){
                        $process | Stop-Process -Force
                    }
                    Remove-Item -Path $item.FullName -Force
                }
                catch {
                    Write-Output "`nUnable to delete the file $($item.FullName)."
                }
            }
        }
    }
}

if ($userResponse -eq "Y" -or $userResponse -eq "y")
{
    Write-Host "`nScanning... please be patient. This may take several minutes and CPU/memory/disk usage will be higher than normal during the scan.`n"
    Write-Host "`nYou can press [ALT + F4] at any time to cancel the scan.`n"
    $fullCommand = '& { ' + $scanScriptBlock + ' } C:\'
    $consoleProcess = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command $fullCommand" -NoNewWindow:$false -PassThru
    $consoleProcess.WaitForExit()

    [System.Windows.Forms.MessageBox]::Show("Scan has finished. RCO2.exe is no longer on the system.`n_________________________________________________________________________`n`n© Knew (2023-2023)`nThis program is licensed under Boost Software License 1.0.`n_________________________________________________________________________`n`nSource: https://github.com/Knewest")
}
else
{
    [System.Windows.Forms.MessageBox]::Show("No scan was performed. `nRCO2.exe might still be on the system but you have removed the main RCO2 folder directory.`n_________________________________________________________________________`n`n© Knew (2023-2023)`nThis program is licensed under Boost Software License 1.0.`n_________________________________________________________________________`n`nSource: https://github.com/Knewest")
}

# Version v1.2 of Remove RCO2.exe Completely
# Source: https://github.com/Knewest/Remove-RCO2.exe-Completely
# Copyright (Boost Software License 1.0) 2023-2023 Knew
