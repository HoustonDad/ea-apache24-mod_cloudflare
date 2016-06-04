EasyApache 4 CloudFlare module
=============
This module builds the mod_cloudflare for cPanel & WHM EasyApache 4.

Installation
-----------
0. Go to the following link and click on your architecture: http://download.opensuse.org/repositories/home:/Jperkster:/EA4_Mod_Cloudflare/
0. Download the .repo file:
```
wget -O /etc/yum.repos.d/EA4-Mod-Cloudflare.repo $Link_to_repo_file 
yum install ea-apache24-mod_cloudflare
```

Removal
-----------
If you ever need to remove this module, simply run:
```
yum remove ea-apache24-mod_cloudflare
```
