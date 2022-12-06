# percona-server
## docker images
percona/percona-server:8.0.25

```
docker pull percona/percona-server:8.0.25
```

## step
1. create docker payload file
  ```
  docker run -n \
  --uuid 56074bda-fc1a-11eb-be24-13714a29b947 \
  --name docker-mysql01 \
  --hostname mysql01 \
  --network default \
  --ip dhcp \
  -m 2048 \
  -v data:/var/lib/mysql*1001/1001 \
  -v my.cnf:/etc/my.cnf*f*1001 \
  -e "MYSQL_ROOT_PASSWORD=P@ssw0rd" \
  --cmd "mysqld --user=mysql --character-set-server=utf8mb4 --collation-server=utf8mb4_general_ci" \
  percona/percona-server:8.0.25
  ```

  - payload file: 
    ```
    {
      "uuid": "56074bda-fc1a-11eb-be24-13714a29b947",
      "max_physical_memory": 2048,
      "image_uuid": "e06ab307-b572-3e85-1bae-085284df7dfb",
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
      "hostname": "mysql01",
      "alias": "docker-mysql01",
      "filesystems": [
        {
          "source": "/export/lofs/docker-mysql01/volumes/data",
          "type": "lofs",
          "target": "/var/lib/mysql"
        },
        {
          "source": "/export/lofs/docker-mysql01/volumes/my.cnf",
          "type": "lofs",
          "target": "/etc/my.cnf"
        }
      ],
      "docker": true,
      "brand": "lx",
      "kernel_version": "4.3.0",
      "internal_metadata_namespaces": [
        "itime"
      ],
      "internal_metadata": {
        "docker:entrypoint": "[\"/docker-entrypoint.sh\"]",
        "docker:cmd": "[\"mysqld\",\"--user=mysql\",\"--character-set-server=utf8mb4\",\"--collation-server=utf8mb4_general_ci\"]",
        "docker:env": "[\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"PS_VERSION=8.0.25-15.1\",\"OS_VER=el8\",\"FULL_PERCONA_VERSION=8.0.25-15.1.el8\",\"MYSQL_ROOT_PASSWORD=P@ssw0rd\"]",
        "docker:open_stdin": "true",
        "docker:tty": "true",
        "itime:lofs_attr": "[{ \"owner\": \"1001:1001\", \"target\": \"/var/lib/mysql\", \"source\": \"/export/lofs/docker-mysql01/volumes/data\" }, { \"isfile\": true, \"owner\": \"1001\", \"target\": \"/etc/my.cnf\", \"source\": \"/export/lofs/docker-mysql01/volumes/my.cnf\" }]",
        "itime:network": "default"
      }
    }
    ```
1. change paylad file as needed.

1. create docker container with the payload file.
  ```
  [root@smartos02 ~]# docker run -k -f 56074bda-fc1a-11eb-be24-13714a29b947.json
  create temp docker for cp default config file...
  Successfully created VM b817897a-7491-11ed-b1dd-54bf6464aaf5
  remove temp docker...
  Successfully deleted VM b817897a-7491-11ed-b1dd-54bf6464aaf5

  chown -R 1001:1001 /export/lofs/docker-mysql01/volumes/data
  chown -R 1001 /export/lofs/docker-mysql01/volumes/my.cnf
  docker container's ip is 192.168.59.166/24
  Successfully created VM 56074bda-fc1a-11eb-be24-13714a29b947
  ```

## Visit:
IP: 192.168.59.166, 端口: 3306
root/P@ssw0rd

## Noticw
1. --cmd must add the option `--user mysql`,  or init faied.