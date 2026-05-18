# =========================
# Stage 1: Builder
# =========================
FROM golang:1.24.13-alpine3.21 AS builder

WORKDIR /app

# Install git
RUN apk add --no-cache git

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build application
RUN CGO_ENABLED=0 GOOS=linux go build -a -o skillpulse .

# =========================
# Stage 2: Runtime
# =========================
FROM alpine:3.21

WORKDIR /app

# Install certificates
RUN apk --no-cache add ca-certificates

# Copy binary from builder
COPY --from=builder /app/skillpulse .

EXPOSE 8080

CMD ["./skillpulse"]
