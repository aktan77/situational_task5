# Project README

## Overview

This project sets up a Node.js application running in a Docker container, served by Nginx, also running in a Docker container. The configuration is managed using Docker Compose.

## Prerequisites

Before running the setup script, ensure you have the following installed on your system:
- Node.js
- npm
- Docker
- Docker Compose

## Setup Instructions

### 1. Install Necessary Packages

The following commands will install the required packages and update the system:

```bash
npm install

sudo apt update
sudo apt install docker.io

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt install docker-compose
```

### 2. Enable and Start Docker Service

Enable and start the Docker service:

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

### 3. Create the Dockerfile

Navigate to the `app` directory and create the `Dockerfile`:

```bash
cd app
sudo cat <<EOF | sudo tee -a Dockerfile
FROM node:latest

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "app.js"]
EOF
```

### 4. Create Nginx Configuration

Create the `nginx.conf` file:

```bash
sudo cat <<EOF | sudo tee -a nginx.conf
events {}

http {
    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://web:3000;
            # proxy_set_header Host \$host;
            # proxy_set_header X-Real-IP \$remote_addr;
            # proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            # proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOF
```

### 5. Create Docker Compose File

Create the `docker-compose.yml` file:

```bash
sudo cat <<EOF | sudo tee -a docker-compose.yml
services:
    web:
        build:
            context: .
            dockerfile: Dockerfile
        ports:
            - "3000:3000"
        networks:
            - app_network
    nginx: 
        image: nginx:latest
        ports: 
            - "80:80"
        volumes: 
            - ./nginx.conf:/etc/nginx/nginx.conf
        depends_on:
            - web
        networks:
            - app_network
    #         - ./certbot/www/:/var/www/certbot/:ro
    # certbot:
    #     image: certbot/certbot:latest
    #     volumes:
    #         - ./certbot/www/:/var/www/certbot/:rw
    #         - ./certbot/conf/:/etc/letsencrypt/:rw

networks:
    app_network:
        driver: bridge
EOF
```

### 6. Start the Application

Start the application using Docker Compose:

```bash
sudo docker-compose up
```

This command will build and run the Node.js application and Nginx server, making your application accessible at `http://localhost`.

## Conclusion

You now have a Node.js application running in a Docker container and served by Nginx, also running in a Docker container. You can modify the configuration files as needed to suit your project's requirements.