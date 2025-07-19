# SQL Server Setup Guide for Linux

## Prerequisites
- Ubuntu/Debian-based Linux system
- At least 2GB RAM
- Internet connection

## Step 1: Install SQL Server 2022 on Linux

### 1.1 Import the public repository GPG keys:
```bash
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
```

### 1.2 Register the Microsoft SQL Server Ubuntu repository:
```bash
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2022.list)"
```

### 1.3 Update package list and install SQL Server:
```bash
sudo apt-get update
sudo apt-get install -y mssql-server
```

### 1.4 Run the configuration script:
```bash
sudo /opt/mssql/bin/mssql-conf setup
```

**During setup:**
- Choose Edition: 2 (Developer - free)
- Accept license terms: Yes
- Set SA password: `YourPassword123` (must be strong - 8+ chars with uppercase, lowercase, numbers, symbols)

### 1.5 Verify SQL Server is running:
```bash
systemctl status mssql-server --no-pager
```

## Step 2: Install SQL Server Command Line Tools

### 2.1 Import the public repository GPG keys:
```bash
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
```

### 2.2 Register the Microsoft Ubuntu repository:
```bash
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
```

### 2.3 Update and install tools:
```bash
sudo apt-get update
sudo apt-get install mssql-tools unixodbc-dev
```

### 2.4 Add tools to PATH:
```bash
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
```

## Step 3: Create Database and Test Connection

### 3.1 Connect to SQL Server:
```bash
sqlcmd -S localhost -U sa -P 'YourPassword123'
```

### 3.2 Create the jobportal database:
```sql
CREATE DATABASE jobportal;
GO
USE jobportal;
GO
SELECT name FROM sys.databases;
GO
quit
```

## Step 4: Configure Firewall (if needed)
```bash
sudo ufw allow 1433/tcp
```

## Step 5: Test Java Application Connection

### 5.1 Clean and rebuild the project:
```bash
./mvnw clean install
```

### 5.2 Run the application:
```bash
./mvnw spring-boot:run
```

## Step 6: Connect with SQL Server Management Studio (SSMS)

Since you're on Linux, you'll need to use SSMS from a Windows machine or VM. Here's how:

### Option A: Using SSMS from Windows
1. Install SQL Server Management Studio on Windows
2. Connect to: `your-linux-ip-address,1433`
3. Authentication: SQL Server Authentication
4. Login: sa
5. Password: YourPassword123

### Option B: Alternative - Azure Data Studio (Linux Native)
```bash
# Download and install Azure Data Studio for Linux
wget https://go.microsoft.com/fwlink/?linkid=2215791 -O azuredatastudio-linux.deb
sudo dpkg -i azuredatastudio-linux.deb
sudo apt-get install -f
```

## Troubleshooting

### If connection fails:
1. Check SQL Server status: `systemctl status mssql-server`
2. Check if port 1433 is listening: `netstat -tuln | grep 1433`
3. Check firewall: `sudo ufw status`
4. Verify SA account: `sqlcmd -S localhost -U sa -P 'YourPassword123'`

### Common Issues:
- **Password too weak**: Must contain uppercase, lowercase, numbers, and symbols
- **Port blocked**: Ensure firewall allows port 1433
- **Service not running**: `sudo systemctl start mssql-server`