# Docker Containers

## Container - List the containers details

```bash
# List all containers
docker container ls

# List all containers, including stopped containers
docker container ls -a

# List all containers, including stopped containers, and show additional details
docker container ls -l

# List only the container IDs
docker container ls -q
```

```bash
# Create a new container
docker container create --name <container-name> <image-name>

# Start a stopped container
docker container start <container-id>

# Run a new container = create + start
docker container run --name <container-name> <image-name>

# Stop a running container
docker container stop <container-id>

# Remove a stopped container
docker container rm <container-id>
```

---
