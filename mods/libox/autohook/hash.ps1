# Only powershell needs ts cuz it sucks
$stream = New-Object System.IO.MemoryStream
foreach ($file in $args) {
    [byte[]]$data = [System.IO.File]::ReadAllBytes($file)
    $stream.Write($data, 0, $data.Length)
}

$stream.Position = 0
$hasher = [System.Security.Cryptography.SHA256]::Create()
$hash = $hasher.ComputeHash($stream)
$stream.Dispose()

# Convert to readable hex string
$hex = -join ($hash | ForEach-Object { $_.ToString("x2") })
Write-Output $hex
