Add-Type -AssemblyName System.Windows.Forms

$folderPath = "C:\Program Files (x86)\RCO2"

if (Test-Path -Path $folderPath)
{
    try
    {
        Remove-Item -Path $folderPath -Recurse -Force
        Write-Output "`nThe folder $folderPath was found and has been deleted.`n"
    }
    catch
    {
        Write-Output "`nUnable to delete the folder $folderPath.`nThis means you already removed it or never had it to begin with.`n"
    }
}
else
{
    Write-Output "`nThe folder $folderPath could not be found.`nThis means you already removed it or never had it to begin with.`n"
}

$userResponse = Read-Host -Prompt "Do you want to scan the entire system for RCO2.exe and remove all instances of it? (Y/N)"

if ($userResponse -eq "Y" -or $userResponse -eq "y")
{
    Write-Host "`nScanning... please be patient. This may take several minutes and disk usage will be higher than normal.`n"
    Write-Host "`nYou can press ALT+F4 at any time to cancel the scan.`n"

    $files = Get-ChildItem -Path "C:\" -Recurse -Filter "RCO2.exe" -ErrorAction SilentlyContinue

    $count = 0

    foreach ($file in $files)
    {
        $count++

        try
        {
            Remove-Item -Path $file.FullName -Force
        }
        catch
        {
            Write-Output "`nUnable to delete the file $($file.FullName).`n"
        }
    }

    [System.Windows.Forms.MessageBox]::Show("Scan has finished. RCO2.exe is no longer on the system.`n_________________________________________________________________________`n© Knew (2023-2023)`nThis program is licensed under Boost Software License 1.0.`n_________________________________________________________________________`n`nSource: https://github.com/Knewest")
}
else
{
    [System.Windows.Forms.MessageBox]::Show("No scan was performed. RCO2.exe might still be on the system.`n_________________________________________________________________________`n`n© Knew (2023-2023)`nThis program is licensed under Boost Software License 1.0.`n_________________________________________________________________________`n`nSource: https://github.com/Knewest")
}

# Source: https://github.com/Knewest/Remove-RCO2.exe-Completely
# Copyright (Boost Software License 1.0) 2023-2023 Knew