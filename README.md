EasyApache 4 CloudFlare module
=============
This module builds the mod_cloudflare for cPanel & WHM EasyApache 4.

Installation
-----------
CentOS 6:
```
wget -O /etc/yum.repos.d/EA4-Mod-Cloudflare.repo http://download.opensuse.org/repositories/home:/Jperkster:/EA4_Mod_Cloudflare/CentOS-6/home:Jperkster:EA4_Mod_Cloudflare.repo
yum install ea-apache24-mod_cloudflare
```

CentOS 7:
```
wget -O /etc/yum.repos.d/EA4-Mod-Cloudflare.repo http://download.opensuse.org/repositories/home:/Jperkster:/EA4_Mod_Cloudflare/CentOS-7/home:Jperkster:EA4_Mod_Cloudflare.repo
yum install ea-apache24-mod_cloudflare
```

Removal
-----------
If you ever need to remove this module, simply run:
```
yum remove ea-apache24-mod_cloudflare
```
