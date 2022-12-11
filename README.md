# smartos-docker
smartos-docker is a tool help manage docker on SmartOS GZ 
- create a payload file for create docker container on SmartOS GZ
- create docker container from a payload file
- manage docker image and container

## Setup
1. clone the repository
    ```
    git clone https://github.com/2itcn/smartos-docker.git
    ```
1. change src/smartos-docker.conf as your env
    ```
    {
        "networks": [
            {
                "name": "default", 
                "tag": "external", 
                "gw": "192.168.18.1",
                "netmask": 24,
                "resolvers": [
                    "192.168.18.1",
                    "8.8.8.8"
                ],
                "desc": "default network"
            },
            {
                "name": "vlan1", 
                "tag": "external", 
                "vlan_id": 1, 
                "netmask": 24,
                "gw": "192.168.1.1",
                "resolvers": [
                    "192.168.1.1",
                    "8.8.8.8"
                ],
                "desc": "network with vlan 1"
            }
        ],
        "volume_base_store": "/export/lofs"
    }
    ```
    - networks: config networks that for docker container use
        - name: network name, there must have a network with name "default", this is the default network for docker container
        - tag: nic_tag for the network
        - gw: gateway for the network
        - vlan_id: vlan id for the network, default is 0, means no vlan
        - netmask: netmask for the network
        - resolvers: nameservers for the network
        - desc: description for the network
    - volume_base_store: the lofs mount base path for docker volume
        - must be a zfs dataset
        - the volume lofs path is ${volume_base_store}/${container}/volumes/{volume_name}
            - volume is a zfs dataset
            - container: docker container name or docker container uuid
            - volume_name: docker volume name

1. setup
    ```
    chmod +x setup.sh
    ./setup.sh
    ```
    - config file is copied to `/opt/tools/etc/smartos-docker.conf`
    - smartos-docker has copied to `/opt/tools/bin/smartos-docker`, and linked as `/opt/tools/bin/docker`

1. test
    ```
    docker -h
    ```  
    or   
    ```
    smartos-docker -h
    ```

**IMPORTANT**
- before setup ensure the pkgin tools is installed at SmartOS GZ
- add docker hub sources to image sources
    - add official docker hub
        ```
        imgadm sources --add-docker-hub
        ```
    - add a custom docker hub
        ```
        imgadm sources -a https://docker.io -t docker
        ```
- create `volume_base_store` dataset config in `/opt/tools/etc/smartos-docker.conf`.
## SYNOPSIS
- `docker --help|-h`  
show usage

- `docker [run] [-n] [[-k] -f <payload_file>] [--ports|-p <ports>] [--uuid <container_uuid>] [--name <name>] [--hostname <hostname>] [--memory|-m <memory>] [--cpu_cap <cpu_cap>] [--cpu_shares <cpu_shares>] [--io <io_priority>] [--quota <quota>] [--network <network_name>] [--ip <ip>] [--nic_tag <nic_tag>] [--gateway <gateway>] [--vlan <vlan_id>] [--resolver <resolver>] [--lofs_volume|-v <lofs_volume>] [--kernel_version <kernel_version>] [--workdir <workdir>] [--env|-e <env>] [--entrypoint <entrypoint>] [--cmd <cmd>] [--image_uuid <image_uuid> | <docker_image>]`  
create docker payload file and container

- `docker start  <container>`  
start docker container, ensure docker container status on `running`.

- `docker stopt [-f|-t <timeout>] <container>`   
stop docker container, ensure docker container status on `stopped`.

- `docker restart [-f]  <container>`  
restart docker container, ensure docker container status from `stopped` to `running`.

- `docker rm [-f]  <container>`  
remove/delete docker container, the volume would not be deleted after container deleted.

- `docker logs [-f] <container>`  
show docker container's logs

- `docker pull [-q] <docker_image>`    
pull docker image

- `docker ps [--all|-a]`   
show docker containers

- `docker images [--all|-a]`   
show docker images

- `docker rmi <image_uuid>`   
remove docker image

- `docker version`   
show smartos-docker verison

- `docker help <sub_command>`   
show docker sub command usage

## SUBCOMMANDS
### docker --help|-h
show usage

