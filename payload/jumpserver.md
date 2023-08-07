# jumpserver
## docker image
jumpserver/jms_all:v2.13.2

```
docker pull jumpserver/jms_all:v2.13.2
```
## step
1. Genarate SECRET_KEY
  - before update or migration please check `SECRET_KEY` is the same as old version, don't make randon SECRET_KEY, or the database can't be read.
    1. `SECRET_KEY`
      `LC_CTYPE=UTF-8 tr -dc A-Za-z0-9 < /dev/urandom | head -c 50`
    1. `BOOTSTRAP_TOKEN`
      `LC_CTYPE=UTF-8 tr -dc A-Za-z0-9 < /dev/urandom | head -c 16`

1. Sets available env vars:
  - SECRET_KEY = **
  - BOOTSTRAP_TOKEN = **
  - DB_HOST = mysql_host
  - DB_PORT = 3306
  - DB_USER = jumpserver
  - DB_PASSWORD = weakPassword
  - DB_NAME = jumpserver
  - REDIS_HOST = 127.0.0.1
  - REDIS_PORT = 6379
  - REDIS_PASSWORD =

1. create docker payload file
  ```
  docker run -n \
  --uuid 146a432e-07e3-11ec-92bd-b3d7fa240dde \
  --name docker-jumpserver01 \
  --hostname jumpserver01 \
  --network default \
  --ip dhcp \
  -m 2048 \
  -v jumpserver:/opt/jumpserver/data/media \
  -e "SECRET_KEY=XOkr5EqqWPftUP3Xiq4mlOspjr1XVwU5kTxTT7dNVWu2xAu6mf" \
  -e "BOOTSTRAP_TOKEN=5LTjAK14r3DVd7f0" \
  -e "DB_HOST=mysql.itime.biz" \
  -e "DB_USER=jumpserver" \
  -e "DB_PASSWORD=weakPassword" \
  -e "REDIS_HOST=redis01.itime.biz" \
  -e "REDIS_PORT=6379" \
  -e "REDIS_PASSWORD=P@ssw0rd" \
  --entrypoint "/opt/entrypoint.sh" \
  jumpserver/jms_all:v2.13.2
  ```

- payload file: 
  ```
  {
    "uuid": "146a432e-07e3-11ec-92bd-b3d7fa240dde",
    "max_physical_memory": 2048,
    "image_uuid": "94776f5e-213e-2779-da8b-b7da32737af2",
    "resolvers": [
      "192.168.81.253",
      "8.8.8.8"
    ],
    "nics": [
      {
        "nic_tag": "external",
        "ips": [
          "dhcp"
        ],
        "primary": true,
        "gateway": "192.168.59.254",
        "vlan_id": 59
      }
    ],
    "hostname": "jumpserver01",
    "alias": "docker-jumpserver01",
    "filesystems": [
      {
        "source": "/export/lofs/docker-jumpserver01/volumes/jumpserver",
        "type": "lofs",
        "target": "/opt/jumpserver/data/media"
      }
    ],
    "brand": "lx",
    "docker": true,
    "kernel_version": "4.3.0",
    "internal_metadata_namespaces": [
      "itime"
    ],
    "internal_metadata": {
      "docker:entrypoint": "[\"/opt/entrypoint.sh\"]",
      "docker:env": "[\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"Version=v2.13.2\",\"LANG=en_US.utf8\",\"SECRET_KEY=XOkr5EqqWPftUP3Xiq4mlOspjr1XVwU5kTxTT7dNVWu2xAu6mf\",\"BOOTSTRAP_TOKEN=5LTjAK14r3DVd7f0\",\"DB_ENGINE=mysql\",\"DB_HOST=mysql.itime.biz\",\"DB_PORT=3306\",\"DB_USER=jumpserver\",\"DB_PASSWORD=weakPassword\",\"DB_NAME=jumpserver\",\"REDIS_HOST=redis01.itime.biz\",\"REDIS_PORT=6379\",\"REDIS_PASSWORD=P@ssw0rd\",\"CORE_HOST=http://127.0.0.1:8080\",\"LOG_LEVEL=ERROR\"]",
      "docker:workingdir": "\"/opt\"",
      "docker:workdir": "\"/opt\"",
      "docker:open_stdin": true,
      "docker:tty": true,
      "itime:network": "default"
    }
  }
  ```
1. change paylad file as needed.

1. create docker container with the payload file.
  ```
  [root@smartos02 ~]# docker run -k -f 146a432e-07e3-11ec-92bd-b3d7fa240dde.json
  docker container's ip is 192.168.59.98/24
  Successfully created VM 146a432e-07e3-11ec-92bd-b3d7fa240dde
  ```

## Visit:
http://192.168.59.98
admin/admin

## Notice
1. `--entrypoint "/opt/entrypoint.sh"`
  - default is `--entrypoint "./entrypoint.sh"`, this will cause failed for the workdir is uncorrectly
1. must use outside `mysql` and `redis`
1. if mysql version is 8.x, maybe occur error: `RSA Encryption not supported - caching_sha2_password plugin was built with GnuTLS support`
  - change mysql user jumpserver login mode:
    `alter user 'jumpserver'@'%' identified with mysql_native_password by 'weakPassword'`
