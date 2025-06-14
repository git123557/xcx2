# 第一阶段：编译代码
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY *.java ./
RUN mvn clean package -DskipTests

# 第二阶段：运行程序（添加证书处理）
FROM openjdk:17-jdk-slim
WORKDIR /app

# 安装证书更新工具（确保基础镜像有必要的工具）
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 创建证书目录（如果不存在）
RUN mkdir -p /app/cert

# 复制证书文件（如果有）
COPY --from=build /app/cert/certificate.crt /app/cert/  # 如果有证书，从第一阶段复制

# 提前更新 CA 证书（构建时执行，而非运行时）
COPY --from=build /app/cert/certificate.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# 复制 JAR 文件
COPY --from=build /app/target/*-jar-with-dependencies.jar app.jar

EXPOSE 8080

# 移除原启动脚本，直接运行应用（避免运行时再次执行证书更新）
CMD ["java", "-jar", "app.jar"]
