# Creating a Custom Certificate Authority for Armory Agent mTLS mode

## Background
Armory Agent is a service that communicates from the target k8s cluster to the Spinnaker control plane (clouddriver via grpc:9091).

To ensure trusted and encrypted communication between Spinnaker and the Agent, we need to configure mutual TLS (mTLS).

## Goal
1. Create a Custom Certificate Authority (Custom CA)
2. Create a certificate for Armory Agent (agent cert) signed by Custom CA
3. Configure Clouddriver - Agent Plugin to use Custom CA
4. Configure Armory Agent to use agent cert.

## Pre-Reqs or Assumptions
* Commands are being run from on Mac OS X
* openssl version LibreSSL 2.8.3

## Step by Step Instructions

### Creating a Custom CA

1. Create a Private Key (ca.key) - this is also known as the private key that will be used to create the Certificate (ca.crt).
** Note: clouddriver requires a pkcs#8 private key **
a. `openssl genpkey -algorithm RSA -out ca.key`
b. `chmod 400 ca.key` 

2. Create the Custom CA Certificate (ca.crt)

using the ca.key we will generate a ca.crt
`openssl req -new -x509 -sha256 -days 730 -key ca.key -out ca.crt`
```
Country Name (2 letter code) []:.
State or Province Name (full name) []:.
Locality Name (eg, city) []:.
Organization Name (eg, company) []:.
Organizational Unit Name (eg, section) []:.
Common Name (eg, fully qualified host name) []:vincent-clouddriver.se.armory.io
Email Address []:.
```
__ QUICK NOTE: This is by far the most important part of configuring mTLS.  We need to ensure that the endpoint the agent is hitting matches the certificate presented.  In this example, the agent is being directed to `vincent-clouddriver.se.armory.io`.  So we need to make sure the certificate uses the same dns in the Common Name. __

Verify the certificate: 
`openssl x509 -noout -text -in ca.crt`

```
❯ openssl x509 -noout -text -in ca.crt
Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number: 14021592652477626861 (0xc296b43a5427f9ed)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=vincent-clouddriver.se.armory.io
        Validity
            Not Before: Nov  4 06:25:46 2020 GMT
            Not After : Nov  4 06:25:46 2022 GMT
        Subject: CN=vincent-clouddriver.se.armory.io
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:c4:81:54:c5:9a:ca:1f:6f:4b:39:a6:5e:5b:05:
                    27:6e:d2:91:1b:55:4a:c5:12:e1:de:6e:10:b5:68:
                    19:a0:4f:3c:b7:96:b1:46:30:1b:84:4a:31:2a:96:
                    45:97:19:a7:d6:81:f8:58:95:62:fc:33:a1:8a:c5:
                    a3:76:b6:38:7f:93:80:ca:6f:9e:15:3e:ab:20:1d:
                    30:65:fd:7e:15:17:43:97:ad:85:c7:0b:51:9b:11:
                    60:21:89:dc:f5:cc:cb:ce:e3:8a:71:71:c8:52:d4:
                    87:62:ec:39:5e:68:f9:93:67:d6:fe:e4:e9:a8:5f:
                    3c:c0:3a:2e:23:18:e6:21:3f:db:84:0b:3b:77:88:
                    d9:2c:ad:17:d3:be:92:b8:56:fb:97:20:c9:76:e5:
                    31:a6:16:39:5c:8a:54:d6:9a:13:9e:31:0a:cc:b5:
                    be:1e:8d:8b:c9:97:01:56:0c:50:17:86:d7:cf:0c:
                    16:0f:ef:95:8e:31:10:48:f9:d7:fc:7e:a3:a0:28:
                    dc:f9:6c:c3:6c:d2:9e:3c:27:77:04:16:e0:03:d5:
                    a5:19:73:59:89:b2:6b:9c:8f:ec:66:db:a1:28:66:
                    08:f9:cb:fb:97:80:ae:1c:41:f3:a6:39:6c:2d:05:
                    6d:95:73:3b:cf:48:29:9f:8b:2f:f0:ac:68:8e:b7:
                    d0:bf
                Exponent: 65537 (0x10001)
    Signature Algorithm: sha256WithRSAEncryption
         17:51:67:45:19:2d:46:c5:64:ee:8f:a5:60:dc:dc:f2:9d:06:
         e6:a5:e8:fb:34:1d:5e:e1:60:1c:3e:d0:7c:1a:e2:3d:c1:75:
         ae:51:2e:c4:21:db:9d:54:57:44:50:41:f5:ac:db:18:41:00:
         a8:4d:c4:09:c0:4d:39:9a:bc:29:6d:65:df:8d:4f:ff:c9:89:
         b6:bf:d0:a3:a2:e6:70:7f:a3:74:fa:3f:4d:43:74:14:63:4b:
         0b:be:4b:82:54:d8:db:a1:2d:e8:96:0c:2d:e0:cc:96:51:5d:
         80:e8:fc:66:eb:f5:e4:30:73:ba:d2:96:32:49:28:d0:57:b7:
         20:9c:c8:6c:0e:47:35:2e:bb:48:e4:0b:3d:cd:81:cf:c3:6c:
         c5:02:32:e4:62:fe:5f:a4:7c:16:6b:0a:98:4c:09:18:0a:50:
         58:0f:c0:e8:a8:5d:7b:95:2b:11:db:06:8a:e8:1b:1d:04:82:
         2c:b4:2a:96:26:87:71:d9:4a:80:41:c5:f0:8d:a1:dd:a0:37:
         07:df:68:ac:e6:e4:56:5e:58:f8:3a:3e:4b:a6:9e:bc:29:5e:
         bc:6c:45:c1:c7:cd:8b:aa:13:a0:63:70:f7:b5:e3:56:51:ef:
         7c:f1:76:fc:0d:4b:96:2a:f0:6e:d6:e0:38:a3:25:66:16:02:
         43:59:2d:8f
```

