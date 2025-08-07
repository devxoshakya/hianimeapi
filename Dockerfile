# Use the official Bun image
FROM oven/bun:1.2.13-slim

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and bun.lockb (if it exists) first for better caching
COPY package.json bun.lock* bunfig.toml ./

# Install dependencies
RUN bun install --frozen-lockfile

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE $PORT

# Create a non-root user for security
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 bunuser

# Change ownership of the app directory to the bunuser
RUN chown -R bunuser:nodejs /app
USER bunuser

# Set environment variables
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:${PORT:-8080}/ping || exit 1

# Start the application
CMD ["bun", "start"]
