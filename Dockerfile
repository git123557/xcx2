# 第一阶段：编译代码
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY *.java ./
RUN mvn clean package -DskipTests

# 第二阶段：运行程序
FROM openjdk:17-jdk-slim
WORKDIR /app
# 复制打包好的 JAR（根据实际生成的文件名调整）
COPY --from=build /app/target/*-jar-with-dependencies.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
