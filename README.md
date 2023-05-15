# bedrock-docker-telegram-bot
A Telegram Notfication Service for Docker Minecraft Bedrock Servers.
Notifies upon Connection or Disconnection of Players. 
No Minecraft Plugins or Addons required. 

## Requirements
- Minecraft Bedrock Server Running in Docker with ```stdin_open: true``` and ```tty: true```
- Running Minecraft Logger Container with Write Access to Docker Socket on the same Host

## How to run
If you run your Minecraft server with docker compose you can add a new service and define the environment variables:
See [docker-compose.yml](../main/docker-compose.yml) for a full example. You can build the log-container yourself or use mine like in the example.
```
bds-logger:
    image: ghcr.io/gigigig/minecrafttelegramdocker:3.0
    environment:
      MGRAM_BOT_TOKEN: "YOUR_TOKEN"
      MGRAM_CHAT_ID: "YOUR_CHAT_ID"
      MGRAM_CONTAINER_NAME: "YOUR_CONTAINER_NAME"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```