### docker run
- `docker run [-n] [[-k] -f <payload_file>] [--ports|-p <ports>] [--uuid <container_uuid>] [--name <name>] [--hostname <hostname>] [--memory|-m <memory>] [--cpu_cap <cpu_cap>] [--cpu_shares <cpu_shares>] [--io <io_priority>] [--quota <quota>] [--network <network_name>] [--ip <ip>] [--nic_tag <nic_tag>] [--gateway <gateway>] [--vlan <vlan_id>] [--resolver <resolver>] [--lofs_volume|-v <lofs_volume>] [--kernel_version <kernel_version>] [--workdir <workdir>] [--env|-e <env>] [--entrypoint <entrypoint>] [--cmd <cmd>] [--image_uuid <image_uuid> | <docker_image>]`  
    create a new payload file at the current directory named with `<container_uuid>.json` and create the docker container. if `-n` option is setted, then only create a new payload file and NOT create the docker container.  
    if `-f <payload_file>` and any options were provided. the options's value is used. and the options's value will override the properties on the new payload file.   
    ***volume lofs filesystems*** the lofs-volume source filesystem creatition followed by the rules:    
    1. if `source` path is exists on SmartOS GZ, doing nothing, else go next.
    1. if `source` is `create-volume` , then create local dataset, see as `lofs_volume` below. else go next.
    1. if `source` parent is an exists filesystem, then create all sub-filesystem on the parent-filesystem. else go next
    1. if `source` can't find an exists parent filesystem, failed. 
        - failed as current action. 
        - maybe create the source path on SmartOS GZ insteed create filesystem?
        - config a base filesystem, all lofs volume be create on the filesystem, like `<base_filesystem>/<vm_uuid>/sub_path`?

    - `[-f <payload_file>]` base payload file
    - `[-k]` skip payload file property replace, only used with `-f`
    - `[-n]` skip create docker container, only genarate payload file
    - `[--ports|-p <ports>]` export port, formart as `-p 80` or -p `"80 443"`
        - can set many times
        - managed by fwadm rule.
        - if setted, only the special ports can be accessed outside the docker container, and the zones `firewall_enabled` is set true.
        - default all ports can be accessed outside the docker container.
    - `[--uuid <container_uuid>]` special the docker container's uuid, if not set, a randon uuid will be set.
        - zone's `uuid`
    - `[--name <name>]` special the docker container's name, if not set, default is `-`.
        - zone's `alias`
    - `[--hostname <hostname>]` special the docker container's hostname, if not set, default is the container's uuid
        - zone's `hostname`
    - `[--memory|-m <memory>]` special the docker container's memory, unit is MB, if not set, default is 512.
        - zone's `max_physical_memory`
    - `[--cpu_cap <cpu_cap>]` Sets a limit on the amount of CPU time for the docker container, The unit used is the percentage of a single CPU that can be used, Eg. 300 means up to 3 full cpus, 0 means no limited
        - zone's `cpu_cap`
    - `[--cpu_shares <cpu_shares>]` Sets a limit on the number of fair share scheduler (FSS) CPU shares for docker container. the container with 50 will get 5x as much time from the scheduler as the one with 10 when there is contention.
        - zone's `cpu_shares`
    - `[--io <io_priority>]` Sets an IO throttle priority value relative to other zones, If one zone has a value X and another zone has a value 2X, the zone with the X value will have some of its IO throttled when both try to use all available IO. default value is `100`.
        - zone's `zfs_io_priority`
    - `[--quota <quota>]` Sets a quota on the zone filesystem for the docker container. the unit is `GB`
        - zone's quota
    - `[--network <network_name>]` Sets network for the docker container. default value is `default`
        - network name must be configed in `smartos-docker.conf`
    - `[--ip <ip>]` Sets ip address for the docker container. default value is `dhcp`
        - format as:
            - `xxx.xxx.xxx.xxx/xx`
            - `xxx.xxx.xxx.xxx` the netmask read from the selected network configuration, if not configed, return `24`.
            - `dhcp` from dhcp server, and then the ip will be set as static ip in new payload file after docker container created.
    - `[--nic_tag <nic_tag>]` Sets the nic_tag for docker container, default read from the selected network configuration, if not configed, return `admin`.
    - `[--gateway <gateway>]` Sets the gateway for docker container, default read from the selected network configuration, if not configed, will be ignored.
        - format as `xxx.xxx.xxx.xxx`
    - `[--vlan <vlan_id>]` Sets the vlan_id for docker container, default read from the selected network configuration, if not configed, will be ignored.
    - `[--resolver <resolver>]` Sets the vlan_id for docker container, default read from the selected network configuration
        - format as `<ips>`
            - `xxx.xxx.xxx.xxx`
            - `"xxx.xxx.xxx.xxx xxx.xxx.xxx.xxx"`
        - can be set many times
        - if not set and network not configed, default is: `"8.8.8.8 4.4.4.4"`
    - `[--lofs_volume|-v <lofs_volume>]` Sets lofs volume for the docker container.
        - volume mount as filesystems
        - can set many times
        - format as `[<source>]:<target>[:<options>]` or `"[<source>]:<target>[:<options>] [<source>]:<target>[:<options>] ..."`
            - `source`: directory or file on SmartOS GZ
                - if the source not start with `/`, then the source path is `${volume_base_store}/${source}`, `volume_base_store` is configed in `smartos-docker.conf` file.
                - in new SmartOS(PI >= `20210506T001621Z`) can be omited, SmartOS GZ screate a zfs filesystem on: `/zones/<vm_uuid>/volumes/<volume_uuid>`
                - if the source not exists in SmartOS GZ
                    - `Directory` the source directory will be auto-created before docker container creating.
                        - create as zfs dataset, failed if create zfs dataset failed.
                    - `File` if the directory path not exists, the directory will be auto-created before docker container creating.
                        - create as zfs dataset, failed if create zfs dataset failed.
                        - copy the container target file to the source path.
                - if `source` not exists before docker container creating and `target` has owner `flag`. then after `source` created the `chown` cmd will be executed. 
            - `target`: the mount path in docker container. format as `<path>[*flag[*flag]]`
                - `path` the mount path in docker container
                - `flag` target flag
                    - `f` file flag, means the volume is a file, the flag must be first flag, if not set the flag, means the volume is a directory
                    - `<uid>[/<gid>]` owner flag, means volume's owner.
                        - `1000` act `chown -R 1000`
                        - `/1000` act `chown -R :1000`
                        - `1000/1000` act `chown -R 1000:1000`
                        - is it get from a temp conainer better? like `dhcp` ip.
            - `options`: mount options, just lofs mount options
                - `ro`
    - `[--kernel_version <kernel_version>]` linux kernel version, default value is `4.3.0`(ubuntu-20.04)
    - `[--workdir <workdir>]` Sets work dir for the docker container, default read from the docker image.    
    - `[--env|-e <env>]` Sets environment variables for the docker container.
        - can be set many times
        - format as `--env var1=value1` or `--env "var1=value1 var2=value2"`
        - ** will add or replace default env var **
    - `[--entrypoint <entrypoint>]` Sets Entrypoint for the docker container
        - can be set many times. the follows is equal.
            - `--entrypoint bash --entrypoint scriptfile`
            - `--entrypoint "bash scriptfile"`
        - **will `replace` the default Entrypoint**
    - `[--cmd <cmd>]` Sets Cmd for the docker container
        - can be set many times. the follows is equal.
            - `--cmd bash --cmd scriptfile`
            - `--cmd "bash scriptfile"`
        - **will `replace` the the default Cmd**
    - `[--image_uuid <image_uuid>]` docker image uuid, if the option setted, the `<image_name>` arg will be ignored
    - `<docker_image>` docker image
        - if provide the arg, must be the end of the command.
        - if `--uuid <image_uuid>` is setted, the arg will be ignored.
        - format as `<image_name>[:<tag>]`
            - if `<tag>` not provided, then set tag as `latest`       