3. Create the Private Key for agent. (agent.key)
Using the same command above, let's generate another private key, this time for the agent. 

`openssl genrsa -out agent.key 2048`

4. Create a Certificate Signing Request (agent.csr)
This is the intermediary process of creating an agent certificate (agent.crt).  By creating a certificate signing request, we will then ask the Custom CA to "sign" and essentially acknowledge that it trusts the agent.  

`openssl req -new -key agent.key -out agent.csr`

```
Country Name (2 letter code) []:
State or Province Name (full name) []:.
Locality Name (eg, city) []:.
Organization Name (eg, company) []:.
Organizational Unit Name (eg, section) []:.
Common Name (eg, fully qualified host name) []:agent.se.armory.io                  
Email Address []:.

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:armory
```

5. Create the agent certificate (agent.crt) by signing the agent.csr
Using the Custom CA (ca.crt and ca.key) we will sign the agent.csr to generate the agent certififcate (agent.crt)

`openssl x509 -req -in agent.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out agent.crt -days 730 -sha256`


verify:
`openssl x509 -noout -text -in agent.crt`
Sample output: 
```
Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number: 14009896992346818621 (0xc26d271640a5483d)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=vincent-clouddriver.se.armory.io
        Validity
            Not Before: Nov  4 06:41:41 2020 GMT
            Not After : Nov  4 06:41:41 2022 GMT
        Subject: CN=agent.se.armory.io
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:ad:72:c5:23:ca:44:21:88:ed:12:50:7d:80:bd:
                    44:fa:eb:f2:b2:06:82:16:e0:ab:e2:33:40:87:88:
                    81:6c:03:ab:af:88:e1:1a:c9:3b:2f:79:f1:bc:fe:
                    e1:a6:d4:84:0e:d7:c3:d9:bd:d7:17:aa:f1:62:b1:
                    5a:22:08:f3:70:66:1c:39:56:d8:46:e4:79:1e:3b:
                    63:d1:06:3e:d9:30:ab:e0:c0:1c:64:d5:ce:07:19:
                    a1:47:5b:86:8d:d1:1b:7e:64:9d:c6:f1:42:e6:dc:
                    e5:1f:56:0c:bf:ab:c4:22:53:f7:93:ec:6c:04:6e:
                    6a:07:f9:5a:a8:80:a7:af:2a:fc:e6:fe:f7:22:68:
                    08:14:ec:e0:e1:c7:af:ee:c8:c7:a5:26:ac:4f:83:
                    4a:26:07:56:88:3f:d3:3d:a8:71:f6:cd:28:86:2f:
                    f9:d3:ee:ab:f8:de:3c:c0:1c:5e:1c:c9:2b:c0:4a:
                    ac:6d:47:51:d7:c3:a5:1f:19:3a:b6:26:1c:19:5f:
                    64:79:00:e5:2d:f5:f3:c2:8e:60:cd:2a:6e:66:b4:
                    cc:12:40:76:38:d7:55:40:f4:9d:a9:19:52:82:92:
                    3a:bc:83:c7:eb:f2:d4:2e:e2:b4:59:ec:64:aa:f0:
                    fb:a7:a7:2b:bf:f8:9c:f6:50:1e:8e:3f:52:3d:70:
                    0c:a7
                Exponent: 65537 (0x10001)
    Signature Algorithm: sha256WithRSAEncryption
         12:ba:a8:86:6e:23:2e:1e:3d:f1:3b:e3:a9:91:f3:e7:36:60:
         dc:39:23:39:35:c4:72:40:bf:f3:13:c9:72:e9:6b:4b:60:78:
         bf:21:0a:c5:57:d1:a3:57:92:7b:b5:45:75:b2:2f:3a:96:a3:
         30:c8:3e:cd:10:30:33:a2:cd:0d:73:19:fe:c8:c4:d6:27:bb:
         bc:59:ec:2e:b8:b3:e6:c1:71:27:a8:3b:71:ad:b0:1c:ed:32:
         69:74:78:9b:e8:74:df:bd:17:9f:6e:64:51:49:f6:57:88:fd:
         92:bf:d2:95:e1:c2:8a:57:4e:de:74:16:3c:6e:78:2b:13:c8:
         8b:9b:19:01:93:1f:d5:f1:80:62:dc:80:d5:4f:2f:30:42:b9:
         2b:95:04:58:73:99:b9:55:27:96:28:98:6e:3e:9c:c6:d9:47:
         cc:f2:d1:c8:7e:cd:f2:dd:a8:a0:b5:80:4f:da:37:d5:18:27:
         a3:60:69:2e:4b:30:53:4a:fc:c4:26:68:7d:7b:c9:25:b2:cb:
         39:6b:ad:4f:2b:5f:c7:d6:9f:47:48:92:32:40:f3:df:ed:47:
         7b:bc:52:c5:30:33:d2:05:51:ea:d9:97:5a:dd:9f:cc:ca:17:
         11:5b:a1:4c:a0:9c:d5:13:00:14:d2:2f:23:67:04:b4:d7:dd:
         d0:94:fd:20
```

You can see that the certificate was signed by the issuer : vincent-clouddriver.se.armory.io

## Resources:

* Mutual TLS : https://rollout.io/blog/how-to-set-up-mutual-tls-authentication/
* OpenSSL Cheat Sheet : https://www.thesslstore.com/blog/openssl-commands-cheat-sheet/
* Generating PKCS#8 private key https://stackoverflow.com/questions/51055884/generate-pkcs8-private-key-with-openssl