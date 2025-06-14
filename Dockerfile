# 第一阶段：编译代码
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY *.java ./
RUN mvn clean package -DskipTests

# 第二阶段：运行程序（移除证书处理逻辑）
FROM openjdk:17-jdk-slim
WORKDIR /app

# 安装必要工具（保留证书工具，但无需更新）
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 复制JAR文件（仅保留必要操作）
COPY --from=build /app/target/*-jar-with-dependencies.jar app.jar

EXPOSE 8080

# 直接运行应用
CMD ["java", "-jar", "app.jar"]