### docker logs
- `smartos-docker logs [-f] <container>`  
show docker container logs

    - `[-f]` trace logs
    - `<container>` docker container name or uuid

### docker pull
- `docker pull [-q] <docker_image>`  
pull docker image

    - `[-q]` quiet mode, if set, will not show the download progress.
    - `docker_image` docker image
        - format as `<image_name>[:<tag>]`
            - if `<tag>` not provided, the default tag is `latest`

### docker images
- `docker images [--all|-a]`   
list downloaded images on the host.

    - `[--all|-a]` show all layers

### docker rmi
- `docker rmi <image_uuid>`   
remove/delete a docker image

    - `<image_uuid>` the uuid of the docker image than want to be deleted

### docker ps
- `docker ps [--all|-a]` 
list running docker containers on the host.

    - `[--all|-a]` list all docker containers on the host. even not in running state.

### docker port
- `port [-a <ports>] [-d <ports>] <container>`  
add/remove container ports for access from outside.  
if the container not enabled firewall, the cmd has no effect

    - `-a <ports>` add ports for access from outside.
        - format as -a 80 or -a "80 443 ..."
        - can set many times
    - `-d <ports>` remove ports for access from outside.
        - format as -d 80 or -d "80 443 ..."
        - can set many times

### docker version 
- `docker version` 
show smartos-docker version.

