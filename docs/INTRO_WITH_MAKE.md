# Getting Started with the `smart_proxy_realm_ad_plugin` Container

This tutorial will guide you through the steps to build, run, and use the `smart_proxy_realm_ad_plugin` container. This container is based on Ubuntu 22.04 and includes various development tools, libraries, and configurations for working with Kerberos and LDAP.

## Prerequisites

- Docker installed on your machine.
- Make installed on your machine.
- Internet connection to pull base images and clone repositories.

## Step 1: Clone the Repository

First, clone the repository containing the Dockerfile, Makefile, and related scripts.

```sh
git clone https://github.com/your-repo/smart_proxy_realm_ad_plugin.git
cd smart_proxy_realm_ad_plugin
```
## Step 2: Understand the Makefile

The Makefile contains several targets to help you manage the Docker container. Here is a brief overview of each target:

- **default**: Builds the Docker image and runs the container.
- **help**: Displays help information.
- **build**: Builds the Docker image from the Dockerfile.
- **rebuild**: Builds the Docker image without using the cache.
- **run**: Runs the container in the background.
- **shell**: Opens a shell in the running container.
- **stop**: Stops the running container.
- **restart**: Restarts the container.
- **clean**: Cleans up by removing the container and image.

## Step 3: Build the Docker Image

To build the Docker image, use the `build` target. This will install all necessary packages and configure the environment.

```sh
make build
```

## Step 4: Run the Docker Container

To run the container in the background, use the `run` target. This command will start the container and keep it running.

```sh
make run
```

## Step 5: Access the Container

To open a shell inside the running container, use the [`shell`] target. This is useful for debugging and development.

```sh
make shell
```

## Step 6: Verify the Environment

Once inside the container, you can verify that the environment is set up correctly.

1. **Check Installed Packages**:
   ```sh
   dpkg -l | grep -E 'ruby|automake|autoconf|gcc|make|libkrb5-dev|libldap2-dev|libsasl2-dev|adcli|krb5-user|ldap-utils|dnsutils|git'
   ```

2. **Check DNS Configuration**:
   ```sh
   cat /etc/resolv.conf
   ```

3. **Check Oh-My-Bash Installation**:
   ```sh
   echo $OSH
   ```

## Step 7: Stop the Container

To stop the running container, use the [`stop`]  target.

```sh
make stop
```

## Step 8: Clean Up

When you are done, you can clean up by removing the container and image using the [`clean`]  target.

```sh
make clean
```

## Additional Targets

- **rebuild**: If you need to rebuild the Docker image without using the cache, use the [`rebuild`]  target.
  ```sh
  make rebuild
  ```

- **restart**: To restart the container, use the [`restart`] target.
  ```sh
  make restart
  ```

## Summary

You have successfully used the Makefile to build, run, and manage the [`smart_proxy_realm_ad_plugin`] devcontainer. The Makefile simplifies common tasks, making it easier to develop and test your application. 
You can now use this setup for efficient development and testing purposes.
