#Compilacion
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder

# area de trabajo
WORKDIR /app

# optimizacion copiando el pom
COPY pom.xml .

# descargar dependencias
RUN mvn dependency:go-offline -B

# copiamos codigo
COPY src ./src

# compila y empaqueta creamos jar omitimos pruebas unitarias
RUN mvn clean package -DskipTests

# ejecucion
FROM eclipse-temurin:21-jre-alpine AS runtime

# area de trabajo
WORKDIR /app

# creamos usuario no privileguiado
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# copiamos el jar
COPY --from=builder /app/target/*.jar app.jar

# asignamos permisos
RUN chown -R appuser:appgroup /app

#cambiamos de usuario
USER appuser


#puerto de exposicion
EXPOSE 8080

# Parámetros optimizados para la JVM en entornos de contenedores
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Punto de entrada de ejecución del contenedor
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"] 