### docker help
- `docker help <sub_command>`  
show docker sub command usage

    - `sub_command`: sub command, one of: `run|pull|ps|logs|images|start|stop|restart|rm|rmi|help`

## payload file
payload file is LX brand vm metadata json file with docker special properties. any LX brand vm properties can alse be add to the file.  
if all lofs volume already exists in SmartOS GZ and IP is not `dhcp` then can use `vmadm create -f paylaod.json` create the docker container.  
use docker cli create docker container is recommanded.
```
docker run -k -f payload.json
```

1. min properties
    - `image_uuid`: docker image uuid, and the image must be imported to host already.
        `imgadm import <image_name>[:<image_tag>]` or `docker pull <image_name>[:<image_tag>`        
    - `nics`: must set a static ip, or the container can't access outside the container.
        - `dhcp`, when `--ip` set to `dhcp`, before docker container creating, the docker cli create a template zone. when recieve an ip from the dhcp server,  delete the temp zone, and set the ip to the payload file.
    - example:
        ```
        {        
            "image_uuid": "62dbd888-dfde-11eb-8a0e-73655000bf44",        
            "nics": [
                {
                    "nic_tag": "external",
                    "ips": [
                        "192.168.18.52/24"
                    ],
                    "gateway": "192.168.18.1",
                    "primary": true
                }
            ]
        }
        ```
