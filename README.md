# Homelab - [Find my website here!](https://seanchoo.top)

## Prerequisites:
1. Terraform: https://developer.hashicorp.com/terraform/install
2. Terragrunt: https://terragrunt.gruntwork.io/docs/getting-started/install/
3. Docker: https://docs.docker.com/engine/install/
4. Cloudflare Tunnels + Zero Trust https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/get-started/
5. Snort (IDPS): https://www.snort.org/
6. Get a domain name. https://porkbun.com/ has some cheap ones!

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

# Word of Caution:
- Secure all "private" exposed services with MFA - TOTP, Oauth etc...
- Install an IDPS (intrustion detection prevention system) to sniff out unwanted snooping/intrusions and take action with cloudflare dashboard
- If possible, host this on a "clean" host machine with no other sensitive data to be compromised
 
# Video Tutorials on Youtube:
- Coming Soon!


