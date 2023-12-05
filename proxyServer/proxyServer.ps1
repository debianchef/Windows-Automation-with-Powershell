# Define the proxy server details
$proxyAddress = "http://127.0.0.1:8080/"

# Create an HttpListener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($proxyAddress)

# Start the listener
$listener.Start()

Write-Output "Proxy server started at $proxyAddress"

# Handle incoming requests
while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    # Log the request
    Write-Output "Request received:"
    Write-Output "  Method: $($request.HttpMethod)"
    Write-Output "  URL: $($request.Url)"
    Write-Output "  Headers:"
    $request.Headers.AllKeys | ForEach-Object { Write-Output "    $_: $($request.Headers.Get($_))" }

    # Example: Modify the request (optional)
    # You can modify the request here if needed.

    # Create a web request to the original destination
    $targetUri = $request.Url
    $targetRequest = [System.Net.HttpWebRequest]::Create($targetUri)
    $targetRequest.Method = $request.HttpMethod

    # Copy headers from the original request to the target request
    foreach ($headerKey in $request.Headers.AllKeys) {
        $targetRequest.Headers.Add($headerKey, $request.Headers.GetValues($headerKey))
    }

    # Get the target response
    $targetResponse = $targetRequest.GetResponse()

    # Copy headers from the target response to the proxy response
    foreach ($headerKey in $targetResponse.Headers.AllKeys) {
        $response.Headers.Add($headerKey, $targetResponse.Headers.GetValues($headerKey))
    }

    # Copy the response stream from the target response to the proxy response
    $targetResponse.GetResponseStream().CopyTo($response.OutputStream)

    # Close the responses
    $targetResponse.Close()
    $response.Close()
}

# Stop the listener when done
$listener.Stop()