1. max properties
    - ref to os zone properties (https://www.smartos.org/man/1m/vmadm)

## EXAMPLES
### Example 1: show usage
```
[root@smartos02 ~]# docker -h
Usage
    docker --help|-h
    docker run [-n] [[-k] -f <payload_file>] [--ports|-p <ports>] [--uuid <container_uuid>] [--name <name>] [--hostname <hostname>] [--memory|-m <memory>] [--cpu_cap <cpu_cap>] [--cpu_shares <cpu_shares>] [--io <io_priority>] [--quota <quota>] [--network <network_name>] [--ip <ip>] [--nic_tag <nic_tag>] [--gateway <gateway>] [--vlan <vlan_id>] [--resolver <resolver>] [--lofs_volume|-v <lofs_volume>] [--kernel_version <kernel_version>] [--workdir <workdir>] [--env|-e <env>] [--entrypoint <entrypoint>] [--cmd <cmd>] [--image_uuid <image_uuid> | <docker_image>]
    docker logs [-f] <container>
    docker pull [-q] <docker_image>
    docker ps [--all|-a]
    docker images [--all|-a]
    docker rmi <image_uuid>
    docker start <container>
    docker stop [-f|-t <timeout>] <container>
    docker restart [-f] <container>
    docker rm [-f] <container>
    docker help <sub_command>
```

### Example 2: show `docker pull` usage
```
[root@smartos02 ~]# docker help pull
Usage
    docker pull [-q] <docker_image>
        pull docker image
        args:
            <docker_image> docker image, format as <image_name>[:<tag>], if <tag> not provided, the default tag is latest
        options:
            -q quiet mode, if set, will not show the download progress
```
### Example 3: pull a latest docker image
```
[root@smartos02 ~]# docker pull minio/minio
Importing 7ee3021f-c1ed-9f08-4ff2-9ea4a70a4c03 (docker.io/minio/minio:latest) from "https://registry.example.com"
Gather image 7ee3021f-c1ed-9f08-4ff2-9ea4a70a4c03 ancestry
Must download and install 6 images
Downloaded image 952e0732-5dd6-c914-d7bf-3416b2f90279 (507.0 B)
Downloaded image 7004533b-05b5-a254-1df2-f92306eea39e (528.0 B)
Downloaded image 60ca3e70-50b6-4c12-c9e3-764d8aa94ff3 (11.6 KiB)
Downloaded image f38c9091-45af-cdad-8c8d-186fc82c785a (144.8 KiB)
Downloaded image b909afc8-27aa-2bf7-dcdc-62306e0fda12 (37.8 MiB)
Imported image b909afc8-27aa-2bf7-dcdc-62306e0fda12 (docker-layer@a6577091999b)
Downloaded image 7ee3021f-c1ed-9f08-4ff2-9ea4a70a4c03 (72.0 MiB)
Download 6 images                               [=========================================================================================================>] 100% 109.98MB   3.48MB/s    31s
Imported image 952e0732-5dd6-c914-d7bf-3416b2f90279 (docker-layer@50056b273c23)
Imported image 7004533b-05b5-a254-1df2-f92306eea39e (docker-layer@322456145f44)
Imported image f38c9091-45af-cdad-8c8d-186fc82c785a (docker-layer@98d4231f1ceb)
Imported image 60ca3e70-50b6-4c12-c9e3-764d8aa94ff3 (docker-layer@b3a99ef00ca4)
Imported image 7ee3021f-c1ed-9f08-4ff2-9ea4a70a4c03 (docker-layer@53c0509e0994)
```

### Example 4: run docker container with less options. only get the payload file, not create docker container.
```
[root@smartos02 ~]# docker run -n --cmd 'minio server /data --console-address :9001' minio/minio
payload file saved at f115014a-7486-11ed-aa33-54bf6464aaf5.json

{
  "uuid": "f115014a-7486-11ed-aa33-54bf6464aaf5",
  "max_physical_memory": 512,
  "image_uuid": "7ee3021f-c1ed-9f08-4ff2-9ea4a70a4c03",
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
  "kernel_version": "4.3.0",
  "brand": "lx",
  "docker": true,
  "internal_metadata": {
    "docker:entrypoint": "[\"/usr/bin/docker-entrypoint.sh\"]",
    "docker:cmd": "[\"minio\",\"server\",\"/data\",\"--console-address\",\":9001\"]",
    "docker:env": "[\"PATH=/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"container=oci\",\"MINIO_ACCESS_KEY_FILE=access_key\",\"MINIO_SECRET_KEY_FILE=secret_key\",\"MINIO_ROOT_USER_FILE=access_key\",\"MINIO_ROOT_PASSWORD_FILE=secret_key\",\"MINIO_KMS_SECRET_KEY_FILE=kms_master_key\",\"MINIO_UPDATE_MINISIGN_PUBKEY=RWTx5Zr1tiHQLwG9keckT0c45M3AGeHD6IvimQHpyRywVWGbP1aVSGav\",\"MINIO_CONFIG_ENV_FILE=config.env\"]",
    "docker:open_stdin": true,
    "docker:tty": true,
    "itime:network": "default"
  },
  "internal_metadata_namespaces": [
    "itime"
  ]
}
```
- `-n` option means NOT create docker container

### Example 4: create a docker container from a payload file. skip the payload file replace.
```
[root@smartos02 ~]# docker run -k -f f115014a-7486-11ed-aa33-54bf6464aaf5.json
docker container's ip is 192.168.59.63/24
Successfully created VM f115014a-7486-11ed-aa33-54bf6464aaf5
```
- `-k` option means NOT replace payload file with options
### Example 5: list all docker containers
```
[root@smartos02 ~]# docker ps -a
UUID                                  TYPE  RAM      CPU_CAP  CPU_SHARE  QUOTA  STATE             ALIAS
4dcfad04-7478-11ed-b86b-54bf6464aaf5  LX    512      -        100        10     stopped           docker-minio01
f115014a-7486-11ed-aa33-54bf6464aaf5  LX    512      -        100        10     running           -
```
- `-a` options means list all docker container, even not in `running` state

### Example 6: Create docker payload with static ip and more options
```
[root@smartos02 ~]# docker run -n \
> --uuid d89700e0-0895-11ec-a012-2f97c366acc7 \
> --name docker-redis01 \
> --hostname redis01 \
> --network default \
> --ip 192.168.59.168 \
> --memory 2048 \
> --lofs_volume data:/data \
> --cmd "redis-server --appendonly yes --requirepass P@ssw0rd" \
> redis:6.2.5-alpine
Importing 45addd62-943a-c1e7-9233-d28ccfa7eba7 (docker.io/redis:6.2.5-alpine) from "https://registry.example.com"
Gather image 45addd62-943a-c1e7-9233-d28ccfa7eba7 ancestry
Must download and install 6 images
Downloaded image 9bc77c47-ac49-9875-f52c-f03c143a044f (1.2 KiB)
Downloaded image 45addd62-943a-c1e7-9233-d28ccfa7eba7 (413.0 B)
Downloaded image 7f414eae-9fa0-e3c9-c98d-2d99dacaf9de (134.0 B)
Downloaded image 42342a52-3588-1434-dad8-40c3a235e139 (375.4 KiB)
Downloaded image cd2acbde-5f97-e3ae-5579-d61417bcc160 (7.3 MiB)
Downloaded image 31bd3228-bb7c-bf8b-f3be-26cbe7967bda (2.6 MiB)
Imported image 31bd3228-bb7c-bf8b-f3be-26cbe7967bda (docker-layer@a0d0a0d46f8b)
Imported image 9bc77c47-ac49-9875-f52c-f03c143a044f (docker-layer@a04b0375051e)
Imported image 42342a52-3588-1434-dad8-40c3a235e139 (docker-layer@cdc2bb0f9590)
Imported image cd2acbde-5f97-e3ae-5579-d61417bcc160 (docker-layer@8f19735ec10c)
Imported image 7f414eae-9fa0-e3c9-c98d-2d99dacaf9de (docker-layer@ac5156a4c6ca)
Imported image 45addd62-943a-c1e7-9233-d28ccfa7eba7 (docker-layer@7b7e1b3fdb00)
payload file saved at d89700e0-0895-11ec-a012-2f97c366acc7.json

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
  "kernel_version": "4.3.0",
  "brand": "lx",
  "docker": true,
  "internal_metadata_namespaces": [
    "itime"
  ],
  "internal_metadata": {
    "docker:entrypoint": "[\"docker-entrypoint.sh\"]",
    "docker:cmd": "[\"redis-server\",\"--appendonly\",\"yes\",\"--requirepass\",\"P@ssw0rd\"]",
    "docker:env": "[\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"REDIS_VERSION=6.2.5\",\"REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-6.2.5.tar.gz\",\"REDIS_DOWNLOAD_SHA=4b9a75709a1b74b3785e20a6c158cab94cf52298aa381eea947a678a60d551ae\"]",
    "docker:workingdir": "\"/data\"",
    "docker:workdir": "\"/data\"",
    "docker:open_stdin": true,
    "docker:tty": true,
    "itime:network": "default"
  }
}
```
- if the image is not pulled before `run`, will auto pull image first

### Example 7: create a docker container from a payload file. skip the payload file replace.
```
[root@smartos02 ~]# docker run -k -f d89700e0-0895-11ec-a012-2f97c366acc7.json
Successfully created VM d89700e0-0895-11ec-a012-2f97c366acc7
```

### Example 8: Create docker container directly.
```
[root@smartos02 ~]# docker run \
> --uuid d89700e0-0895-11ec-a012-2f97c366acc7 \
> --name docker-redis01 \
> --hostname redis01 \
> --network default \
> --ip 192.168.59.168 \
> --memory 2048 \
> --lofs_volume data:/data \
> --cmd "redis-server --appendonly yes --requirepass P@ssw0rd" \
> redis:6.2.5-alpine
payload file saved at d89700e0-0895-11ec-a012-2f97c366acc7.json
Successfully created VM d89700e0-0895-11ec-a012-2f97c366acc7
```
- without `-n` option, the run cmd will create a new payload file and create docker container with the new payload file.

### Example 9: Delete docker container
```
[root@smartos02 ~]# docker rm -f d89700e0-0895-11ec-a012-2f97c366acc7
Successfully deleted VM d89700e0-0895-11ec-a012-2f97c366acc7
```
- `-f` option means force delete, even the docker container in `running` state

## Recommended Step for Docker Cli
1. Config networks and volume_base_store.
1. Create a payload doc file for each docker image.(see `payload` dir)
    - docker image and tag
    - the cmd of `docker run`
    - the payload file
    - create docker image from payload file
    - add notices if have any
1. some of docker container creation maybe failed without correct options.
    - check image config info and set your own options of `docker run`
        ```
        imgadm get image_uuid | json manifest.tags.docker:config
        ```
        - it best to create a payload doc file for share the options. 

## TODO:
1. add nfs volume
1. auto check lofs_volume owner.
~~1. fwadm integrate~~
1. innernet ip

