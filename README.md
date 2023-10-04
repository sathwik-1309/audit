# Docker

## Start containers

### Rails
    docker run -d -p 3001:3001 audit-rails:v1

### React
    docker run -d -e VITE_HOST=localhost -e VITE_PORT=5173 -p 5173:5173 audit-react:v1

### Redis
    docker run --name some-redis -p 6379:6379 -d redis

### Postgres
    docker run -e POSTGRES_USER=sathwik -e POSTGRES_PASSWORD=sath139 -p 5432:5432 -d postgres:latest

