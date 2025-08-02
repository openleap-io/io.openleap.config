# OpenLeap.org Configuration Server
A Spring Boot configuration service, built on top of Netflix Archaius. The purpose of this service is to provide technical microservice
configuration centrally managed across the whole application. Furthermore, this set of configuration files can be kept in separate project
specific repositories to keep the configuration service project independent. It can be configured to push configuration changes directly
out to the certain services and trigger a configuration reload without the need to restart the downstream service.

# Build and Run Locally
The easiest way to run the configuration server locally is in `native` mode without pointing to an external Git repository. In this mode,
the server tries to resolve all configuration files locally, either from classpath or a file location. The server could also be configured
to fetch the configuration files at startup from a Git repository.

Build and run locally:
```
$ ./mvnw package
$ java -Dspring.profiles.active=native \ 
-Dspring.cloud.config.server.native.search-location=file://./myconf \
-jar target/openleap-config-exec.jar
```

By default, the configuration server listens on port `8099` and exposes the configuration files under the `/config` path that are part of the repository `https://github.com/openleap-io/io.openleap.config-repo`

To fetch the configuration files from a Git repository, the following configuration is required:

In the [application.yml](src/main/resources/application.yml) set the
```yaml
username: ${SSH_USERNAME:your_username}
password: ${SSH_PASSWORD:your_password}
```
This is your ssh username and password for your public key you are using to access the git repository.

Note: if there are issues related the ssh key make sure you have the git repo added to your known_hosts file at the top.

### Key generation and encryption of sensitive information
Currently, there is a default server.jks.

To create new key use the command:
```shell
keytool -genkeypair -alias mytestkey -keyalg RSA -dname "CN=Web Server,OU=Unit,O=Organization,L=City,S=State,C=US" -keypass letmein -keystore server.jks -storepass letmein
```
and then update the [application.yml](src/main/resources/application.yml) with the following:
```yaml
encrypt:
  keyStore:
    location: classpath:/server.jks
    password: letmein
    alias: mytestkey
    secret: letmein
```

To add new sensitive information to the configuration files, use the following command:

Make a request to:
```shell
curl -i -X POST -H "Authorization: Basic dXNlcjpzYQ==" localhost:8098/encrypt -s -d kire
HTTP/1.1 200 
X-Content-Type-Options: nosniff
X-XSS-Protection: 0
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Pragma: no-cache
Expires: 0
X-Frame-Options: DENY
Content-Type: text/plain;charset=UTF-8
Content-Length: 560
Date: Sat, 02 Aug 2025 11:39:57 GMT

AYCP0CkK9KMb/uzd/xubkVJClCETY1yJIqAHtK6XkE2CHkohU4VUwTox0yQO1cvYrRMp3ddEGl4f4+BVLLHimhLfXKxmlp0lcxOehKPhDEAKiKVDfDKtKWAisdbmL9vv9XbCmv0nFHPfAUJpVYSo6XC8YLh0if37T2jlcfErbOAyPRFdWwEDuk9I6XjozQgL3HlSBN5Ti09SrjNn8/6czH4dv6wCy7w6a1uREqN8IUWtFYwD5nwhbpGRddtjQM9Pgp86RgsEOxhbYDuc6OH7OatwZnmSJX//2fBn/bjKfNGEt/C0eQr9HA9YT7xwhwe66n3DmrA888RAF0SZritQRQUgxOWRHj1wZ6IKMs29FRLGc8Z4uJKwWlpT/yG7cfzpYOeNfijma9f7NTDaNvjAJauTashst1CvxzHPfzpa4fJ9zsZwZFVbcyC/jndtIv4tslfn22q66KF0WAwVdm/jOvJoFGH+bOQkjQu13dMlgMUCPbg2jCSTUeNYzCThLy3S6jQrm24pXfjPaTFVnVYcsPfeUN5xxpvPqTciDKdojwEfGw==
```
To decrypt the value, use the following command (url encode the data):
```shell
curl -i -X POST -H "Authorization: Basic dXNlcjpzYQ==" localhost:8098/decrypt -s -d AYCP0CkK9KMb%2Fuzd%2FxubkVJClCETY1yJIqAHtK6XkE2CHkohU4VUwTox0yQO1cvYrRMp3ddEGl4f4%2BBVLLHimhLfXKxmlp0lcxOehKPhDEAKiKVDfDKtKWAisdbmL9vv9XbCmv0nFHPfAUJpVYSo6XC8YLh0if37T2jlcfErbOAyPRFdWwEDuk9I6XjozQgL3HlSBN5Ti09SrjNn8%2F6czH4dv6wCy7w6a1uREqN8IUWtFYwD5nwhbpGRddtjQM9Pgp86RgsEOxhbYDuc6OH7OatwZnmSJX%2F%2F2fBn%2FbjKfNGEt%2FC0eQr9HA9YT7xwhwe66n3DmrA888RAF0SZritQRQUgxOWRHj1wZ6IKMs29FRLGc8Z4uJKwWlpT%2FyG7cfzpYOeNfijma9f7NTDaNvjAJauTashst1CvxzHPfzpa4fJ9zsZwZFVbcyC%2FjndtIv4tslfn22q66KF0WAwVdm%2FjOvJoFGH%2BbOQkjQu13dMlgMUCPbg2jCSTUeNYzCThLy3S6jQrm24pXfjPaTFVnVYcsPfeUN5xxpvPqTciDKdojwEfGw%3D%3D
HTTP/1.1 200 
X-Content-Type-Options: nosniff
X-XSS-Protection: 0
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Pragma: no-cache
Expires: 0
X-Frame-Options: DENY
Content-Type: text/plain;charset=UTF-8
Content-Length: 4
Date: Sat, 02 Aug 2025 12:00:32 GMT

kire

```

