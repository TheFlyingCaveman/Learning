# Example-ContainerLogRedirect

An example of how one can redirect multiple files to stdout in a container.

```shell
docker build . -t container_log_redirect_example
docker run --rm container_log_redirect_example
```

Inspired by many sources, but one in particular: https://github.com/nginxinc/docker-nginx/blob/8921999083def7ba43a06fabd5f80e4406651353/mainline/jessie/Dockerfile#L21-L23