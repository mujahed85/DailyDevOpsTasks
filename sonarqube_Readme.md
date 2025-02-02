# Install SonarQube on Windows 11

## Prerequisites

1. **Java JDK 11 or later**:  
   SonarQube requires Java to run. Download and install the JDK if it's not already installed.  
   You can download it from [AdoptOpenJDK](https://adoptium.net/) or Oracle's website.

2. **Download SonarQube**:  
   Go to the [SonarQube Downloads page](https://www.sonarqube.org/downloads/) and download the **Community Edition** or any other version you prefer.

---

## Installation Steps

### 1. Install Java

- After downloading the JDK, run the installer.
- Set the `JAVA_HOME` environment variable to the JDK installation path:
    1. Right-click on **This PC** > **Properties** > **Advanced system settings** > **Environment Variables**.
    2. Under **System variables**, click **New**.
    3. Set the variable name as `JAVA_HOME` and value as the path to your JDK (e.g., `C:\Program Files\AdoptOpenJDK\jdk-11.0.11.9-hotspot`).
    4. Add `%JAVA_HOME%\bin` to the `Path` variable.

### 2. Install SonarQube

- Unzip the SonarQube archive to a folder (e.g., `C:\SonarQube`).
- Navigate to the extracted folder and open the `conf` directory.

### 3. Configure SonarQube

- Open the `sonar.properties` file in a text editor.
- Look for the following line and uncomment it to enable the database connection (for local development, the default H2 database should work fine).
    ```properties
    #sonar.jdbc.url=jdbc:h2:tcp://localhost:9092/sonar
    ```

### 4. Start SonarQube

- Go to the **bin** folder inside the SonarQube directory (`C:\SonarQube\bin\windows-x86-64`).
- Double-click the `StartSonar.bat` file to start SonarQube.

### 5. Access SonarQube

- Once the server starts, open a web browser and go to:
    ```
    http://localhost:9000
    ```
- The default login credentials are:
    - **Username**: `admin`
    - **Password**: `admin`

### 6. Stop SonarQube

- To stop SonarQube, go back to the `bin\windows-x86-64` folder and run the `StopSonar.bat` file.

---

## Optional: Configure SonarQube as a Windows Service

If you want SonarQube to run as a service on Windows, follow these additional steps:

1. Navigate to the `bin\windows-x86-64` folder.
2. Open a command prompt with Administrator privileges.
3. Run the following command to install SonarQube as a service:
    ```bash
    ./SonarQubeService.bat install
    ```

---

After these steps, SonarQube will be running on your Windows 11 machine!
