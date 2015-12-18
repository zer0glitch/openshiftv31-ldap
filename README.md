Configuring Openshift lab for ldap authentication
1.  Add a new identity provider
```
- name: "my_ldap_provider" 
    challenge: true 
    login: true 
    provider:
      apiVersion: v1
      kind: LDAPPasswordIdentityProvider
      attributes:
        id: 
        - dn
        email: 
        - mail
        name: 
        - cn
        preferredUsername: 
        - uid
      bindDN: "dc=opentlcGUID,dc=com" 
      bindPassword: "secret" 
      insecure: true 
      url: "ldap://oselabGUID/ou=users,dc=openltcGUID,dc=com?uid"
```


Perform the following actions on your jump server or another server to install ApacheDS  

Using a playbook

1 clone the project here https://github.com/zer0glitch/openshiftv31-ldap
2 modify vars/config.yml with your GUID
3 ansible-play ldap.yml



Manual Steps
  1. Download apache ds rpm
```
    curl http://mirrors.koehn.com/apache/directory/apacheds/dist/2.0.0-M20/apacheds-2.0.0-M20-x86_64.rpm -o apacheds-2.0.0-M20-x86_64.rpm
```

  2 name: install the rpm
```
     yum install apacheds-2.0.0-M20-x86_64.rpm java-1.8.0-openjdk java-1.8.0-openjdk-devel openldap-clients -y
```

  3 name: open iptables ports
```
   iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 10389 -j ACCEPT
   iptables -A OS_FIREWALL_ALLOW -p tcp -m state --state NEW -m tcp --dport 10389 -j ACCEPT
```

  4 configure your config.ldif
    - Example is below
  5 copy your ldif to apache *this needs to be done before the server starts
```
  cp config.ldif /var/lib/apacheds-2.0.0_M20/default/conf/config.ldif
```

  6 Start apache
```
    /etc/init.d/apacheds-2.0.0_M20-default start
```

  7 Modify your create.ldif example for  your guid
```
dn: dc=opentlc07a7, dc=com
dc: opentlc07a7
o: Oopen Tlc 07a7
objectclass: organization
objectclass: dcObject

dn: ou=People, dc=opentlc07a7,dc=com
objectclass: top
objectclass: organizationalUnit
ou: People
ou: Marketing

dn: ou=Groups,dc=opentlc07a7,dc=com
objectclass: top
objectclass: organizationalUnit
ou: Groups

dn: cn=Administrators,ou=Groups,dc=opentlc07a7,dc=com
objectclass: top
objectclass: groupOfNames
member: cn=NOT REALLY,ou=People,dc=opentlc07a7,dc=com
cn: Administrators
```

  8 Import your domain
```
    bash -c 'ldapadd -h localhost -p 10389 -D "uid=admin,ou=system" -w secret < create.ldif'
```

  9 Modify your add_user.ldif example for  your guid
```
dn: cn=openshift,ou=People,dc=opentlc07a7,dc=com
changetype: add
objectclass: top
objectclass: person
objectclass: organizationalPerson
objectclass: inetOrgPerson
cn: Red Hat Open Shift
givenName: Red Hat
sn: openshift
ou: openshift
uid: openshift
userPassword: password

```

  10 Import your domain
```
    bash -c 'ldapadd -h localhost -p 10389 -D "uid=admin,ou=system" -w secret < add_user.ldif'
```


