#!/bin/bash

echo "=== SQL Server Setup Script for Linux ==="
echo "This script will install and configure SQL Server 2022 for your Job Portal application"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "This script should not be run as root for security reasons."
   echo "Please run as a regular user with sudo privileges."
   exit 1
fi

# Update system
echo "Step 1: Updating system packages..."
sudo apt-get update -y

# Install prerequisites
echo "Step 2: Installing prerequisites..."
sudo apt-get install -y wget curl gnupg2

# Import Microsoft GPG key
echo "Step 3: Adding Microsoft repository..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

# Add SQL Server repository
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2022.list)" -y

# Update package list
sudo apt-get update -y

# Install SQL Server
echo "Step 4: Installing SQL Server 2022..."
sudo apt-get install -y mssql-server

# Configure SQL Server
echo "Step 5: Configuring SQL Server..."
echo "Please follow the prompts:"
echo "1. Choose Edition 2 (Developer - free)"
echo "2. Accept license terms"
echo "3. Set SA password: YourPassword123"
echo ""
sudo /opt/mssql/bin/mssql-conf setup

# Install SQL Server tools
echo "Step 6: Installing SQL Server command line tools..."
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
sudo apt-get update -y
sudo ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev

# Add tools to PATH
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc

# Start and enable SQL Server service
echo "Step 7: Starting SQL Server service..."
sudo systemctl start mssql-server
sudo systemctl enable mssql-server

# Check service status
echo "Step 8: Checking SQL Server status..."
sudo systemctl status mssql-server --no-pager

# Configure firewall
echo "Step 9: Configuring firewall..."
sudo ufw allow 1433/tcp

# Create database
echo "Step 10: Creating jobportal database..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourPassword123' -Q "CREATE DATABASE jobportal;"

# Verify database creation
echo "Step 11: Verifying database creation..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourPassword123' -Q "SELECT name FROM sys.databases WHERE name = 'jobportal';"

echo ""
echo "=== Setup Complete! ==="
echo "SQL Server is now installed and configured."
echo "Database: jobportal"
echo "Username: sa"
echo "Password: YourPassword123"
echo "Port: 1433"
echo ""
echo "To start your Java application, run:"
echo "./mvnw spring-boot:run"
echo ""
echo "To connect from SSMS (Windows), use:"
echo "Server: $(hostname -I | awk '{print $1}'),1433"
echo "Authentication: SQL Server Authentication"
echo "Login: sa"
echo "Password: YourPassword123"