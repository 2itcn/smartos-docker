# prometheus
## docker image
prom/prometheus:v2.28.1

```
docker pull prom/prometheus:v2.28.1
```

## step
1. create docker payload file
  ```
  docker run -n \
  --uuid f38a928e-ed67-11eb-8010-1bf1367f470a \
  --name docker-prometheus01 \
  --hostname prometheus01 \
  --network default \
  --ip dhcp \
  -v data:/prometheus*nobody4/nogroup \
  -v prometheus.yml:/etc/prometheus/prometheus.yml*f*nobody4/nogroup \
  prom/prometheus:v2.28.1
  ```
  - payload file: 
    ```
    {
      "uuid": "f38a928e-ed67-11eb-8010-1bf1367f470a",
      "max_physical_memory": 512,
      "image_uuid": "1d6f4b9a-acb0-dcfa-bc0a-29e8833a8ae3",
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
      "hostname": "prometheus01",
      "alias": "docker-prometheus01",
      "filesystems": [
        {
          "source": "/export/lofs/docker-prometheus01/volumes/data",
          "type": "lofs",
          "target": "/prometheus"
        },
        {
          "source": "/export/lofs/docker-prometheus01/volumes/prometheus.yml",
          "type": "lofs",
          "target": "/etc/prometheus/prometheus.yml"
        }
      ],
      "kernel_version": "4.3.0",
      "docker": true,
      "brand": "lx",
      "internal_metadata_namespaces": [
        "itime"
      ],
      "internal_metadata": {
        "docker:entrypoint": "[\"/bin/prometheus\"]",
        "docker:cmd": "[\"--config.file=/etc/prometheus/prometheus.yml\",\"--storage.tsdb.path=/prometheus\",\"--web.console.libraries=/usr/share/prometheus/console_libraries\",\"--web.console.templates=/usr/share/prometheus/consoles\"]",
        "docker:env": "[\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"]",
        "docker:workingdir": "\"/prometheus\"",
        "docker:workdir": "\"/prometheus\"",
        "docker:open_stdin": "true",
        "docker:tty": "true",
        "itime:lofs_attr": "[{ \"owner\": \"nobody4:nogroup\", \"source\": \"/export/lofs/docker-prometheus01/volumes/data\", \"target\": \"/prometheus\" }, { \"isfile\": true, \"owner\": \"nobody4:nogroup\", \"source\": \"/export/lofs/docker-prometheus01/volumes/prometheus.yml\", \"target\": \"/etc/prometheus/prometheus.yml\" }]",
        "itime:network": "default"
      }
    }
    ```
1. change paylad file as needed.

1. create docker container with the payload file.
  ```
  [root@smartos02 ~]# docker run -k -f f38a928e-ed67-11eb-8010-1bf1367f470a.json
  create temp docker for cp default config file...
  Successfully created VM 16bc3068-7495-11ed-b9bd-54bf6464aaf5
  remove temp docker...
  Successfully deleted VM 16bc3068-7495-11ed-b9bd-54bf6464aaf5

  chown -R nobody4:nogroup /export/lofs/docker-prometheus01/volumes/data
  chown -R nobody4:nogroup /export/lofs/docker-prometheus01/volumes/prometheus.yml
  docker container's ip is 192.168.59.111/24
  Successfully created VM f38a928e-ed67-11eb-8010-1bf1367f470a
  ```

## Visit:
http://192.168.59.111:9090
