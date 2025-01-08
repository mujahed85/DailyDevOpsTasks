#!/bin/bash

# Step 1: Generate a Maven Project using Archetype
echo "Generating Maven Project..."
mvn archetype:generate -DgroupId=com.example.helloworld \
                       -DartifactId=helloworld \
                       -Dversion=1.0-SNAPSHOT \
                       -DarchetypeArtifactId=maven-archetype-quickstart \
                       -DinteractiveMode=false

# Navigate into the project directory
cd helloworld

# Step 2: Modify the pom.xml to include Spring Boot dependencies
echo "Modifying pom.xml..."

cat <<EOL > pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">

    <modelVersion>4.0.0</modelVersion>

    <!-- Spring Boot Parent -->
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.7.7</version>
    </parent>

    <groupId>com.example.helloworld</groupId>
    <artifactId>helloworld</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>jar</packaging>
    <name>helloworld</name>
    <url>http://maven.apache.org</url>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>3.8.1</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>

</project>
EOL

# Step 3: Modify the App.java to create a web endpoint
echo "Modifying App.java..."

cat <<EOL > src/main/java/com/example/helloworld/DemoApplication.java
package com.example.helloworld;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class DemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

    @GetMapping("/")
    public String helloWorld() {
        return "Hello, World!";
    }
}
EOL

# Step 4: Build the project
echo "Building the project..."
mvn clean package

# Step 5: Run the Spring Boot application
echo "Running the Spring Boot application..."
java -jar target/helloworld-1.0-SNAPSHOT.jar

echo "Application is running on http://localhost:8080"

