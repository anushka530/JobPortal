#!/bin/bash

echo "=== Testing SQL Server Connection ==="
echo ""

# Test if SQL Server is running
echo "1. Checking SQL Server service status..."
sudo systemctl status mssql-server --no-pager | grep "Active:"

# Test if port 1433 is listening
echo ""
echo "2. Checking if SQL Server port 1433 is listening..."
netstat -tuln | grep 1433 || echo "Port 1433 not found - SQL Server may not be running"

# Test SQL Server connection
echo ""
echo "3. Testing SQL Server connection..."
if command -v sqlcmd &> /dev/null; then
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourPassword123' -Q "SELECT @@VERSION;" -W
    echo ""
    echo "4. Testing jobportal database..."
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourPassword123' -Q "USE jobportal; SELECT DB_NAME() AS CurrentDatabase;" -W
else
    echo "sqlcmd not found. Please install SQL Server tools first."
fi

echo ""
echo "5. Your connection details for SSMS:"
echo "Server: $(hostname -I | awk '{print $1}'),1433"
echo "Authentication: SQL Server Authentication"
echo "Login: sa"
echo "Password: YourPassword123"
echo "Database: jobportal"
echo ""

# Test Java application connectivity
echo "6. Testing Java application..."
if [ -f "mvnw" ]; then
    echo "Maven wrapper found. You can now run:"
    echo "./mvnw clean install"
    echo "./mvnw spring-boot:run"
else
    echo "Maven wrapper not found in current directory"
fi