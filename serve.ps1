param(
    [int]$Port = 8080,
    [string]$Root = $PSScriptRoot
)

$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$Port/"
$listener.Prefixes.Add($prefix)

$mimeTypes = @{
    ".html"  = "text/html; charset=utf-8"
    ".htm"   = "text/html; charset=utf-8"
    ".css"   = "text/css; charset=utf-8"
    ".js"    = "application/javascript; charset=utf-8"
    ".json"  = "application/json; charset=utf-8"
    ".png"   = "image/png"
    ".jpg"   = "image/jpeg"
    ".jpeg"  = "image/jpeg"
    ".gif"   = "image/gif"
    ".svg"   = "image/svg+xml"
    ".mp3"   = "audio/mpeg"
    ".wav"   = "audio/wav"
    ".ogg"   = "audio/ogg"
    ".ico"   = "image/x-icon"
    ".woff"  = "font/woff"
    ".woff2" = "font/woff2"
    ".ttf"   = "font/ttf"
}

try {
    $listener.Start()
    Write-Host "Local server listening at $prefix"
    Write-Host "Root folder: $Root"

    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $req = $context.Request
        $res = $context.Response

        try {
            $res.Headers.Add("Access-Control-Allow-Origin", "*")

            $rawPath = $req.RawUrl.Split('?')[0]
            if ($rawPath -eq "/" -or [string]::IsNullOrEmpty($rawPath)) {
                $rawPath = "/index.html"
            }
            $cleanRelPath = [System.Uri]::UnescapeDataString($rawPath.TrimStart('/').Replace('/', [System.IO.Path]::DirectorySeparatorChar))
            $filePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($Root, $cleanRelPath))

            if ($filePath.StartsWith($Root) -and [System.IO.File]::Exists($filePath)) {
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                if ($mimeTypes.ContainsKey($ext)) {
                    $res.ContentType = $mimeTypes[$ext]
                } else {
                    $res.ContentType = "application/octet-stream"
                }
                $res.Headers.Add("Accept-Ranges", "bytes")

                $fileInfo = New-Object System.IO.FileInfo($filePath)
                $totalLength = $fileInfo.Length

                $rangeHeader = $req.Headers["Range"]
                if ($rangeHeader -and $rangeHeader.StartsWith("bytes=")) {
                    $parts = $rangeHeader.Substring(6).Split('-')
                    $start = 0L
                    $end = $totalLength - 1

                    if (-not [string]::IsNullOrEmpty($parts[0])) {
                        [int64]::TryParse($parts[0], [ref]$start) | Out-Null
                    }
                    if ($parts.Length -gt 1 -and -not [string]::IsNullOrEmpty($parts[1])) {
                        [int64]::TryParse($parts[1], [ref]$end) | Out-Null
                    }

                    if ($start -ge $totalLength) {
                        $res.StatusCode = 416
                        $res.Headers.Add("Content-Range", "bytes */$totalLength")
                        $res.Close()
                        continue
                    }

                    if ($end -ge $totalLength) { $end = $totalLength - 1 }
                    $contentLength = $end - $start + 1

                    $res.StatusCode = 206
                    $res.Headers.Add("Content-Range", "bytes $start-$end/$totalLength")
                    $res.ContentLength64 = $contentLength

                    $fs = [System.IO.File]::OpenRead($filePath)
                    try {
                        $fs.Seek($start, [System.IO.SeekOrigin]::Begin) | Out-Null
                        $buffer = New-Object byte[] 65536
                        $bytesRemaining = $contentLength
                        while ($bytesRemaining -gt 0) {
                            $bytesToRead = [Math]::Min($buffer.Length, $bytesRemaining)
                            $bytesRead = $fs.Read($buffer, 0, $bytesToRead)
                            if ($bytesRead -le 0) { break }
                            $res.OutputStream.Write($buffer, 0, $bytesRead)
                            $bytesRemaining -= $bytesRead
                        }
                    } finally {
                        $fs.Dispose()
                    }
                } else {
                    $res.StatusCode = 200
                    $res.ContentLength64 = $totalLength
                    $fs = [System.IO.File]::OpenRead($filePath)
                    try {
                        $fs.CopyTo($res.OutputStream)
                    } finally {
                        $fs.Dispose()
                    }
                }
            } else {
                $res.StatusCode = 404
                $errBytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $rawPath")
                $res.ContentLength64 = $errBytes.Length
                $res.OutputStream.Write($errBytes, 0, $errBytes.Length)
            }
        } catch {
            # Client disconnected or error writing
        } finally {
            try { $res.Close() } catch {}
        }
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
