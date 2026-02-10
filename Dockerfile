# Stage 1: Build the Flutter Web App
FROM debian:bookworm-slim AS build-env

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    gdb \
    libstdc++6 \
    libglu1-mesa \
    fonts-droid-fallback \
    lib32stdc++6 \
    python3 \
    && apt-get clean

# Clone Flutter (pinned to stable channel)
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter \
    && cd /usr/local/flutter \
    && git checkout stable

# Set flutter path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor to verify setup
RUN flutter doctor

# Enable web support
RUN flutter config --enable-web

# Copy project files into container
COPY . /app
WORKDIR /app

# Get dependencies
RUN flutter pub get

# Build Flutter web release
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:1.25-alpine

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy only the built web files from Stage 1
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy custom nginx config (handles Flutter routing)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx in foreground (required for Docker)
CMD ["nginx", "-g", "daemon off;"]