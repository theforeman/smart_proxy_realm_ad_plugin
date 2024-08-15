# Getting Started with the [`smart_proxy_realm_ad_plugin`] 

This tutorial will guide you through the steps to build, run, and use the [`smart_proxy_realm_ad_plugin`] 

This container is based on Ubuntu 22.04 and includes various development tools, libraries, and configurations for working with Kerberos and LDAP.

## Prerequisites

- Docker installed on your machine.
- Internet connection to pull base images and clone repositories.

## Step 1: Clone the Repository

First, clone the repository containing the Dockerfile and related scripts.

```sh
git clone https://github.com/your-repo/smart_proxy_realm_ad_plugin.git
cd smart_proxy_realm_ad_plugin
```

## Step 2: Build the Docker Image

Build the Docker image using the provided Dockerfile. This step will install all necessary packages and configure the environment.

```sh
docker build -t smart_proxy_realm_ad_plugin:master .
```

## Step 3: Run the Docker Container

Run the container in the background. This command will start the container and keep it running.

```sh
docker run --name smart_proxy_realm_ad_plugin-dev -d smart_proxy_realm_ad_plugin:master sleep infinity
```

## Step 4: Access the Container

Open a shell inside the running container to start using it.

```sh
docker exec -it smart_proxy_realm_ad_plugin-dev /bin/bash
```

## Step 5: Verify the Environment

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

## Step 6: Run Tests (Optional)

If you have tests to run inside the container, you can execute them as follows:

```sh
docker exec smart_proxy_realm_ad_plugin-dev /bin/bash -c "cd /path/to/tests && ./run_tests.sh"
```

## Step 7: Clean Up

When you are done, you can stop and remove the container, and optionally remove the image.

1. **Stop the Container**:
   ```sh
   docker stop smart_proxy_realm_ad_plugin-dev
   ```

2. **Remove the Container**:
   ```sh
   docker rm smart_proxy_realm_ad_plugin-dev
   ```

3. **Remove the Image** (optional):
   ```sh
   docker rmi smart_proxy_realm_ad_plugin:master
   ```

## Summary

You have successfully built and run the [`smart_proxy_realm_ad_plugin`] container. You can now use this container for development and testing purposes, with all necessary tools and configurations pre-installed.