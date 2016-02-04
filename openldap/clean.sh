systemctl stop slapd
rm -rf /etc/openldap/*
rm -rf /etc/opentlc/*
rm -rf /var/lib/ldap/*

yum reinstall *openldap* -y
