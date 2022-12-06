# redis
## docker image
redis:6.2.5-alpine

```
docker pull redis:6.2.5-alpine
```

## step
1. create docker payload file
  ```
  docker run -n \
  --uuid d89700e0-0895-11ec-a012-2f97c366acc7 \
  --name docker-redis01 \
  --hostname redis01 \
  --network default \
  --ip 192.168.59.168 \
  --memory 2048 \
  --lofs_volume data:/data \
  --cmd "redis-server --appendonly yes --requirepass P@ssw0rd" \
  redis:6.2.5-alpine
  ```

  - payload file: 
    ```
    {
      "uuid": "d89700e0-0895-11ec-a012-2f97c366acc7",
      "max_physical_memory": 2048,
      "image_uuid": "45addd62-943a-c1e7-9233-d28ccfa7eba7",
      "resolvers": [
        "192.168.81.253",
        "8.8.8.8"
      ],
      "nics": [
        {
          "nic_tag": "external",
          "ips": [
            "192.168.59.168/24"
          ],
          "primary": true,
          "gateway": "192.168.59.254",
          "vlan_id": 59
        }
      ],
      "hostname": "redis01",
      "alias": "docker-redis01",
      "filesystems": [
        {
          "source": "/export/lofs/docker-redis01/volumes/data",
          "type": "lofs",
          "target": "/data"
        }
      ],
      "brand": "lx",
      "docker": true,
      "kernel_version": "4.3.0",
      "internal_metadata": {
        "docker:entrypoint": "[\"docker-entrypoint.sh\"]",
        "docker:cmd": "[\"redis-server\",\"--appendonly\",\"yes\",\"--requirepass\",\"P@ssw0rd\"]",
        "docker:env": "[\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"REDIS_VERSION=6.2.5\",\"REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-6.2.5.tar.gz\",\"REDIS_DOWNLOAD_SHA=4b9a75709a1b74b3785e20a6c158cab94cf52298aa381eea947a678a60d551ae\"]",
        "docker:workingdir": "\"/data\"",
        "docker:workdir": "\"/data\"",
        "docker:open_stdin": "true",
        "docker:tty": "true",
        "itime:network": "default"
      },
      "internal_metadata_namespaces": [
        "itime"
      ]
    }
    ```

1. change paylad file as needed.

1. create docker container with the payload file.
  ```
  [root@smartos02 ~]# docker run -k -f d89700e0-0895-11ec-a012-2f97c366acc7.json
  Successfully created VM d89700e0-0895-11ec-a012-2f97c366acc7
  ```

## Visit:
ip: 192.168.59.168, port: 6379
password: P@ssw0rd

## Notice