# =========================================================================
# FitTrack - Production Multi-Stage Dockerfile for Render Deployment
# =========================================================================
# Stage 1: Build & Package application using Maven and OpenJDK 17
# Stage 2: Minimal, secure OpenJDK 17 JRE runtime with non-root execution
# =========================================================================

# -------------------------------------------------------------------------
# STAGE 1: Builder
# -------------------------------------------------------------------------
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy Maven descriptor and wrapper for layer caching
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw* ./

# Resolve dependencies in a cacheable layer
RUN mvn dependency:go-offline -B || ./mvnw dependency:go-offline -B || true

# Copy application source code
COPY src ./src

# Compile classes, package application, and collect runtime dependencies
RUN mvn clean compile dependency:copy-dependencies -DincludeScope=runtime -DskipTests

# -------------------------------------------------------------------------
# STAGE 2: Production Runtime
# -------------------------------------------------------------------------
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Create a dedicated non-root application user for container security
RUN groupadd -r fittrack && useradd -r -g fittrack -d /app -s /bin/bash fittrack

# Copy compiled classes, runtime dependencies, web assets, and resource templates
COPY --from=builder /app/target/classes ./target/classes
COPY --from=builder /app/target/dependency ./target/dependency
COPY --from=builder /app/src/main/webapp ./src/main/webapp
COPY --from=builder /app/src/main/resources ./src/main/resources

# Create working directory for embedded Tomcat work files
RUN mkdir -p target/tomcat-embed && chown -R fittrack:fittrack /app

# Switch to non-root execution
USER fittrack

# Default port (Render provides $PORT dynamically at container startup)
ENV PORT=8080
EXPOSE 8080

# Health check using the lightweight /health endpoint built into DevServer
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD curl -f http://localhost:${PORT:-8080}/health || exit 1

# Launch FitTrack Embedded Tomcat server with container-aware JVM memory tuning
ENTRYPOINT ["sh", "-c", "java -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.awt.headless=true -cp 'target/classes:target/dependency/*' com.fittrack.DevServer"]
