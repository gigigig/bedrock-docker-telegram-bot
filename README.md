# bedrock-docker-telegram-bot
A Telegram Notification Service for Docker Minecraft Bedrock Servers.
Notifies upon Connection or Disconnection of Players. 
No Minecraft Plugins or Addons required. 

![Showing Connection Messages in Telegram Chat](../main/message.PNG)

## Requirements
- Minecraft Bedrock Server running in Docker
- Running Minecraft Logger Container with read access to Docker socket on the same host

## How to run
### Docker Compose using [ghcr.io image](https://github.com/users/gigigig/packages/container/package/minecrafttelegramdocker) ![Docker Build](https://github.com//gigigig/bedrock-docker-telegram-bot/actions/workflows/docker-publish.yml/badge.svg)
Define the environment variables:
 - ``` MGRAM_BOT_TOKEN "..." ``` [Create a bot](https://core.telegram.org/bots/tutorial#obtain-your-bot-token) and get the Token
 - ``` MGRAM_CHAT_ID "..." ```  Set the _chat_id_ starting with a dash "-" for the notifications output 
 - ``` MGRAM_CONTAINER_NAME "..." ``` Set the name of the Minecraft Bedrock container you want to monitor
 - Edit your docker compose file and add the logger as a new service:

```yaml
bds-logger:
    image: ghcr.io/gigigig/minecrafttelegramdocker:3.1
    environment:
      MGRAM_BOT_TOKEN: "YOUR_TOKEN"
      MGRAM_CHAT_ID: "YOUR_CHAT_ID"
      MGRAM_CONTAINER_NAME: "YOUR_CONTAINER_NAME"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
```
See [docker-compose.yml](../main/docker-compose.yml) for a full example. 

### Build with Dockerfile
```Shell
git clone https://github.com/gigigig/bedrock-docker-telegram-bot/
cd bedrock-docker-telegram-bot/
docker build .
```



