#!/bin/bash

# Update the package lists and install Docker
sudo apt update -y
sudo apt install docker.io -y

# Start the Docker service
sudo systemctl start docker

# Enable Docker service to start on boot
sudo systemctl enable docker

# Add the default user (ubuntu) to the Docker group
sudo usermod -aG docker ubuntu

# Run the Nginx container, exposing it on port 8080
sudo docker run -p 8080:80 -d nginx:latest
