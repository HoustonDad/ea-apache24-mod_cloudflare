%global ns_name ea-apache24
%global module_name mod_cloudflare

Summary: CloudFlare Apache module mod_cloudflare to show visitor IPs in logs.
Name: ea-apache24-mod_cloudflare
Version: 1.2.0
Release: 1%{?dist}
License: ASL-2.0
Group: System Environment/Daemons
URL: https://github.com/cloudflare/mod_cloudflare
Source0: %{module_name}.c
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildRequires: ea-apache24-devel
Requires: ea-apache24

%description
CloudFlare acts as a proxy, which means that your visitors are routed through
the CloudFlare network and you do not see their original IP address. This
module uses HTTP headers provided by the CloudFlare proxy to log the real IP
address of the visitor.
Based on mod_remoteip.c, this apache extension will replace the
remote_ip variable in user's logs with the correct remote_ip sent
from CloudFlare. This also does authentication, only performing
the switch for requests originating from CloudFlare IPs.

%prep
%setup -c -T
cp -p %{SOURCE0} .

%build
%{_httpd_apxs} -c mod_cloudflare.c
mv .libs/%{module_name}.so .
%{__strip} -g %{module_name}.so

%install
rm -rf %{buildroot}

mkdir -p %{buildroot}%{_httpd_moddir}
install %{module_name}.so %{buildroot}%{_httpd_moddir}/
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/apache2/conf.modules.d/
install -p $RPM_SOURCE_DIR/cloudflare.conf $RPM_BUILD_ROOT%{_sysconfdir}/apache2/conf.modules.d/cloudflare.conf

%clean
rm -rf %{buildroot}

%files
%defattr(0640,root,root,0755)
%attr(755,root,root)%{_httpd_moddir}/mod_cloudflare.so
%config(noreplace) %attr(0644,root,root) %{_sysconfdir}/apache2/conf.modules.d/cloudflare.conf

%changelog
* Sat Jun 4 2016 Jacob Perkins <jacob.perkin@gmail.com>
- Initial commit
* Sun Jan 7 2018 Michael Beasley <m.beasly@cpanel.net>
- Fix spelling error in Summary
