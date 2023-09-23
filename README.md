# Docker

## Start containers

### Rails
    docker run -d -p 3001:3001 audit-rails:v1

### React
    docker run -d -e VITE_HOST=localhost -e VITE_PORT=5173 -p 5173:5173 audit-react:v1

### Redis
    docker run --name some-redis -p 6379:6379 -d redis