```
dn: ou=config
entryCSN: 20151218031302.999000Z#000000#000#000000
entryUUID: 207e34dc-55c8-46af-b6e6-82c0243ba798
ou: config
objectClass: top
objectClass: organizationalUnit
entryParentId: 00000000-0000-0000-0000-000000000000

dn: ads-directoryServiceId=default,ou=config
ads-directoryServiceId: default
ads-dsSyncPeriodMillis: 15000
entryCSN: 20151218031303.000000Z#000000#000#000000
ads-dsAllowAnonymousAccess: TRUE
ads-dsReplicaId: 1
ads-dsAccessControlEnabled: FALSE
ads-dsPasswordHidden: FALSE
ads-dsDenormalizeOpAttrsEnabled: FALSE
ads-enabled: TRUE
entryUUID: b10a63f1-15ee-4793-92be-f332065d549c
objectClass: top
objectClass: ads-directoryService
objectClass: ads-base
entryParentId: 207e34dc-55c8-46af-b6e6-82c0243ba798

dn: ads-changeLogId=defaultChangeLog,ads-directoryServiceId=default,ou=config
ads-changeLogExposed: FALSE
entryCSN: 20151218031303.002000Z#000000#000#000000
objectClass: top
objectClass: ads-base
objectClass: ads-changeLog
ads-enabled: FALSE
entryUUID: 870c020e-9083-4677-ade3-4c5c38c37c23
ads-changeLogId: defaultChangeLog
entryParentId: b10a63f1-15ee-4793-92be-f332065d549c

dn: ads-journalId=defaultJournal,ads-directoryServiceId=default,ou=config
ads-journalId: defaultJournal
ads-journalFileName: Journal.txt
entryCSN: 20151218031303.002000Z#000001#000#000000
objectClass: top
objectClass: ads-journal
objectClass: ads-base
ads-enabled: FALSE
entryUUID: e0191436-0048-405f-abca-1eb7c294c149
ads-journalWorkingDir: /
ads-journalRotation: 2
entryParentId: b10a63f1-15ee-4793-92be-f332065d549c

dn: ou=interceptors,ads-directoryServiceId=default,ou=config
entryCSN: 20151218031303.069000Z#000000#000#000000
entryUUID: d1f6f466-2070-43f2-9e87-daeaf06b8843
ou: interceptors
objectClass: top
objectClass: organizationalUnit
entryParentId: b10a63f1-15ee-4793-92be-f332065d549c

dn: ads-interceptorId=aciAuthorizationInterceptor,ou=interceptors,ads-directoryS
 erviceId=default,ou=config
entryCSN: 20151218031303.142000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: TRUE
entryUUID: ecf7e333-5d73-4202-97cf-ba2107009ba3
ads-interceptorClassName: org.apache.directory.server.core.authz.AciAuthorizatio
 nInterceptor
ads-interceptorOrder: 4
ads-interceptorId: aciAuthorizationInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ads-interceptorId=administrativePointInterceptor,ou=interceptors,ads-directo
 ryServiceId=default,ou=config
entryCSN: 20151218031303.096000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: TRUE
entryUUID: 83e34c9c-540a-4b0c-b998-14089b406ad4
ads-interceptorClassName: org.apache.directory.server.core.admin.AdministrativeP
 ointInterceptor
ads-interceptorOrder: 6
ads-interceptorId: administrativePointInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ads-interceptorId=authenticationInterceptor,ou=interceptors,ads-directorySer
 viceId=default,ou=config
entryCSN: 20151218031303.120000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
objectClass: ads-authenticationInterceptor
ads-enabled: TRUE
entryUUID: 29fbb337-dcf2-44c1-b2af-a6a4315eb189
ads-interceptorClassName: org.apache.directory.server.core.authn.AuthenticationI
 nterceptor
ads-interceptorOrder: 2
ads-interceptorId: authenticationInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ou=authenticators,ads-interceptorId=authenticationInterceptor,ou=interceptor
 s,ads-directoryServiceId=default,ou=config
entryCSN: 20151218031303.123000Z#000000#000#000000
entryUUID: ced8612d-b428-48d3-bf3b-a545e43df849
ou: authenticators
objectClass: top
objectClass: organizationalUnit
entryParentId: 29fbb337-dcf2-44c1-b2af-a6a4315eb189

dn: ads-authenticatorId=anonymousauthenticator,ou=authenticators,ads-interceptor
 Id=authenticationInterceptor,ou=interceptors,ads-directoryServiceId=default,ou=
 config
entryCSN: 20151218031303.128000Z#000000#000#000000
objectClass: top
objectClass: ads-authenticator
objectClass: ads-base
objectClass: ads-authenticatorImpl
ads-authenticatorId: anonymousauthenticator
ads-baseDn: 
ads-authenticatorClass: org.apache.directory.server.core.authn.AnonymousAuthenti
 cator
ads-enabled: TRUE
entryUUID: a3253235-ca91-47bd-998e-3bfedf07839e
entryParentId: ced8612d-b428-48d3-bf3b-a545e43df849

dn: ads-authenticatorId=delegatingauthenticator,ou=authenticators,ads-intercepto
 rId=authenticationInterceptor,ou=interceptors,ads-directoryServiceId=default,ou
 =config
entryCSN: 20151218031303.125000Z#000000#000#000000
objectClass: top
objectClass: ads-authenticator
objectClass: ads-base
objectClass: ads-authenticatorImpl
ads-authenticatorId: delegatingauthenticator
ads-baseDn: 
ads-authenticatorClass: org.apache.directory.server.core.authn.DelegatingAuthent
 icator
ads-enabled: FALSE
entryUUID: bf7dedcb-feba-43d3-bb95-eb7bed8058ea
entryParentId: ced8612d-b428-48d3-bf3b-a545e43df849

dn: ads-authenticatorId=simpleauthenticator,ou=authenticators,ads-interceptorId=
 authenticationInterceptor,ou=interceptors,ads-directoryServiceId=default,ou=con
 fig
entryCSN: 20151218031303.131000Z#000000#000#000000
objectClass: top
objectClass: ads-authenticator
objectClass: ads-base
objectClass: ads-authenticatorImpl
ads-authenticatorId: simpleauthenticator
ads-baseDn: 
ads-authenticatorClass: org.apache.directory.server.core.authn.SimpleAuthenticat
 or
ads-enabled: TRUE
entryUUID: b247353e-2193-4223-a560-db17f7170ff9
entryParentId: ced8612d-b428-48d3-bf3b-a545e43df849

dn: ads-authenticatorId=strongauthenticator,ou=authenticators,ads-interceptorId=
 authenticationInterceptor,ou=interceptors,ads-directoryServiceId=default,ou=con
 fig
entryCSN: 20151218031303.129000Z#000000#000#000000
objectClass: top
objectClass: ads-authenticator
objectClass: ads-base
objectClass: ads-authenticatorImpl
ads-authenticatorId: strongauthenticator
ads-baseDn: 
ads-authenticatorClass: org.apache.directory.server.core.authn.StrongAuthenticat
 or
ads-enabled: TRUE
entryUUID: da9037f8-828e-4b58-add0-ac79a204a3fd
entryParentId: ced8612d-b428-48d3-bf3b-a545e43df849

dn: ou=passwordPolicies,ads-interceptorId=authenticationInterceptor,ou=intercept
 ors,ads-directoryServiceId=default,ou=config
entryCSN: 20151218031303.133000Z#000000#000#000000
entryUUID: b18c60fa-f438-4a84-b685-16ef4b2514b3
ou: passwordPolicies
objectClass: top
objectClass: organizationalUnit
entryParentId: 29fbb337-dcf2-44c1-b2af-a6a4315eb189

dn: ads-pwdId=default,ou=passwordPolicies,ads-interceptorId=authenticationInterc
 eptor,ou=interceptors,ads-directoryServiceId=default,ou=config
entryCSN: 20151218031303.136000Z#000000#000#000000
ads-pwdLockoutDuration: 0
ads-pwdAttribute: userPassword
ads-pwdId: default
ads-pwdLockout: TRUE
ads-pwdFailureCountInterval: 30
ads-pwdMaxFailure: 5
ads-pwdCheckQuality: 1
ads-enabled: TRUE
entryUUID: 086dca2a-6a85-405d-af60-e97a740323b0
ads-pwdInHistory: 5
ads-pwdValidator: org.apache.directory.server.core.api.authn.ppolicy.DefaultPass
 wordValidator
ads-pwdMinLength: 5
ads-pwdGraceAuthNLimit: 5
ads-pwdExpireWarning: 600
objectClass: ads-passwordPolicy
objectClass: top
objectClass: ads-base
entryParentId: b18c60fa-f438-4a84-b685-16ef4b2514b3

dn: ads-interceptorId=collectiveAttributeInterceptor,ou=interceptors,ads-directo
 ryServiceId=default,ou=config
entryCSN: 20151218031303.139000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: TRUE
entryUUID: 72efc6fb-2fe7-4403-95d3-76a5fc6b9f23
ads-interceptorClassName: org.apache.directory.server.core.collective.Collective
 AttributeInterceptor
ads-interceptorOrder: 12
ads-interceptorId: collectiveAttributeInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ads-interceptorId=defaultAuthorizationInterceptor,ou=interceptors,ads-direct
 oryServiceId=default,ou=config
entryCSN: 20151218031303.143000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: TRUE
entryUUID: fd2fbf55-8760-4b8b-9482-917b6b85ebb1
ads-interceptorClassName: org.apache.directory.server.core.authz.DefaultAuthoriz
 ationInterceptor
ads-interceptorOrder: 5
ads-interceptorId: defaultAuthorizationInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ads-interceptorId=eventInterceptor,ou=interceptors,ads-directoryServiceId=de
 fault,ou=config
entryCSN: 20151218031303.108000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: TRUE
entryUUID: 3c97a932-b395-44c8-a413-8995cfea4134
ads-interceptorClassName: org.apache.directory.server.core.event.EventIntercepto
 r
ads-interceptorOrder: 14
ads-interceptorId: eventInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ads-interceptorId=exceptionInterceptor,ou=interceptors,ads-directoryServiceI
 d=default,ou=config
entryCSN: 20151218031303.101000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: TRUE
entryUUID: d5b371aa-77d1-4356-b67f-dee740f88f0d
ads-interceptorClassName: org.apache.directory.server.core.exception.ExceptionIn
 terceptor
ads-interceptorOrder: 7
ads-interceptorId: exceptionInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ads-interceptorId=journalInterceptor,ou=interceptors,ads-directoryServiceId=
 default,ou=config
entryCSN: 20151218031303.091000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: TRUE
entryUUID: 44e683e4-8752-4bda-80e1-91f62948f959
ads-interceptorClassName: org.apache.directory.server.core.journal.JournalInterc
 eptor
ads-interceptorOrder: 16
ads-interceptorId: journalInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ads-interceptorId=keyDerivationInterceptor,ou=interceptors,ads-directoryServ
 iceId=default,ou=config
entryCSN: 20151218031303.114000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: FALSE
entryUUID: cc76cf73-43a5-425d-961c-92a08b5b3ef5
ads-interceptorClassName: org.apache.directory.server.core.kerberos.KeyDerivatio
 nInterceptor
ads-interceptorOrder: 8
ads-interceptorId: keyDerivationInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ads-interceptorId=normalizationInterceptor,ou=interceptors,ads-directoryServ
 iceId=default,ou=config
entryCSN: 20151218031303.098000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: TRUE
entryUUID: 2d8bee1c-95e6-485e-a1b7-366045ec405a
ads-interceptorClassName: org.apache.directory.server.core.normalization.Normali
 zationInterceptor
ads-interceptorOrder: 1
ads-interceptorId: normalizationInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ads-interceptorId=numberInterceptor,ou=interceptors,ads-directoryServiceId=d
 efault,ou=config
entryCSN: 20151218031303.118000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: FALSE
entryUUID: 13097032-be23-4739-aa7c-a3a731e2d230
ads-interceptorClassName: org.apache.directory.server.core.number.NumberIncremen
 tingInterceptor
ads-interceptorOrder: 17
ads-interceptorId: numberInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ads-interceptorId=operationalAttributeInterceptor,ou=interceptors,ads-direct
 oryServiceId=default,ou=config
entryCSN: 20151218031303.088000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: TRUE
entryUUID: 6415736d-f108-45e8-8737-8d5d238d1e3a
ads-interceptorClassName: org.apache.directory.server.core.operational.Operation
 alAttributeInterceptor
ads-interceptorOrder: 11
ads-interceptorId: operationalAttributeInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ads-interceptorId=passwordHashingInterceptor,ou=interceptors,ads-directorySe
 rviceId=default,ou=config
entryCSN: 20151218031303.112000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: TRUE
entryUUID: 849afa06-31f4-4120-a1f3-7799a3cde3f9
ads-interceptorClassName: org.apache.directory.server.core.hash.SshaPasswordHash
 ingInterceptor
ads-interceptorOrder: 9
ads-interceptorId: passwordHashingInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ads-interceptorId=referralInterceptor,ou=interceptors,ads-directoryServiceId
 =default,ou=config
entryCSN: 20151218031303.104000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: TRUE
entryUUID: edc639c6-691e-4092-a51c-7d776ba50dae
ads-interceptorClassName: org.apache.directory.server.core.referral.ReferralInte
 rceptor
ads-interceptorOrder: 3
ads-interceptorId: referralInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ads-interceptorId=schemaInterceptor,ou=interceptors,ads-directoryServiceId=d
 efault,ou=config
entryCSN: 20151218031303.094000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: TRUE
entryUUID: de449319-c5d1-45d2-8e51-06e0ad92103b
ads-interceptorClassName: org.apache.directory.server.core.schema.SchemaIntercep
 tor
ads-interceptorOrder: 10
ads-interceptorId: schemaInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ads-interceptorId=subentryInterceptor,ou=interceptors,ads-directoryServiceId
 =default,ou=config
entryCSN: 20151218031303.116000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: TRUE
entryUUID: 7515a995-3b44-4b44-ac15-b9b16a7df4e5
ads-interceptorClassName: org.apache.directory.server.core.subtree.SubentryInter
 ceptor
ads-interceptorOrder: 13
ads-interceptorId: subentryInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ads-interceptorId=triggerInterceptor,ou=interceptors,ads-directoryServiceId=
 default,ou=config
entryCSN: 20151218031303.110000Z#000000#000#000000
objectClass: ads-interceptor
objectClass: top
objectClass: ads-base
ads-enabled: TRUE
entryUUID: 19c33637-be98-4031-bc34-bf164b0389e6
ads-interceptorClassName: org.apache.directory.server.core.trigger.TriggerInterc
 eptor
ads-interceptorOrder: 15
ads-interceptorId: triggerInterceptor
entryParentId: d1f6f466-2070-43f2-9e87-daeaf06b8843

dn: ou=partitions,ads-directoryServiceId=default,ou=config
entryCSN: 20151218031303.145000Z#000000#000#000000
entryUUID: 1d52ea78-4cfd-4fcb-91e8-0312c3778ae5
ou: partitions
objectClass: top
objectClass: organizationalUnit
entryParentId: b10a63f1-15ee-4793-92be-f332065d549c

dn: ads-partitionId=opentlc07a7,ou=partitions,ads-directoryServiceId=default,ou=
 config
ads-contextEntry:: ZG46IGRjPW9wZW50bGNHVUlELGRjPWNvbQpvYmplY3RjbGFzczogZG9tYWluC
 m9iamVjdGNsYXNzOiB0b3AKZGM6IG9wZW50bGNHVUlECgo=
entryCSN: 20151218031303.182000Z#000000#000#000000
objectClass: top
objectClass: ads-partition
objectClass: ads-base
objectClass: ads-jdbmPartition
ads-enabled: TRUE
ads-partitionSuffix: dc=opentlc07a7,dc=com
entryUUID: f9d337f7-0192-470b-ba75-1bc37fa648ed
ads-partitionId: opentlc07a7
ads-partitionCacheSize: 10000
ads-partitionSyncOnWrite: TRUE
entryParentId: 1d52ea78-4cfd-4fcb-91e8-0312c3778ae5

dn: ou=indexes,ads-partitionId=opentlc07a7,ou=partitions,ads-directoryServiceId=
 default,ou=config
entryCSN: 20151218031303.185000Z#000000#000#000000
entryUUID: f99d985a-8533-4800-8701-4a87887d125e
ou: indexes
objectClass: top
objectClass: organizationalUnit
entryParentId: f9d337f7-0192-470b-ba75-1bc37fa648ed

dn: ads-indexAttributeId=administrativeRole,ou=indexes,ads-partitionId=opentlc
 07a7,ou=partitions,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.216000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: administrativeRole
ads-enabled: TRUE
entryUUID: 0919bada-966b-4e91-a92a-c1bbfad15728
entryParentId: f99d985a-8533-4800-8701-4a87887d125e

dn: ads-indexAttributeId=apacheAlias,ou=indexes,ads-partitionId=opentlc07a7,ou=p
 artitions,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.223000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: apacheAlias
ads-enabled: TRUE
entryUUID: 1da6acf4-43fa-4d83-a1d6-83649adbe57b
entryParentId: f99d985a-8533-4800-8701-4a87887d125e

dn: ads-indexAttributeId=apacheOneAlias,ou=indexes,ads-partitionId=opentlc07a7,o
 u=partitions,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.221000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: apacheOneAlias
ads-enabled: TRUE
entryUUID: 01224518-f5bf-45be-80d2-ccf213590e56
entryParentId: f99d985a-8533-4800-8701-4a87887d125e

dn: ads-indexAttributeId=apachePresence,ou=indexes,ads-partitionId=opentlc07a7,o
 u=partitions,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.203000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: apachePresence
ads-enabled: TRUE
entryUUID: 53022649-2e3a-4b1e-b870-160f2814df07
entryParentId: f99d985a-8533-4800-8701-4a87887d125e

dn: ads-indexAttributeId=apacheRdn,ou=indexes,ads-partitionId=opentlc07a7,ou=par
 titions,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: TRUE
entryCSN: 20151218031303.208000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: apacheRdn
ads-enabled: TRUE
entryUUID: 367781ba-44e8-414c-8d4c-64d4643a0604
entryParentId: f99d985a-8533-4800-8701-4a87887d125e

dn: ads-indexAttributeId=apacheSubAlias,ou=indexes,ads-partitionId=opentlc07a7,o
 u=partitions,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.198000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: apacheSubAlias
ads-enabled: TRUE
entryUUID: 80ab2ad4-1999-49ea-af85-72ceb5e497a3
entryParentId: f99d985a-8533-4800-8701-4a87887d125e

dn: ads-indexAttributeId=dc,ou=indexes,ads-partitionId=opentlc07a7,ou=partitions
 ,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.219000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: dc
ads-enabled: TRUE
entryUUID: bca16945-f5dd-4894-a508-7a7d7907b2a2
entryParentId: f99d985a-8533-4800-8701-4a87887d125e

dn: ads-indexAttributeId=entryCSN,ou=indexes,ads-partitionId=opentlc07a7,ou=part
 itions,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.210000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: entryCSN
ads-enabled: TRUE
entryUUID: 52860bfa-8647-4bbb-a8a2-29de6df37b85
entryParentId: f99d985a-8533-4800-8701-4a87887d125e

dn: ads-indexAttributeId=krb5PrincipalName,ou=indexes,ads-partitionId=opentlc
 07a7,ou=partitions,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.225000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: krb5PrincipalName
ads-enabled: TRUE
entryUUID: 394f9018-e165-44e9-b525-c0b1fa59ef46
entryParentId: f99d985a-8533-4800-8701-4a87887d125e

dn: ads-indexAttributeId=objectClass,ou=indexes,ads-partitionId=opentlc07a7,ou=p
 artitions,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.201000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: objectClass
ads-enabled: TRUE
entryUUID: 3e30261f-4642-4c70-b43d-d22e1242ca5b
entryParentId: f99d985a-8533-4800-8701-4a87887d125e

dn: ads-indexAttributeId=ou,ou=indexes,ads-partitionId=opentlc07a7,ou=partitions
 ,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.213000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: ou
ads-enabled: TRUE
entryUUID: 828810ef-96d5-4952-8a9d-24ac2f5ae08c
entryParentId: f99d985a-8533-4800-8701-4a87887d125e

dn: ads-indexAttributeId=uid,ou=indexes,ads-partitionId=opentlc07a7,ou=partition
 s,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.205000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: uid
ads-enabled: TRUE
entryUUID: d0446651-1d63-447d-8ca1-8c32a2ed2215
entryParentId: f99d985a-8533-4800-8701-4a87887d125e

dn: ads-partitionId=system,ou=partitions,ads-directoryServiceId=default,ou=confi
 g
entryCSN: 20151218031303.147000Z#000000#000#000000
objectClass: top
objectClass: ads-partition
objectClass: ads-base
objectClass: ads-jdbmPartition
ads-enabled: TRUE
ads-partitionSuffix: ou=system
entryUUID: 49c227dd-b9c3-4447-9269-45c9871dfe93
ads-partitionId: system
ads-partitionCacheSize: 10000
ads-partitionSyncOnWrite: TRUE
entryParentId: 1d52ea78-4cfd-4fcb-91e8-0312c3778ae5

dn: ou=indexes,ads-partitionId=system,ou=partitions,ads-directoryServiceId=defau
 lt,ou=config
entryCSN: 20151218031303.150000Z#000000#000#000000
entryUUID: 8add395d-0588-4c13-a8be-7f36857deec5
ou: indexes
objectClass: top
objectClass: organizationalUnit
entryParentId: 49c227dd-b9c3-4447-9269-45c9871dfe93

dn: ads-indexAttributeId=administrativeRole,ou=indexes,ads-partitionId=system,ou
 =partitions,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.173000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: administrativeRole
ads-enabled: TRUE
entryUUID: edd25846-11ce-4406-bead-cd8951eef1f1
entryParentId: 8add395d-0588-4c13-a8be-7f36857deec5

dn: ads-indexAttributeId=apacheAlias,ou=indexes,ads-partitionId=system,ou=partit
 ions,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.162000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: apacheAlias
ads-enabled: TRUE
entryUUID: 0e7fd4bb-7963-4930-b84b-df7fbb7fceb7
entryParentId: 8add395d-0588-4c13-a8be-7f36857deec5

dn: ads-indexAttributeId=apacheOneAlias,ou=indexes,ads-partitionId=system,ou=par
 titions,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.168000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: apacheOneAlias
ads-enabled: TRUE
entryUUID: 53b7f046-7cf4-4101-a2ff-b5e39df6ad33
entryParentId: 8add395d-0588-4c13-a8be-7f36857deec5

dn: ads-indexAttributeId=apachePresence,ou=indexes,ads-partitionId=system,ou=par
 titions,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.159000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: apachePresence
ads-enabled: TRUE
entryUUID: 0fb71171-aaa9-4e07-9829-17ab434b30be
entryParentId: 8add395d-0588-4c13-a8be-7f36857deec5

dn: ads-indexAttributeId=apacheRdn,ou=indexes,ads-partitionId=system,ou=partitio
 ns,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: TRUE
entryCSN: 20151218031303.179000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: apacheRdn
ads-enabled: TRUE
entryUUID: 3bf9235b-dd99-4369-bf9a-e9f940378344
ads-indexCacheSize: 1000
entryParentId: 8add395d-0588-4c13-a8be-7f36857deec5

dn: ads-indexAttributeId=apacheSubAlias,ou=indexes,ads-partitionId=system,ou=par
 titions,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.176000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: apacheSubAlias
ads-enabled: TRUE
entryUUID: a880733e-cd15-4f46-9f70-55c780bfb0c0
entryParentId: 8add395d-0588-4c13-a8be-7f36857deec5

dn: ads-indexAttributeId=entryCSN,ou=indexes,ads-partitionId=system,ou=partition
 s,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.153000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: entryCSN
ads-enabled: TRUE
entryUUID: 9a7a7fde-8411-43b1-84eb-e42a7acb909a
entryParentId: 8add395d-0588-4c13-a8be-7f36857deec5

dn: ads-indexAttributeId=objectClass,ou=indexes,ads-partitionId=system,ou=partit
 ions,ads-directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.157000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: objectClass
ads-enabled: TRUE
entryUUID: e6d43d73-beb6-4e75-9120-5316daf3591b
entryParentId: 8add395d-0588-4c13-a8be-7f36857deec5

dn: ads-indexAttributeId=ou,ou=indexes,ads-partitionId=system,ou=partitions,ads-
 directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.164000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: ou
ads-enabled: TRUE
entryUUID: 9ca9cef1-2281-461a-9e24-89f5be00fbcd
entryParentId: 8add395d-0588-4c13-a8be-7f36857deec5

dn: ads-indexAttributeId=uid,ou=indexes,ads-partitionId=system,ou=partitions,ads
 -directoryServiceId=default,ou=config
ads-indexHasReverse: FALSE
entryCSN: 20151218031303.170000Z#000000#000#000000
objectClass: ads-index
objectClass: top
objectClass: ads-jdbmIndex
objectClass: ads-base
ads-indexAttributeId: uid
ads-enabled: TRUE
entryUUID: 6814660d-c6af-4498-92a4-86c47ac0f82c
entryParentId: 8add395d-0588-4c13-a8be-7f36857deec5

dn: ou=servers,ads-directoryServiceId=default,ou=config
entryCSN: 20151218031303.003000Z#000000#000#000000
entryUUID: c89f0a9b-e0bf-45ca-8e51-eadb8b288b48
ou: servers
objectClass: top
objectClass: organizationalUnit
entryParentId: b10a63f1-15ee-4793-92be-f332065d549c

dn: ads-serverId=changePasswordServer,ou=servers,ads-directoryServiceId=default,
 ou=config
entryCSN: 20151218031303.003000Z#000001#000#000000
objectClass: ads-server
objectClass: ads-changePasswordServer
objectClass: top
objectClass: ads-base
objectClass: ads-dsBasedServer
ads-serverId: changePasswordServer
ads-enabled: FALSE
entryUUID: bb509a27-1cef-43b9-8d82-d34ae40d5cf4
entryParentId: c89f0a9b-e0bf-45ca-8e51-eadb8b288b48

dn: ou=transports,ads-serverId=changePasswordServer,ou=servers,ads-directoryServ
 iceId=default,ou=config
entryCSN: 20151218031303.004000Z#000000#000#000000
entryUUID: f439f961-64ef-47f5-9123-e4420e4c975a
ou: transports
objectClass: top
objectClass: organizationalUnit
entryParentId: bb509a27-1cef-43b9-8d82-d34ae40d5cf4

dn: ads-transportId=tcp,ou=transports,ads-serverId=changePasswordServer,ou=serve
 rs,ads-directoryServiceId=default,ou=config
entryCSN: 20151218031303.006000Z#000000#000#000000
ads-transportId: tcp
objectClass: top
objectClass: ads-base
objectClass: ads-transport
objectClass: ads-tcpTransport
ads-systemPort: 60464
ads-transportAddress: 0.0.0.0
ads-enabled: TRUE
entryUUID: ef1339ff-f9e8-4cff-ae0c-ad619267e5d6
ads-transportNbThreads: 2
entryParentId: f439f961-64ef-47f5-9123-e4420e4c975a

dn: ads-transportId=udp,ou=transports,ads-serverId=changePasswordServer,ou=serve
 rs,ads-directoryServiceId=default,ou=config
entryCSN: 20151218031303.005000Z#000000#000#000000
ads-transportId: udp
objectClass: ads-udpTransport
objectClass: top
objectClass: ads-base
objectClass: ads-transport
ads-systemPort: 60464
ads-transportAddress: 0.0.0.0
ads-enabled: TRUE
entryUUID: 1774e82e-0882-4566-91ab-2acabb27832e
ads-transportNbThreads: 2
entryParentId: f439f961-64ef-47f5-9123-e4420e4c975a

dn: ads-serverId=httpServer,ou=servers,ads-directoryServiceId=default,ou=config
entryCSN: 20151218031303.008000Z#000000#000#000000
objectClass: ads-server
objectClass: ads-httpServer
objectClass: top
objectClass: ads-base
ads-serverId: httpServer
ads-enabled: FALSE
entryUUID: 2f5151e4-212a-4499-9f76-1c5fac157f47
entryParentId: c89f0a9b-e0bf-45ca-8e51-eadb8b288b48

dn: ou=httpWebApps,ads-serverId=httpServer,ou=servers,ads-directoryServiceId=def
 ault,ou=config
entryCSN: 20151218031303.011000Z#000000#000#000000
entryUUID: 05ecaacc-c904-468d-9f4b-0468d5f54adf
ou: httpWebApps
objectClass: top
objectClass: organizationalUnit
entryParentId: 2f5151e4-212a-4499-9f76-1c5fac157f47

dn: ads-id=testapp,ou=httpWebApps,ads-serverId=httpServer,ou=servers,ads-directo
 ryServiceId=default,ou=config
entryCSN: 20151218031303.013000Z#000000#000#000000
objectClass: top
objectClass: ads-httpWebApp
objectClass: ads-base
ads-httpAppCtxPath: /foo
ads-httpWarFile: /path/to/foo/war
ads-enabled: FALSE
entryUUID: 51465a36-cf43-4b2c-b914-dad54aff940a
ads-id: testapp
entryParentId: 05ecaacc-c904-468d-9f4b-0468d5f54adf

dn: ou=transports,ads-serverId=httpServer,ou=servers,ads-directoryServiceId=defa
 ult,ou=config
entryCSN: 20151218031303.014000Z#000000#000#000000
entryUUID: f53e5086-d92e-4e12-a52d-13d85c404fbb
ou: transports
objectClass: top
objectClass: organizationalUnit
entryParentId: 2f5151e4-212a-4499-9f76-1c5fac157f47

dn: ads-transportId=http,ou=transports,ads-serverId=httpServer,ou=servers,ads-di
 rectoryServiceId=default,ou=config
entryCSN: 20151218031303.016000Z#000000#000#000000
ads-transportId: http
objectClass: top
objectClass: ads-base
objectClass: ads-transport
objectClass: ads-tcpTransport
ads-systemPort: 8080
ads-transportAddress: 0.0.0.0
ads-enabled: TRUE
entryUUID: d532d724-8bb7-4c5e-8175-7cce30a9c33d
entryParentId: f53e5086-d92e-4e12-a52d-13d85c404fbb

dn: ads-transportId=https,ou=transports,ads-serverId=httpServer,ou=servers,ads-d
 irectoryServiceId=default,ou=config
entryCSN: 20151218031303.015000Z#000000#000#000000
ads-transportId: https
objectClass: top
objectClass: ads-base
objectClass: ads-transport
objectClass: ads-tcpTransport
ads-systemPort: 8443
ads-transportAddress: 0.0.0.0
ads-enabled: TRUE
entryUUID: e835ecf7-f119-4f38-b43d-c329c2e719a2
entryParentId: f53e5086-d92e-4e12-a52d-13d85c404fbb

dn: ads-serverId=kerberosServer,ou=servers,ads-directoryServiceId=default,ou=con
 fig
entryCSN: 20151218031303.060000Z#000000#000#000000
ads-krbMaximumTicketLifetime: 86400000
ads-krbBodyChecksumVerified: TRUE
ads-krbEncryptionTypes: aes128-cts-hmac-sha1-96
ads-krbEncryptionTypes: des3-cbc-sha1-kd
ads-krbEncryptionTypes: des-cbc-md5
ads-krbAllowableClockSkew: 300000
ads-krbPrimaryRealm: OPENTLC07a7.COM
ads-krbForwardableAllowed: TRUE
ads-krbEmptyAddressesAllowed: TRUE
ads-searchBaseDN: ou=users,dc=opentlc07a7,dc=com
ads-krbPostdatedAllowed: TRUE
ads-krbPAEncTimestampRequired: TRUE
ads-krbRenewableAllowed: TRUE
ads-krbProxiableAllowed: TRUE
ads-krbMaximumRenewableLifetime: 604800000
ads-enabled: FALSE
entryUUID: f5cc414f-8378-4d61-8642-2f8f997ab358
objectClass: ads-server
objectClass: top
objectClass: ads-base
objectClass: ads-kdcServer
objectClass: ads-dsBasedServer
ads-serverId: kerberosServer
entryParentId: c89f0a9b-e0bf-45ca-8e51-eadb8b288b48

dn: ou=transports,ads-serverId=kerberosServer,ou=servers,ads-directoryServiceId=
 default,ou=config
entryCSN: 20151218031303.062000Z#000000#000#000000
entryUUID: ee3a391c-93a2-4b86-9558-1a12a9425cac
ou: transports
objectClass: top
objectClass: organizationalUnit
entryParentId: f5cc414f-8378-4d61-8642-2f8f997ab358

dn: ads-transportId=tcp,ou=transports,ads-serverId=kerberosServer,ou=servers,ads
 -directoryServiceId=default,ou=config
entryCSN: 20151218031303.064000Z#000000#000#000000
ads-transportId: tcp
objectClass: top
objectClass: ads-base
objectClass: ads-transport
objectClass: ads-tcpTransport
ads-systemPort: 60088
ads-transportAddress: 0.0.0.0
ads-enabled: TRUE
entryUUID: 998d7467-5bff-481c-8917-7ffecc78a467
ads-transportNbThreads: 4
entryParentId: ee3a391c-93a2-4b86-9558-1a12a9425cac

dn: ads-transportId=udp,ou=transports,ads-serverId=kerberosServer,ou=servers,ads
 -directoryServiceId=default,ou=config
entryCSN: 20151218031303.067000Z#000000#000#000000
ads-transportId: udp
objectClass: ads-udpTransport
objectClass: top
objectClass: ads-base
objectClass: ads-transport
ads-systemPort: 60088
ads-transportAddress: 0.0.0.0
ads-enabled: TRUE
entryUUID: 25d60d9d-ebdb-45ae-bc74-4a479b668faf
ads-transportNbThreads: 4
entryParentId: ee3a391c-93a2-4b86-9558-1a12a9425cac

dn: ads-serverId=ldapServer,ou=servers,ads-directoryServiceId=default,ou=config
ads-maxPDUSize: 2000000
entryCSN: 20151218031303.017000Z#000000#000#000000
ads-confidentialityRequired: FALSE
ads-maxSizeLimit: 1000
ads-saslHost: ldap.example.com
ads-maxTimeLimit: 15000
ads-searchBaseDN: ou=users,ou=system
ads-saslRealms: example.com
ads-saslRealms: apache.org
ads-saslPrincipal: ldap/ldap.example.com@EXAMPLE.COM
ads-replPingerSleep: 5
ads-replEnabled: TRUE
ads-enabled: TRUE
entryUUID: 31dfbb73-2a0e-40b8-a039-f80a40bde2d8
objectClass: ads-server
objectClass: top
objectClass: ads-ldapServer
objectClass: ads-base
objectClass: ads-dsBasedServer
ads-serverId: ldapServer
entryParentId: c89f0a9b-e0bf-45ca-8e51-eadb8b288b48

dn: ou=extendedOpHandlers,ads-serverId=ldapServer,ou=servers,ads-directoryServic
 eId=default,ou=config
entryCSN: 20151218031303.036000Z#000000#000#000000
entryUUID: ee63c3bf-dc1b-4d01-9df2-74e62176b69e
ou: extendedOpHandlers
objectClass: top
objectClass: organizationalUnit
entryParentId: 31dfbb73-2a0e-40b8-a039-f80a40bde2d8

dn: ads-extendedOpId=gracefulShutdownHandler,ou=extendedOpHandlers,ads-serverId=
 ldapServer,ou=servers,ads-directoryServiceId=default,ou=config
ads-extendedOpId: gracefulShutdownHandler
entryCSN: 20151218031303.040000Z#000000#000#000000
objectClass: top
objectClass: ads-base
objectClass: ads-extendedOpHandler
ads-extendedOpHandlerClass: org.apache.directory.server.ldap.handlers.extended.G
 racefulShutdownHandler
ads-enabled: TRUE
entryUUID: 5fbd4715-262e-41e3-af32-3419544da8e2
entryParentId: ee63c3bf-dc1b-4d01-9df2-74e62176b69e

dn: ads-extendedOpId=pwdModifyHandler,ou=extendedOpHandlers,ads-serverId=ldapSer
 ver,ou=servers,ads-directoryServiceId=default,ou=config
ads-extendedOpId: pwdModifyHandler
entryCSN: 20151218031303.050000Z#000000#000#000000
objectClass: top
objectClass: ads-base
objectClass: ads-extendedOpHandler
ads-extendedOpHandlerClass: org.apache.directory.server.ldap.handlers.extended.P
 wdModifyHandler
ads-enabled: TRUE
entryUUID: 7db4c44b-2b65-4f02-9618-8d76cdf46fe5
entryParentId: ee63c3bf-dc1b-4d01-9df2-74e62176b69e

dn: ads-extendedOpId=starttlshandler,ou=extendedOpHandlers,ads-serverId=ldapServ
 er,ou=servers,ads-directoryServiceId=default,ou=config
ads-extendedOpId: starttlshandler
entryCSN: 20151218031303.047000Z#000000#000#000000
objectClass: top
objectClass: ads-base
objectClass: ads-extendedOpHandler
ads-extendedOpHandlerClass: org.apache.directory.server.ldap.handlers.extended.S
 tartTlsHandler
ads-enabled: TRUE
entryUUID: 7c6c8ccb-a48f-4d76-ae8e-b37fc3894573
entryParentId: ee63c3bf-dc1b-4d01-9df2-74e62176b69e

dn: ads-extendedOpId=storedprochandler,ou=extendedOpHandlers,ads-serverId=ldapSe
 rver,ou=servers,ads-directoryServiceId=default,ou=config
ads-extendedOpId: storedprochandler
entryCSN: 20151218031303.045000Z#000000#000#000000
objectClass: top
objectClass: ads-base
objectClass: ads-extendedOpHandler
ads-extendedOpHandlerClass: org.apache.directory.server.ldap.handlers.extended.S
 toredProcedureExtendedOperationHandler
ads-enabled: FALSE
entryUUID: 4abfca48-9393-4306-a11b-742305354c4f
entryParentId: ee63c3bf-dc1b-4d01-9df2-74e62176b69e

dn: ads-extendedOpId=whoAmIHandler,ou=extendedOpHandlers,ads-serverId=ldapServer
 ,ou=servers,ads-directoryServiceId=default,ou=config
ads-extendedOpId: whoAmIHandler
entryCSN: 20151218031303.043000Z#000000#000#000000
objectClass: top
objectClass: ads-base
objectClass: ads-extendedOpHandler
ads-extendedOpHandlerClass: org.apache.directory.server.ldap.handlers.extended.W
 hoAmIHandler
ads-enabled: TRUE
entryUUID: 48d64798-9503-4a18-a2ae-df7c5defb597
entryParentId: ee63c3bf-dc1b-4d01-9df2-74e62176b69e

dn: ou=replConsumers,ads-serverId=ldapServer,ou=servers,ads-directoryServiceId=d
 efault,ou=config
entryCSN: 20151218031303.018000Z#000000#000#000000
entryUUID: 01c5d246-f9c3-4102-bbf4-39d608ff5a8d
ou: replConsumers
objectClass: top
objectClass: organizationalUnit
entryParentId: 31dfbb73-2a0e-40b8-a039-f80a40bde2d8

dn: ou=saslMechHandlers,ads-serverId=ldapServer,ou=servers,ads-directoryServiceI
 d=default,ou=config
entryCSN: 20151218031303.021000Z#000000#000#000000
entryUUID: db7f2b01-4496-4300-a7f4-9af66d39cef3
ou: saslMechHandlers
objectClass: top
objectClass: organizationalUnit
entryParentId: 31dfbb73-2a0e-40b8-a039-f80a40bde2d8

dn: ads-saslMechName=CRAM-MD5,ou=saslMechHandlers,ads-serverId=ldapServer,ou=ser
 vers,ads-directoryServiceId=default,ou=config
ads-saslMechName: CRAM-MD5
entryCSN: 20151218031303.026000Z#000000#000#000000
objectClass: top
objectClass: ads-saslMechHandler
objectClass: ads-base
ads-saslMechClassName: org.apache.directory.server.ldap.handlers.sasl.cramMD5.Cr
 amMd5MechanismHandler
ads-enabled: TRUE
entryUUID: c6731817-9e07-4974-b2be-f5dfbe3d79de
entryParentId: db7f2b01-4496-4300-a7f4-9af66d39cef3

dn: ads-saslMechName=DIGEST-MD5,ou=saslMechHandlers,ads-serverId=ldapServer,ou=s
 ervers,ads-directoryServiceId=default,ou=config
ads-saslMechName: DIGEST-MD5
entryCSN: 20151218031303.030000Z#000000#000#000000
objectClass: top
objectClass: ads-saslMechHandler
objectClass: ads-base
ads-saslMechClassName: org.apache.directory.server.ldap.handlers.sasl.digestMD5.
 DigestMd5MechanismHandler
ads-enabled: TRUE
entryUUID: a6cb524e-458f-49dd-94e4-f74a36d5654a
entryParentId: db7f2b01-4496-4300-a7f4-9af66d39cef3

dn: ads-saslMechName=GSS-SPNEGO,ou=saslMechHandlers,ads-serverId=ldapServer,ou=s
 ervers,ads-directoryServiceId=default,ou=config
ads-ntlmMechProvider: com.foo.Bar
ads-saslMechName: GSS-SPNEGO
entryCSN: 20151218031303.032000Z#000000#000#000000
objectClass: top
objectClass: ads-saslMechHandler
objectClass: ads-base
ads-saslMechClassName: org.apache.directory.server.ldap.handlers.sasl.ntlm.NtlmM
 echanismHandler
ads-enabled: TRUE
entryUUID: f7be0b1c-d4ec-4722-9860-655e9fbe142e
entryParentId: db7f2b01-4496-4300-a7f4-9af66d39cef3

dn: ads-saslMechName=GSSAPI,ou=saslMechHandlers,ads-serverId=ldapServer,ou=serve
 rs,ads-directoryServiceId=default,ou=config
ads-saslMechName: GSSAPI
entryCSN: 20151218031303.028000Z#000000#000#000000
objectClass: top
objectClass: ads-saslMechHandler
objectClass: ads-base
ads-saslMechClassName: org.apache.directory.server.ldap.handlers.sasl.gssapi.Gss
 apiMechanismHandler
ads-enabled: TRUE
entryUUID: aabdc1d7-1cc3-4ab7-a149-15a68fd005e2
entryParentId: db7f2b01-4496-4300-a7f4-9af66d39cef3

dn: ads-saslMechName=NTLM,ou=saslMechHandlers,ads-serverId=ldapServer,ou=servers
 ,ads-directoryServiceId=default,ou=config
ads-ntlmMechProvider: com.foo.Bar
ads-saslMechName: NTLM
entryCSN: 20151218031303.034000Z#000000#000#000000
objectClass: top
objectClass: ads-saslMechHandler
objectClass: ads-base
ads-saslMechClassName: org.apache.directory.server.ldap.handlers.sasl.ntlm.NtlmM
 echanismHandler
ads-enabled: TRUE
entryUUID: c530b27f-1074-46c7-9fde-65567f5a3a66
entryParentId: db7f2b01-4496-4300-a7f4-9af66d39cef3

dn: ads-saslMechName=SIMPLE,ou=saslMechHandlers,ads-serverId=ldapServer,ou=serve
 rs,ads-directoryServiceId=default,ou=config
ads-saslMechName: SIMPLE
entryCSN: 20151218031303.024000Z#000000#000#000000
objectClass: top
objectClass: ads-saslMechHandler
objectClass: ads-base
ads-saslMechClassName: org.apache.directory.server.ldap.handlers.sasl.SimpleMech
 anismHandler
ads-enabled: TRUE
entryUUID: 659084ba-f28c-41e3-822b-7d2be53746f6
entryParentId: db7f2b01-4496-4300-a7f4-9af66d39cef3

dn: ou=transports,ads-serverId=ldapServer,ou=servers,ads-directoryServiceId=defa
 ult,ou=config
entryCSN: 20151218031303.052000Z#000000#000#000000
entryUUID: 8e028310-3304-4ee1-86d0-764d8bb4b80f
ou: transports
objectClass: top
objectClass: organizationalUnit
entryParentId: 31dfbb73-2a0e-40b8-a039-f80a40bde2d8

dn: ads-transportId=ldap,ou=transports,ads-serverId=ldapServer,ou=servers,ads-di
 rectoryServiceId=default,ou=config
entryCSN: 20151218031303.055000Z#000000#000#000000
ads-transportId: ldap
objectClass: top
objectClass: ads-base
objectClass: ads-transport
objectClass: ads-tcpTransport
ads-systemPort: 10389
ads-transportAddress: 0.0.0.0
ads-enabled: TRUE
entryUUID: f0d4b4fa-0580-4274-9c3c-c19089756afb
ads-transportNbThreads: 8
entryParentId: 8e028310-3304-4ee1-86d0-764d8bb4b80f

dn: ads-transportId=ldaps,ou=transports,ads-serverId=ldapServer,ou=servers,ads-d
 irectoryServiceId=default,ou=config
entryCSN: 20151218031303.058000Z#000000#000#000000
ads-transportId: ldaps
objectClass: top
objectClass: ads-base
objectClass: ads-transport
objectClass: ads-tcpTransport
ads-systemPort: 10636
ads-transportAddress: 0.0.0.0
ads-enabled: TRUE
entryUUID: 6f8a5b0a-fb01-4c98-b49c-2825709ef5e7
ads-transportEnableSsl: TRUE
entryParentId: 8e028310-3304-4ee1-86d0-764d8bb4b80f
```