Add the encrypted value to the coresponding configuration file with a prefix {cipher}:
```yaml
some_sensitive_property: '{cipher}AYC+btjcE+8zVcdTPXnwfIxs4bLyYKAJwxMcb66F48keDAP1BAhAFx5KqwMiJq5w0viQieq2Em8mlX6z+/wAkgmYN+qJ9LLTPT6qE5ftuF1vz8CYJf2o5NxbyV6CB/gobtcpijhadKeQc9Gj3nNs7ghhleEQuFd8qDyg8Kp0hbciTacZi8HvUYLZFP6jltwUFa4qKwoUs0EGie95T900+kaMvtJkZFKBCiVlLRSBZbb9gEUh+B/OOuwEmSrZ8z8bKyU91/2m5TVLhL06P9TBvJk59iZbv3oIgQNvhdexGoK+UOAZ/WTcimHHbLiKh6lUKSiXceyt5qaUnu4FyloO7XOm4LS0xDN0WJW6bHmGgiTBSYYwvX0dN5b2SjwaSCOCK8ujE3rzQ7+l4a9vx3wOb96H60Q98gqvhCtsh2W5dyteh/w7U9jFBDIzpAJsNM2AaCoccMAUChsKRyT9ZtGr4rR67RUZY10Jun5phcN8+NISL74w/AVU/Lg90TuQnTRZ2FJE2s0dpHYvimmdTGA/CrH21qwZMSt3mmswOZONwxl+BdSLkKT4ZRW8FEFl2GN9tEI='
```

# Run as Docker Container
The configuration server is also available on [Docker Hub](https://hub.docker.com/r/openleap/openleap-config) as pre-built Docker
image. Simply bootstrap a container and expose the internal port `8099` of the service:

```
docker run -p8099:8099 -d openleap/openleap-config:latest
```

# Release
A release and upload of this service can be done:
```
$ ./mvn release:prepare
$ ./mvn release:perform
```

# Resources

[![Build status](https://github.com/openleap-io/io.openleap.config/actions/workflows/main-build.yml/badge.svg)](https://github.com/openleap-io/io.openleap.config/actions/workflows/main-build.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Maven central](https://img.shields.io/maven-central/v/org.openwms/io.openleap.config)](https://search.maven.org/search?q=a:io.openleap.config)
[![Docker pulls](https://img.shields.io/docker/pulls/openleap/openleap-config)](https://hub.docker.com/r/openleap/openleap-config)

