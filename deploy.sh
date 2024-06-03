#!/bin/bash

#Install all packeges
sudo apt update 
sudo apt install docker.io

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt install docker-compose

#Enable docker and start 
sudo systemctl enable docker
sudo systemctl start docker

cd app
#Creating Dockerfile
sudo cat <<EOF | sudo tee -a Dockerfile
FROM node:latest

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "app.js"]
EOF

#Creating nginx configuration
sudo cat <<EOF | sudo tee -a nginx.conf
events {}

http {
    server {
        listen 80;
        server_name 19d73b6fe42c.mylabserver.com;

        location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    }
}
EOF

#Creating docker compose file
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
            - ./certbot/www/:/var/www/certbot/:ro
    certbot:
        image: certbot/certbot:latest
        volumes:
        - ./certbot/www/:/var/www/certbot/:rw
        - ./certbot/conf/:/etc/letsencrypt/:rw

networks:
    app_network:
        driver: bridge
EOF

sudo docker-compose up