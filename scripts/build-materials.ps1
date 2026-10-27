$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root 'materials\mt-01'
$destination = Join-Path $root 'docs\downloads\mt-01.zip'
$files = @(
    'START-HERE.md'
    'input\meeting-notes.md'
    'output\README.md'
)

Add-Type -AssemblyName System.IO.Compression
$stream = [System.IO.MemoryStream]::new()
try {
    $archive = [System.IO.Compression.ZipArchive]::new(
        $stream, [System.IO.Compression.ZipArchiveMode]::Create, $true
    )
    try {
        foreach ($file in $files) {
            $content = [System.IO.File]::ReadAllBytes((Join-Path $source $file))
            $entryName = 'mt-01/' + $file.Replace('\', '/')
            $entry = $archive.CreateEntry($entryName)
            $entryStream = $entry.Open()
            try {
                $entryStream.Write($content, 0, $content.Length)
            } finally {
                $entryStream.Dispose()
            }
        }
    } finally {
        $archive.Dispose()
    }
    [System.IO.Directory]::CreateDirectory((Split-Path -Parent $destination)) | Out-Null
    [System.IO.File]::WriteAllBytes($destination, $stream.ToArray())
} finally {
    $stream.Dispose()
}
Write-Output "Created $destination"
