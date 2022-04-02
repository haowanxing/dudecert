# DudeCert - A SSL Certificates Tools

This image can used for:

1. Generate a RootCA which can signed a AgentCA certificates.
2. Generate a AgentCA which can signed a client certificates. such as ssl(https) etc.
3. Request a cerificate with private.key/req.csr/openssl.cnf or even nothing but just follow the terminal tips.

## Simple usage

```bash
docker pull haowanxing/dudecert:latest
docker run --rm -it haowanxing/dudecert:latest
```

## Advance usages

### With a CSR file

you can use your own openssl to gain a csr file or use online tool (eg: [chinassl-generator](https://www.chinassl.net/ssltools/generator-csr.html))

```sh
docker run --rm -it -v /path/to/domain.csr:/opt/site/site.csr haowanxing/dudecert:latest
```

### With a private key

```sh
docker run --rm -it -v /path/to/private.key:/opt/site/privkey.pem haowanxing/dudecert:latest
```

### With an old CA data

```sh
docker run --rm -it -v /path/to/ca.key:/opt/ca/agent/key/cakey.pem -v /path/to/ca.crt:/opt/ca/agent/key/cacert.crt haowanxing/dudecert:latest
```

### Sign a agentCA with an old rootCA data

> let's try.

## Volumns & Files

```sh
/ # tree /opt/
/opt/
├── ca
│   ├── agent
│   │   ├── index.txt
│   │   ├── index.txt.attr
│   │   ├── index.txt.attr.old
│   │   ├── index.txt.old
│   │   ├── key
│   │   │   ├── ca.csr
│   │   │   ├── cacert.crt
│   │   │   └── cakey.pem
│   │   ├── newcerts
│   │   │   └── 01.pem
│   │   ├── openssl.cnf
│   │   ├── serial
│   │   └── serial.old
│   └── root
│       ├── index.txt
│       ├── index.txt.attr
│       ├── index.txt.attr.old
│       ├── index.txt.old
│       ├── key
│       │   ├── ca.csr
│       │   ├── cacert.crt
│       │   └── cakey.pem
│       ├── newcerts
│       │   ├── 01.pem
│       │   └── 02.pem
│       ├── openssl.cnf
│       ├── serial
│       └── serial.old
├── entrypoint.sh
└── site
    ├── privkey.pem
    ├── site.cnf
    ├── site.crt
    └── site.csr

8 directories, 28 files
```

|      Dir&File       |              Comment              |
|:-------------:| :----------------------------: |
|     `/opt`     |            working dir            |
|   `/opt/ca`   |        certificate authority dir         |
|   `/opt/ca/root`   |        root data         |
|   `/opt/ca/agent`   |        agent data         |
|   `/opt/ca/(root/agent)/key/ca.csr`   |        cerificate signing request file        |
|   `/opt/ca/(root/agent)/key/cacert.crt`   |        ca certificate         |
|   `/opt/ca/(root/agent)/key/cakey.pem`   |        ca private key         |
|   `/opt/ca/(root/agent)/newcerts`   |        signed certificates dir        |
|   `/opt/ca/(root/agent)/openssl.cnf`   |        openssl config file       |
| `/opt/site`  |              store site temp files              |
