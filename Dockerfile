
# 第一阶段：编译代码（使用 Maven 镜像，包含编译环境）
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app

# 1. 复制 pom.xml 并缓存依赖（改代码不重复下载依赖，加速构建）
COPY pom.xml .
RUN mvn dependency:go-offline

# 2. 复制 Java 源码文件（当前目录所有 .java 文件）
COPY *.java ./

# 3. 编译代码（跳过测试，适合部署环境）
RUN mvn clean compile assembly:single -DskipTests

# 第二阶段：运行程序（使用轻量 OpenJDK 镜像，减小最终镜像体积）
FROM openjdk:17-jdk-slim
WORKDIR /app

# 从编译阶段复制打包好的 JAR 文件（根据实际生成的 JAR 名称调整，或用通配符）
COPY --from=build /app/target/*.jar app.jar

# 暴露端口（如果你的 Java 程序启动后监听 8080，就填 8080；按需修改）
EXPOSE 8080

# 启动命令（直接运行 JAR 包，需确保 pom.xml 中配置了 mainClass）
CMD ["java", "-jar", "app.jar"]
