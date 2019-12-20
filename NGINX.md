# Protect Health Check endpoints using htauth credentials.

## Create htpasswd file
  - Create /etc/nginx/.htpasswd. The format for this file is as follow:

    ```
    $user:password
    ```

  - The password can be generated using the following command.

    ```
    $-> openssl passwd -apr1
    ```

  - Example of the file.

    ```
    httpauth:$apr1$LNrZDUUO$sAN3WLCm7YN6gzGjnCc85.
    ```

  - In case you are using dockerized nginx, Update the docker file with the following command.

    ```
    COPY ${path_to_htpasswd_file} /etc/nginx/.htpasswd
    ```

## Update the nginx configurations
Add the following lines to nginx confutations for each of the applications that use the health check gem. Make sure that you replace the place holders #{application} and #{port}.

```
location /${endpoint_to_be_protected} {
    auth_basic "Restricted Content";
    auth_basic_user_file /etc/nginx/.htpasswd;

    resolver 127.0.0.11 ipv6=off;

    set $target http://#{application}:#{port};
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_pass $target;
  }
```
