# What's this

A tool for automatically updating Cloudflare DNS, usually used for DDNS.

# How to use

```bash
docker run --rm \
  -e CF_API_TOKEN=your_api_token \
  -e CF_DOMAIN=your_domain_eg_example.com \
  -e CF_DNS_DOMAIN=your_doain_for_update_eg_my-nas.example.com \
  gam2046/cloudflare
```
