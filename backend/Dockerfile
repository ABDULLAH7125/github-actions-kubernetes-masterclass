# =========================
# Stage 1: Builder
# =========================
FROM golang:1.25-alpine3.20 AS builder

WORKDIR /app

RUN apk add --no-cache git

COPY go.mod go.sum ./

RUN go mod tidy
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o skillpulse .

# =========================
# Stage 2: Runtime
# =========================
FROM alpine:3.20

RUN apk --no-cache add ca-certificates

WORKDIR /app

COPY --from=builder /app/skillpulse .

EXPOSE 8080

CMD ["./skillpulse"]
