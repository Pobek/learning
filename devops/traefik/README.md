# Traefik

## How to run

```bash
docker run -d -p 80:80 -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock -v /Users/evyac/Documents/personal/git/learning/devops/traefik/traefik.toml:/etc/traefik/traefik.toml --name traefik traefik:1.6.6-alpine```
