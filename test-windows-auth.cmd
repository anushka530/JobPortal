@echo off
echo === Testing SQL Server Windows Authentication ===
echo.

echo 1. Checking SQL Server service status...
sc query MSSQLSERVER | findstr STATE
echo.

echo 2. Testing SQL Server connection with Windows Authentication...
sqlcmd -S localhost -E -Q "SELECT @@VERSION" -W
echo.

echo 3. Checking if jobportal database exists...
sqlcmd -S localhost -E -Q "SELECT name FROM sys.databases WHERE name = 'jobportal'" -W
echo.

echo 4. If database doesn't exist, creating it...
sqlcmd -S localhost -E -Q "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'jobportal') CREATE DATABASE jobportal" -W
echo.

echo 5. Testing jobportal database access...
sqlcmd -S localhost -E -d jobportal -Q "SELECT DB_NAME() AS CurrentDatabase" -W
echo.

echo 6. Checking current Windows user...
echo Current user: %USERNAME%
echo Domain: %USERDOMAIN%
echo.

echo 7. Your SSMS connection details:
echo Server name: localhost (or . or (local))
echo Authentication: Windows Authentication
echo Database: jobportal
echo.

echo 8. Testing Java application prerequisites...
if exist "mvnw.cmd" (
    echo Maven wrapper found. You can now run:
    echo mvnw.cmd clean install
    echo mvnw.cmd spring-boot:run
) else (
    echo Maven wrapper not found in current directory
)
echo.

echo === Test Complete ===
pause