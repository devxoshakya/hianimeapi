# HiAnime API - Docker Setup

This guide explains how to run the HiAnime API using Docker.

## Prerequisites

- Docker installed on your system
- Docker Compose (optional, for easier management)

## Environment Variables

Create a `.env` file in the root directory with your configuration:

```env
NODE_ENV=production
PORT=3030
ORIGIN=*
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_LIMIT=100
# Add other environment variables as needed
```

## Building and Running

### Option 1: Using Docker Compose (Recommended)

```bash
# Build and start the container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

### Option 2: Using Docker Commands

```bash
# Build the image
docker build -t hianime-api .

# Run the container
docker run -d \
  --name hianime-api \
  -p 3030:3030 \
  --env-file .env \
  hianime-api

# View logs
docker logs -f hianime-api

# Stop the container
docker stop hianime-api
docker rm hianime-api
```

## Health Check

The container includes a health check that monitors the application status. You can check the health status using:

```bash
docker inspect --format='{{.State.Health.Status}}' hianime-api
```

## API Endpoints

Once running, the API will be available at:

- **Base URL**: `http://localhost:3030`
- **Documentation**: `http://localhost:3030/api/v1`
- **Swagger UI**: `http://localhost:3030/ui`
- **Health Check**: `http://localhost:3030/ping`

## Development

For development with hot reload, you can mount the source code:

```bash
docker run -d \
  --name hianime-api-dev \
  -p 3030:3030 \
  -v $(pwd):/app \
  --env-file .env \
  hianime-api \
  bun run dev
```

## Troubleshooting

### Common Issues

1. **Port already in use**: Change the port mapping in docker-compose.yml or use a different host port
2. **Permission denied**: Ensure Docker has proper permissions and the bunuser has access to the app directory
3. **Environment variables**: Make sure all required environment variables are set in your `.env` file

### Useful Commands

```bash
# View container logs
docker-compose logs hianime-api

# Execute commands inside the container
docker-compose exec hianime-api bash

# Rebuild the image
docker-compose build --no-cache

# Remove all containers and images
docker-compose down --rmi all
```

## Docker Hub Deployment

### Pushing to Docker Hub

To push your image to Docker Hub for public or private distribution:

#### 1. Login to Docker Hub

```bash
docker login
```

Enter your Docker Hub username and password when prompted.

#### 2. Build and Tag the Image

```bash
# Build the image with your Docker Hub username
docker build -t your-username/hianime-api:latest .

# Or tag an existing image
docker tag hianime-api your-username/hianime-api:latest

# Optional: Create version tags
docker tag your-username/hianime-api:latest your-username/hianime-api:v1.0.0
```

#### 3. Push to Docker Hub

```bash
# Push latest version
docker push your-username/hianime-api:latest

# Push specific version (if tagged)
docker push your-username/hianime-api:v1.0.0
```

#### 4. Using the Published Image

Once published, others can use your image:

```bash
# Pull and run the image
docker run -d \
  --name hianime-api \
  -p 3030:3030 \
  -e NODE_ENV=production \
  your-username/hianime-api:latest
```

Or update your `docker-compose.yml`:

```yaml
services:
  hianime-api:
    image: your-username/hianime-api:latest  # Instead of build context
    container_name: hianime-api
    # ... rest of the configuration
```

#### 5. Automated Builds (Optional)

For automated builds, you can:

1. **GitHub Actions**: Set up CI/CD to automatically build and push on commits
2. **Docker Hub Automated Builds**: Connect your GitHub repository to Docker Hub

Example GitHub Actions workflow (`.github/workflows/docker.yml`):

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push
      uses: docker/build-push-action@v4
      with:
        push: true
        tags: your-username/hianime-api:latest
```

### 6. Cloud Run Deployment

For Google Cloud Run deployment:

#### Prerequisites
- Install Google Cloud SDK: `gcloud` CLI
- Authenticate: `gcloud auth login`
- Set project: `gcloud config set project YOUR_PROJECT_ID`

#### Deploy to Cloud Run

```bash
# Build and push to Google Container Registry
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/hianime-api

# Deploy to Cloud Run
gcloud run deploy hianime-api \
  --image gcr.io/YOUR_PROJECT_ID/hianime-api \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080 \
  --set-env-vars NODE_ENV=production
```

#### Or using Docker Hub image:

```bash
# Deploy from Docker Hub
gcloud run deploy hianime-api \
  --image your-username/hianime-api:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080 \
  --set-env-vars NODE_ENV=production,PORT=8080
```

#### Important Notes for Cloud Run:
- The app now listens on `PORT` environment variable (defaults to 8080 for Cloud Run)
- Health check endpoint is available at `/ping`
- The container starts within the allocated timeout
- Cloud Run automatically handles HTTPS and scaling

## Production Deployment

For production deployment, consider:

1. Setting appropriate environment variables
2. Using a reverse proxy (nginx, Traefik)
3. Setting up proper logging and monitoring
4. Configuring resource limits
5. Using Docker secrets for sensitive data
6. Using specific version tags instead of `latest` for stability

## Security Notes

- The container runs as a non-root user (`bunuser`) for security
- Sensitive files are excluded via `.dockerignore`
- Environment variables should be used for configuration
- Consider using Docker secrets for production deployments
