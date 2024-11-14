# Use the official OpenJDK image as a base image
FROM openjdk:17-jdk-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the JAR file to the container
COPY app.jar /app/app.jar

# Define the command to run the JAR file
CMD ["java", "-jar", "/app/app.jar"]
