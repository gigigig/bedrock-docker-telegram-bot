<#
.SYNOPSIS
    Docker Minecraft Bedrock Server Player Notifications to Telegram
    Github: https://github.com/gigigig/bedrock-docker-telegram-bot
.DESCRIPTION
    This script monitors the Docker logs of a specified Minecraft container and sends new player connection and disconnection events to a Telegram webhook. 
    The Telegram bot token, chat ID, and container name should be set as environment variables.

.PARAMETER MGRAM_BOT_TOKEN
    The Telegram bot token for authentication. Set as an environment variable.

.PARAMETER MGRAM_CHAT_ID
    The ID of the chat or channel where the webhook messages will be sent. Set as an environment variable.

.PARAMETER MGRAM_CONTAINER_NAME
    The name of the Docker container to retrieve logs from. Set as an environment variable.
#>

# Retrieve the Telegram bot token, chat ID, and container name from environment variables
$telegramBotToken = $env:MGRAM_BOT_TOKEN
$telegramChatId = $env:MGRAM_CHAT_ID
$containerName = $env:MGRAM_CONTAINER_NAME

Write-Verbose -Message "Listening to Container: $env:MGRAM_CONTAINER_NAME" -Verbose
Write-Verbose -Message "Posting to Chat-ID: $env:MGRAM_CHAT_ID" -Verbose
Write-Verbose -Message "Using Bot-Token (REDACTED): $($env:MGRAM_BOT_TOKEN.Substring(0,6))..." -Verbose

# Construct the Telegram webhook URL
$telegramWebhookUrl = "https://api.telegram.org/bot$($telegramBotToken)/sendMessage?chat_id=$($telegramChatId)"
$parsemode = "markdown"

# Initialize an array to store previous log entries
$previousEntries = @()

# Continuously monitor Docker logs and send new events to the Telegram webhook
while ($true) {
    Start-Sleep -Seconds 5
    # Retrieve the Docker logs of the specified container
    $dockerLogs = docker logs --tail=32 $containerName
    
    # Filter new log entries matching the specified patterns
    $newEntries = $dockerLogs | Where-Object { $_ -match "(Player connected|Player disconnected): (.+), xuid: (.+)" }
    
    # Process new entries and send them as Telegram webhooks
    foreach ($entry in $newEntries) {
        # Check if the entry has been previously sent
        if ($previousEntries -notcontains $entry) {
            # Extract the player and xuid information from the log entry
            $player = $entry -replace "(Player connected|Player disconnected): (.+), xuid: (.+)", '$2'
            $xuid = $entry -replace "(Player connected|Player disconnected): (.+), xuid: (.+)", '$3'
            
            # Determine the message based on the log entry type
            if ($entry -match "Player connected") {
                Write-Verbose -Message "Connect: $($player)" -Verbose   
                $message = "Player connected: *$($player.Substring(31))*, xuid: $($xuid.Substring(31))"
                $payload = @{
                    "chat_id"                   = $telegramChatId;
                    "text"                      = $message
                    "parse_mode"                = $parsemode; 
                }
            }
            else {
                Write-Verbose -Message "Disconnect: $($player)" -Verbose
                $message = "Player disconnected: *$($player.Substring(31))*, xuid: $($xuid.Substring(31))"
                $payload = @{
                    "chat_id"                   = $telegramChatId;
                    "text"                      = $message
                    "parse_mode"                = $parsemode;   
                }
            }
            
            # Send the message as a Telegram webhook
            $sendmgram = Invoke-RestMethod `
            -Uri ("https://api.telegram.org/bot$($telegramBotToken)/sendMessage" -f $BotToken) `
            -Method Post `
            -ContentType "application/json" `
            -Body (ConvertTo-Json -Compress -InputObject $payload) `
            -ErrorAction Stop
        if (($sendmgram.ok -eq "True")) {
            Write-Verbose -Message "Mgram did send successfully!" -Verbose
            # Add the entry to the list of previous entries
            $previousEntries += $entry
        }
        else {Write-Warning -Message "Mgram did NOT send!"}
        }
    }
}
