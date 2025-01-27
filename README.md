# Homelab - [Find my website here!](https://seanchoo.top)

## Prerequisitess:
1. Terraform: https://developer.hashicorp.com/terraform/install
2. Terragrunt: https://terragrunt.gruntwork.io/docs/getting-started/install/
3. Docker: https://docs.docker.com/engine/install/
4. Cloudflare Tunnels + Zero Trust https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/get-started/
5. Snort (IDP): https://www.snort.org/

# Steps to set up:

## 1. Set up and install all prereqs mentioned above

## 2. Update and set up config files

Key Requirements:
- Update the environment files for env-vars and global-vars
- Update .env for firefly and immich in infra-modules
- Update the caddyfile (in volumes/caddy/caddystuff) as per below:

```

<YOUR_DOMAIN> {
	file_server
}

https://subdomain.{domain_name} {
	reverse_proxy {local_ip:port}
}

...

```

You may have to automatically upgrade insecure headers because of http / https differences when going from cloudflare tunnel to reverse proxy to app.

## 3. Build all infrastructure

```
sudo terragrunt run-all apply
```

## 4. Run the tunnel

```
cloudflared tunnel --config server_config.yml run <tunnel UUID>
```


# Video Tutorials on Youtube:
- Coming Soon!


