# smart_proxy_realm_ad_plugin

Welcome to the project! This repository contains smart_proxy_realm_ad_plugin.

## Getting Started

For detailed onboarding instructions, please refer to the [ONBOARDING.md](ONBOARDING.md) file.

## Prerequisites

- Docker
- Git

## Quick Start

1. **Clone your fork**

   ```sh
   git clone https://github.com/your-username/smart_proxy_realm_ad_plugin.git
   cd smart_proxy_realm_ad_plugin
   ```

2. **Install the prerequisites**

   Ensure you have Docker and Git installed on your machine. You can follow the official installation guides:

   - [Docker Installation](https://docs.docker.com/get-docker/)
   - [Git Installation](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

3. **Build the Docker image**

   Use Docker to build the image for the development environment.

   ```sh
   docker build -t smart_proxy_realm_ad_plugin .
   ```

4. **Run the Docker container**

   Start the Docker container with the necessary configurations.

   ```sh
   docker run -it --rm --name smart_proxy_realm_ad_plugin -v $(pwd):/app -w /app smart_proxy_realm_ad_plugin
   ```

   This command will run the Docker container interactively, mount the current directory to `/app` inside the container, and set the working directory to `/app`.

5. **Install dependencies**

   Inside the running Docker container, install the necessary dependencies.

   ```sh
   bundle install
   ```

6. **Run tests**

   To ensure everything is set up correctly, you can run the tests inside the Docker container.

   ```sh
   bundle exec rake test
   ```

7. **Start developing**

   You are now ready to start developing! Make your changes and see them reflected in the running application.

## Additional Resources

- [Foreman Documentation](https://theforeman.org/documentation.html)
- [Foreman Smart Proxy Documentation](https://theforeman.org/manuals/latest/index.html#4.3SmartProxies)
- [Foreman Community](https://community.theforeman.org/)
 