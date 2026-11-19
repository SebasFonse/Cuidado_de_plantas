# Imagen del backend Quarkus para desplegar en Vercel (Container Runtime).
# Vercel construye este archivo en cada push y envía el tráfico al puerto $PORT.

# 1) Compilación con Maven (sin pruebas: ya corren en GitHub Actions)
FROM maven:3.9-eclipse-temurin-25 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -q package -DskipTests

# 2) Imagen final solo con el JRE y la aplicación
FROM eclipse-temurin:25-jre
WORKDIR /app
COPY --from=build /app/target/quarkus-app/ ./

# Vercel espera el puerto 80 por defecto. En el contenedor no se escriben logs a archivo.
ENV PORT=80 \
    QUARKUS_LOG_FILE_ENABLED=false \
    JAVA_OPTS="-XX:MaxRAMPercentage=75"
EXPOSE 80

CMD ["sh", "-c", "java $JAVA_OPTS -jar quarkus-run.jar"]
