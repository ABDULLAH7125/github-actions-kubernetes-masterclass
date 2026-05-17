# =========================
# Stage 1: Builder
# =========================
FROM golang:1.26-alpine AS builder

WORKDIR /app

# Install git (needed for private/public deps sometimes)
RUN apk add --no-cache git

# =========================
# 1. COPY ONLY DEPENDENCIES FIRST (IMPORTANT FOR CACHE)
# =========================
COPY go.mod ./
RUN go mod download

# =========================
# 2. COPY SOURCE CODE AFTER CACHE LAYER
# =========================
COPY . .

# =========================
# 3. BUILD (FAST + SMALL)
# =========================
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o skillpulse .

# =========================
# Stage 2: Runtime
# =========================
FROM alpine:3.23

RUN apk --no-cache add ca-certificates

WORKDIR /app

COPY --from=builder /app/skillpulse .

EXPOSE 8080

CMD ["./skillpulse"]
