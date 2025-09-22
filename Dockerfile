# Stage 1: Build stage
FROM node:18-alpine as build

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install all dependencies (including devDependencies needed for build)
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the application (env vars will be baked into the build)
RUN npm run build

# Stage 2: Production stage
FROM node:18-alpine as production

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json for production dependencies
COPY package*.json ./

# Install only production dependencies and vite for preview
RUN npm ci --only=production && npm install vite

# Copy the built application from the build stage
COPY --from=build /app/dist ./dist

# Copy necessary config files for preview server
COPY --from=build /app/vite.config.js ./

# Expose port 5173 (Vite preview default port)
EXPOSE 5173

# Start the Vite preview server to serve the built application
CMD ["npx", "vite", "preview", "--host", "0.0.0.0", "--port", "5173"]