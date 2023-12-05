# Set the custom sender's name and email address
$customSenderName = "Your Custom Name"
$customSenderEmail = "customname@email.com"

# Set the subject of the email
$subject = "Test Email from PowerShell"

# Read HTML content from the file
$htmlFilePath = "C:\path\to\message.html"
$htmlBody = Get-Content $htmlFilePath -Raw

# Set SMTP server details
$smtpServer = "smtp.example.com"
$smtpPort = 587
$smtpCredential = New-Object System.Management.Automation.PSCredential("username", (ConvertTo-SecureString "password" -AsPlainText -Force))

# Read email addresses from the file
$emailListPath = "C:\path\to\emailList.txt"
$emailList = Get-Content $emailListPath

# Set the throttle delay in seconds
$throttleDelaySeconds = 5  # Adjust as needed

# Create an SMTP client
$client = New-Object System.Net.Mail.SmtpClient($smtpServer, $smtpPort)

# Set the SMTP client credentials (if required)
$client.Credentials = $smtpCredential

# Enable SSL for secure email transmission
$client.EnableSsl = $true

# Iterate over each email address in the list
foreach ($recipient in $emailList) {
    # Test SMTP connection
    try {
        $client.Connect()
        Write-Output "SMTP server connected successfully."

        # Create a new email message
        $message = New-Object System.Net.Mail.MailMessage($customSenderEmail, $recipient)

        # Set the custom sender's name
        $message.From = "$customSenderName <$customSenderEmail>"

        # Set the email subject
        $message.Subject = $subject

        # Set the HTML body of the email
        $message.Body = $htmlBody
        $message.IsBodyHtml = $true  # Specify that the body is HTML-formatted

        # Send the email message
        $client.Send($message)

        Write-Output "Email sent successfully to $recipient."

    } catch {
        Write-Output "Failed to connect to SMTP server or send email to $recipient. Error: $($_.Exception.Message)"
    } finally {
        # Close the connection, whether it was successful or not
        $client.Dispose()
    }

    # Throttle: Pause script execution for the specified delay
    Start-Sleep -Seconds $throttleDelaySeconds
}
