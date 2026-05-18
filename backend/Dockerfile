# =========================
# Stage 1: Builder
# =========================
FROM golang:1.24-alpine AS builder

WORKDIR /app

# Install git
RUN apk add --no-cache git

# Copy go modules
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o skillpulse .

# =========================
# Stage 2: Runtime
# =========================
FROM alpine:3.21

WORKDIR /app

# Install certificates
RUN apk add --no-cache ca-certificates

# Copy binary
COPY --from=builder /app/skillpulse .

# Expose app port
EXPOSE 8080

# Run app
CMD ["./skillpulse"]
