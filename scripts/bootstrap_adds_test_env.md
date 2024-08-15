### Overview of the Topology

The script is designed to configure an Active Directory (AD) forest and domain controllers on multiple Windows servers. Here's an overview of the topology and how the script operates:

#### Topology

1. **Windows Servers**:
   - **ad01**: The first server where the AD forest is initially configured.
   - **ad02**, **ad03**, **ad04**: Additional servers that are joined to the domain and promoted as domain controllers.

2. **Control Machine**:
   - This is the machine from which the script is executed. It could be a Windows machine, a Linux machine with PowerShell Core installed, or a Docker container running PowerShell Core.

#### Script Execution

The script can be executed from various environments, including:

1. **Windows Machine**:
   - The script can be run directly on a Windows machine with administrative privileges.

2. **Linux Machine with PowerShell Core**:
   - The script can be run from a Linux machine with PowerShell Core installed. This could be a physical Linux machine, a virtual machine, or a Windows machine with Windows Subsystem for Linux (WSL) and PowerShell Core installed.

3. **Docker Container**:
   - The script can be run from a Docker container running PowerShell Core. This is useful for environments where Docker is available and provides a consistent runtime environment.

#### Connectivity

The script uses PowerShell remoting to connect to the Windows servers. This requires:

1. **WinRM (Windows Remote Management)**:
   - WinRM must be enabled and configured on the Windows servers to allow remote PowerShell execution.

2. **Network Access**:
   - The control machine must have network access to the Windows servers. This includes proper routing, firewall rules, and any necessary VPN connections.

#### Script Execution Flow

1. **Configure Network Settings and Install Updates**:
   - The script configures network settings (static IP, DNS) and installs Windows updates on all servers.

2. **Install AD DS and Configure the Forest on ad01**:
   - The script installs the AD DS role and configures a new AD forest on the first server (`ad01`).

3. **Join Additional Servers to the Domain and Promote as Domain Controllers**:
   - The script joins the remaining servers (`ad02`, `ad03`, `ad04`) to the domain and promotes them as additional domain controllers.

4. **Configure NTP Settings**:
   - The script configures NTP settings on all servers to synchronize time with an external NTP server.

### Example: Running the Script from a Docker Container on a Linux Host

#### Dockerfile

Create a Dockerfile to build a PowerShell Core container:

```Dockerfile
FROM mcr.microsoft.com/powershell:7.2.0-ubuntu-20.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy the PowerShell script into the container
COPY install_adds.ps1 /scripts/install_adds.ps1

# Set the entrypoint to PowerShell
ENTRYPOINT ["pwsh", "/scripts/install_adds.ps1"]
```

#### Build and Run the Container

1. **Build the Docker Image**:

```sh
docker build -t powershell-core-ad-config .
```

2. **Run the Docker Container**:

```sh
docker run --rm -it powershell-core-ad-config
```

### Summary

- **Control Machine**: The script can be run from a Windows machine, a Linux machine with PowerShell Core, or a Docker container.
- **Connectivity**: Requires WinRM to be enabled on Windows servers and proper network access.
- **Execution Flow**: Configures network settings, installs updates, sets up AD DS, joins additional servers to the domain, and configures NTP settings.

By following this topology and execution flow, you can effectively configure an AD forest and domain controllers on multiple Windows servers from various environments.