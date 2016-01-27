ldapsearch -D "cn=Manager,dc=opentlcx,dc=com" -h 172.17.84.3 -p 389 -w password -x -s sub -b dc=opentlcx,dc=com "(&(objectClass=inetOrgPerson)(cn=jamie)(memberOf=cn=openshift,ou=Group,dc=opentlcx,dc=com))"

#"(&(cn=openshift)(objectclass=groupOfNames))"
