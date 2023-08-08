# Nexus3
## docker image
sonatype/nexus3:3.58.1

```
docker pull sonatype/nexus3:3.58.1
```

## step
1. create docker payload file
  ```
  docker run -n \
  --uuid 6e20a5a6-3532-11ee-aa70-334157a8ee03 \
  --name docker-nexus01 \
  --hostname nexus01 \
  -m 4096 \
  -v "data:/nexus-data" \
  sonatype/nexus3:3.58.1
  ```
  - payload file
    ```
    {
      "uuid": "6e20a5a6-3532-11ee-aa70-334157a8ee03",
      "max_physical_memory": 4096,
      "image_uuid": "6b9cd0a6-2e3e-2500-dab6-72861346ac2b",
      "resolvers": [
        "192.168.18.3",
        "8.8.8.8"
      ],
      "nics": [
        {
          "nic_tag": "external",
          "ips": [
            "dhcp"
          ],
          "primary": true,
          "gateway": "192.168.18.1"
        }
      ],
      "hostname": "nexus01",
      "alias": "docker-nexus01",
      "filesystems": [
        {
          "source": "/export/lofs/docker-nexus01/volumes/data",
          "type": "lofs",
          "target": "/nexus-data"
        }
      ],
      "kernel_version": "4.3.0",
      "docker": true,
      "brand": "lx",
      "internal_metadata_namespaces": [
        "itime"
      ],
      "internal_metadata": {
        "docker:cmd": "[\"/opt/sonatype/nexus/bin/nexus\",\"run\"]",
        "docker:env": "[\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"container=oci\",\"SONATYPE_DIR=/opt/sonatype\",\"NEXUS_HOME=/opt/sonatype/nexus\",\"NEXUS_DATA=/nexus-data\",\"NEXUS_CONTEXT=\",\"SONATYPE_WORK=/opt/sonatype/sonatype-work\",\"DOCKER_TYPE=rh-docker\",\"INSTALL4J_ADD_VM_PARAMS=-Xms2703m -Xmx2703m -XX:MaxDirectMemorySize=2703m -Djava.util.prefs.userRoot=/nexus-data/javaprefs\"]",
        "docker:workingdir": "\"/opt/sonatype\"",
        "docker:workdir": "\"/opt/sonatype\"",
        "docker:open_stdin": true,
        "docker:tty": true,
        "itime:network": "default"
      }
    }
    ```
1. change paylad file as needed.
  - default env: `-e 'INSTALL4J_ADD_VM_PARAMS="-Xms2703m -Xmx2703m -XX:MaxDirectMemorySize=2703m -Djava.util.prefs.userRoot=/nexus-data/javaprefs"' \`

1. create docker container with the payload file.
  ```
  docker run -k -f 6e20a5a6-3532-11ee-aa70-334157a8ee03.json
  docker container's ip is 192.168.18.143/24
  Successfully created VM 6e20a5a6-3532-11ee-aa70-334157a8ee03
  ```

## Visit:
- url: `http://192.168.18.143:8081`
- shell: `docker exec -i docker-nexus01 bash`

## Note
1. if the memory less than 4096MB, then must change Xms and Xmx by env var `INSTALL4J_ADD_VM_PARAMS`, the value set to half of memory.
1. first time the `admin` password is saved in file `/nexus-data/admin.password`