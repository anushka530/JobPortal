# SQL Server Setup with Windows Authentication

## Prerequisites
- Windows operating system
- SQL Server installed locally
- SQL Server Management Studio (SSMS)
- Java application running on the same Windows machine

## Step 1: Configure SQL Server for Windows Authentication

### 1.1 Open SQL Server Management Studio (SSMS)
- Connect to your local SQL Server instance
- Server name: `localhost` or `(local)` or `.`
- Authentication: Windows Authentication

### 1.2 Create the jobportal database
```sql
-- Connect to SQL Server and run this query
CREATE DATABASE jobportal;
GO

USE jobportal;
GO

-- Verify database creation
SELECT name FROM sys.databases WHERE name = 'jobportal';
```

### 1.3 Grant permissions to your Windows user (if needed)
```sql
-- Add your Windows user to the database (replace DOMAIN\username with your actual user)
USE jobportal;
GO

CREATE USER [DOMAIN\username] FOR LOGIN [DOMAIN\username];
GO

-- Grant necessary permissions
ALTER ROLE db_owner ADD MEMBER [DOMAIN\username];
GO
```

## Step 2: Download SQL Server Authentication Library

### Option A: Manual Download
1. Download `mssql-jdbc_auth-12.4.2.x64.dll` from Microsoft
2. Place it in one of these locations:
   - `C:\Windows\System32\`
   - Your Java application's working directory
   - A directory in your system PATH

### Option B: Automatic (using Maven)
The dependency is already added to your `pom.xml` file, but you may need to extract the DLL:

```bash
# The DLL will be automatically extracted when you run the application
./mvnw clean install
```

## Step 3: Configure Your Application

Your `application.properties` is already configured for Windows Authentication:

```properties
# SQL Server Configuration with Windows Authentication
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=jobportal;integratedSecurity=true;trustServerCertificate=true
spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver

# JPA/Hibernate Configuration for SQL Server
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.SQLServerDialect
spring.jpa.properties.hibernate.format_sql=true
```

## Step 4: Test the Connection

### 4.1 Test SQL Server Connection
Open Command Prompt or PowerShell and test:
```cmd
sqlcmd -S localhost -E -Q "SELECT @@VERSION"
```

### 4.2 Test Database Access
```cmd
sqlcmd -S localhost -E -d jobportal -Q "SELECT DB_NAME() AS CurrentDatabase"
```

## Step 5: Run Your Java Application

```bash
# Clean and build the project
./mvnw clean install

# Run the application
./mvnw spring-boot:run
```

## Step 6: Verify Connection in SSMS

1. Open SQL Server Management Studio
2. Connect using Windows Authentication
3. Navigate to `Databases` → `jobportal`
4. You should see the tables created by Hibernate/JPA

## Alternative Connection Strings

If you have issues, try these alternative connection strings in `application.properties`:

### Option 1: Default instance
```properties
spring.datasource.url=jdbc:sqlserver://localhost;databaseName=jobportal;integratedSecurity=true;trustServerCertificate=true
```

### Option 2: Named instance
```properties
spring.datasource.url=jdbc:sqlserver://localhost\\SQLEXPRESS;databaseName=jobportal;integratedSecurity=true;trustServerCertificate=true
```

### Option 3: Explicit port
```properties
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=jobportal;integratedSecurity=true;trustServerCertificate=true
```

## Troubleshooting

### Common Issues:

1. **"This driver is not configured for integrated authentication"**
   - Solution: Ensure `mssql-jdbc_auth-12.4.2.x64.dll` is in your system PATH or Java library path

2. **"Login failed for user"**
   - Solution: Ensure your Windows user has access to SQL Server and the jobportal database

3. **"Cannot create SSPI context"**
   - Solution: Check Windows firewall and ensure SQL Server is running

4. **"Database 'jobportal' does not exist"**
   - Solution: Create the database manually in SSMS

### Verification Commands:

```cmd
# Check SQL Server service status
sc query MSSQLSERVER

# Check if port 1433 is listening
netstat -an | findstr 1433

# Test connection with sqlcmd
sqlcmd -S localhost -E -Q "SELECT @@SERVERNAME, @@VERSION"
```

## Security Notes

- Windows Authentication is more secure than SQL Authentication
- Your application will run under the context of the Windows user
- Ensure the Windows user has minimal required permissions
- Consider using a dedicated service account for production deployments