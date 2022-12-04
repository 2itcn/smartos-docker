# smartos-docker
smartos-docker is a tool help manage docker on SmartOS GZ 
- create a payload file for create docker container on SmartOS GZ
- create docker container from a payload file
- manage docker image and container

## Setup
1. clone the repository
    ```
    https://github.com/2itcn/smartos-docker.git
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
    - config file is copied to /opt/tools/etc/smartos-docker.conf
    - smartos-docker is copied to /opt/tools/bin/smartos-docker, and linked as /opt/tools/bin/docker

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
## SYNOPSIS
- docker -h  
show usage help

- docker [run] [options] [<docker_image>]  
create docker container

- docker logs [-f] <container>  
show docker container's logs

- docker pull [-q] <docker_image>  
pull docker image

- docker ps  
show docker containers

- docker images  
show docker images

- docker help <sub_command>  
show docker sub command usage

## SUBCOMMANDS
### docker -h
show usage help

### docker [run]
- docker [run] [-n] [-f <payload_file> [-k]] [--uuid <container_uuid>] [--name <name>] [--hostname <hostname>] [--memory <memory>] [--cpu_cap <cpu_cap>] [--cpu_shares <cpu_shares>] [--quota <quota>] [--network <network_name>] [--ip <ip>] [--nic_tag <nic_tag>] [--gateway <gateway>] [--vlan <vlan_id>] [--resolver <resolver>] [--lofs_volume <lofs_volume>] [--workdir <workdir>] [--env <env>] [--entrypoint <entrypoint>] [--cmd <cmd>] [--image_uuid <image_uuid> | <docker_image> ]  
    create a new payload file at the current directory named with `<container_uuid>.json` and create the docker container. if `-n` option is setted, then only create a new payload file and NOT create the docker container.

    - `[-f <payload_file>]` base payload file,
    - `[-k]` skip pattern match and replace, only use with `-f`
    - `[-n]` skip create docker container, only genarate payload file
    - `[--uuid <container_uuid>]` special the docker container's uuid, if not set, a randon uuid will be set.
        - zone's uuid
    - `[--name <name>] special the docker container's name, if not set, default is `-`.
        - zone's alias
    - `[--hostname <hostname>]` special the docker container's hostname, if not set, default is the container's uuid
        - zone's hostname
    - `[--memory <memory>]` special the docker container's memory, unit is MB, if not set, default is 512.
        - zone's max_physical_memory
    - `[--cpu_cap <cpu_cap>]` Sets a limit on the amount of CPU time for the docker container, The
        unit used is the percentage of a single CPU that can be used, Eg. 300 means up to 3 full cpus, 0 means no limited
        - zone's cpu_cap
    - `[--cpu_shares <cpu_shares>]` Sets a limit on the number of fair share scheduler (FSS) CPU shares for docker container. the container with 50 will get 5x as much time from the scheduler as the one with 10 when there is contention.
        - zone's cpu_shares
    - `[--quota <quota>]` Sets a quota on the zone filesystem for the docker container. the unit is GB
        - zone's quota
    - `[--network <network_name>]` Sets network for the docker container. default value is `default`
        - network name must config in in smartos-docker.conf
    - `[--ip <ip>]` Sets ip address for the docker container. default value is `dhcp`
        - format like:
            - `xxx.xxx.xxx.xxx/xx`
            - `xxx.xxx.xxx.xxx` the netmask read from the selected network configuration, if not configed, return 24.
            - `dhcp` from dhcp server, and then the ip will be set as static ip.
    - `[--nic_tag <nic_tag>]` Sets the nic_tag for docker container, default read from the selected network configuration, if not configed, return `admin`.
    - `[--gateway <gateway>]` Sets the gateway for docker container, default read from the selected network configuration, if not configed, return `none`.
        - format as `xxx.xxx.xxx.xxx`
    - `[--vlan <vlan_id>]` Sets the vlan_id for docker container, default read from the selected network configuration, if not configed, return `none`.
    - `[--resolver <resolver>]` Sets the vlan_id for docker container, default read from the selected network configuration
        - format as `<ips>`
            - `xxx.xxx.xxx.xxx`
            - `xxx.xxx.xxx.xxx xxx.xxx.xxx.xxx`
        - can be set many times
        - if not set and network not configed, default is: `8.8.8.8 4.4.4.4`
    - `[--lofs_volume <lofs_volume>]` Sets lofs volume for the docker container.
        - volume mount as filesystems
        - cat set many times
        - format as `[<source>]:<target>[:<options>]` or `[<source>]:<target>[:<options>] [<source>]:<target>[:<options>] ...`
            - `source`: directory or file on SmartOS GZ
                - if the source not start with `/`, then the source path is `${volume_base_store}/${source}`, `volume_base_store` is configed in `smartos-docker.conf` file.
                - in new SmartOS(PI >= 20210506T001621Z) can be omited, SmartOS GZ screate a zfs filesystem on: `/zones/<vm_uuid>/volumes/<volume_uuid>`
                - if the source not exists in SmartOS GZ
                    - `Directory` the source directory will be auto-created before docker container creating.
                        - create as zfs dataset, failed if create zfs dataset failed.
                    - `File` if the directory path not exists, the directory will be auto-created before docker container creating.
                        - create as zfs dataset, failed if create zfs dataset failed.
                        - copy the container target file to the source path.
                - if source not exists at docker container creating and target has owner flag. then after source created the chown will be executed. 
            - `target`: the mount path in docker container. format as `<path>[*flag[*flag]]`
                - `path` the mount path in docker container
                - `flag` target flag
                    - `f` file flag, means the volume is a file, the flag must be first flag, if not set the flag, means the volume is a directory
                    - `<uid>[/<gid>]` owner flag, means volume's owner.
                        - `1000` act `chown -R 1000`
                        - `/1000` act `chown -R :1000`
                        - `1000/1000` act `chown -R 1000:1000`
            - `options`: mount options, just lofs mount options
                - `ro`
    - `[--workdir <workdir>]` Sets work dir for the docker container, default read from the docker image.
    - `[--image_uuid <image_uuid>]` docker image uuid, if the option setted, the `<image_name>` arg will be ignored
    - `[--env <env>]` Sets environment variables for the docker container.
        - can be set many times
        - format as `--env var1=value1` or `--env "var1=value1 var2=value2"`
    - `[--entrypoint <entrypoint>]` Sets Entrypoint for the docker container
        - can be set many times. the follows is equal.
            - `--entrypoint bash --entrypoint scriptfile`
            - `--entrypoint "bash scriptfile"`

    - `[--cmd <cmd>]` Sets Cmd for the docker container,
        - can be set many times. the follows is equal.
            - `--cmd bash --cmd scriptfile`
            - `--cmd "bash scriptfile"`
    - `<docker_image>` docker image
        - if provide the arg, must be the end of the command.
        - if `--uuid <image_uuid>` is setted, the arg will be ignored.
        - format as `<image_name>[:<tag>]`
            - if `<tag>` not provided, then set tag as `latest`
    不管是否创建docker zone, 都会生成并保存完整的payload文件, 此完整payload文件可以直接通过vmadm create -f <payloadfile> 来创建docker zone    
    
    1. 文件模式: smartos-docker [run] [-v|-k] -f <file> [options] [<docker_image>]

        通过payload基础文件生成完整payload文件并创建docker zone
        - 如果提供 -v 选项, 则只生成完整payload文件, 不创建docker zone
        - 如果提供 -k 选项, 则跳过所有模式项分析和替换, 直接基础payload文件创建docker zone, 此时-v失效
    1. 选项模式: smartos-docker [run] [options] [<docker_image>]
    
        根据提供的选项生成完整payload文件, 不创建docker zone
    
    注: 如同时 符合 文件模式 和 选项模式, 则执行以下规则:
    - 如提供选项, 以选项中的值覆盖 基础文件 中的值
    - 如选项没有提供, 则以 基础 文件为准, 不以默认值覆盖
    - 如果没有提供-v, 则会创建 docker zone
    - 生成的完整payload文件会保存在当前目录下, 并以容器uuid命名: <vm_uuid>.json

    ***filesystems***
    通过smartos-docker工具创建docker zone时, 会判断filesystems中source,按以下规则处理:
        1. 如果 source 在SmartOS主机中存在, 继续.
        1. 如果 source 值为 create-volume , 继续. 新版本SmartOS会创建一个本地volume, 见lofs_volume说明
        1. 如果 source 能够在SmartOS找到父级 filesystem, 继续. 会在此父级 filesystem 下递归创建对应子 filesystem 进行挂载
        1. 如果 source 能够在SmartOS找到父级 filesystem, 失败. 
            - 目前做失败处理
            - 直接在SmartOS主机上创建此目录?
            - 默认配置一父级 filesystem, 在此父级下创建相对子 filesystem? <base_filesystem>/<vm_uuid>/sub_path









##### 查看容器日志
1. 语法
    - smartos-docker logs [-f] <container>
1. 说明
     查看容器日志
        参数: 
            container: 容器名称或uuid
        options:
            -f 跟踪日志输出

##### 拉取docker镜像
1. 语法
    - smartos-docker pull [-q] <docker_image>
1. 说明
     拉取docker镜像
        参数: 
            docker_image docker镜像, NAME[:TAG], 如未提供TAG, 默认为 latest
        options:
            -q 不显示进度信息

##### 显示已下载的镜像列表
1. 语法
    - smartos-docker images
1. 说明
     显示已下载的镜像列表

##### 显示部署的容器列表
1. 语法
    - smartos-docker ps
1. 说明
     显示部署的容器列表

##### 显示子命令帮助
1. 语法
    - smartos-docker help <sub_command>
1. 说明
     显示子命令帮助
        参数: 
            sub_command: 子命令, run|pull|ps|logs|images|help



#### 基础payload
1. 最少项(否则必须以选项模式补充)
    - image_uuid: docker image uuid, 必须已经导入到SmartOS主机
        - 导入方法: `imgadm import <image_name>[:<image_tag>]`
        - 查看已导入的docker image方法: `imgadm list --docker`
    - nic: 必须设置一个静态IP, 否则容器没法被访问到
    - 示例:
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
1. 最多项

    不限制, 参考SmartOS vmtype 为 OS 的选项(https://www.smartos.org/man/1m/vmadm)

### EXAMPLES
1. 显示使用帮助
    ```
    [root@gen9san ~]# smartos-docker -h
    usage:
    smartos-docker.sh -h
    smartos-docker.sh [-v|-k] -f <filename> [options]
    smartos-docker.sh [options]
        -f <filename> payload file, 如果不提供, 必须提供image_uuid, 并且只会生成完成payload文件显示, 不会执行创建docker容器
        --uuid 容器uuid, 默认随机产生
        -v 显示完整payload, vmadm可用
        -k 跳过所有选项分析和替换, 直接使用原始文件创建docker zone, 必须和-f一起使用
        --image_uuid docker_image uuid, 如果提供, 以这个为准（会替换payload文件中的image_uuid
        --hostname 主机名称, 如果不设置默认为容器uuid
        --name 容器名称, 如果不设置默认为无(-)
        --kernel_version linux kernel version, 默认为:4.3.0(ubuntu-20.04)
        --memory 容器内存, 单位为MB, 默认为512
        --cpu_cap 容器cpu使用限额, 单位为百分比, 如100表示一个全cpu, 默认为0, 表示不限制
        --cpu_shares 容器cpu使用优先级, 相对于整台服务器所有zone有效, 默认为100, 如100比50有两倍的机会享有cpu
        --quota 容器磁盘限额, 单位为GB, 默认为10
        --nic_ip docker nic ip, 如果没有配置filename, 则应指定ip, 否则没有可访问的IP, 默认为dhcp(获取不到IP)
            格式为: xxx.xxx.xxx.xxx/xx 或 xxx.xxx.xxx.xxx, 如不提供/xx, 则默认为/24, 如: 192.168.1.8 和 192.168.1.8/24j是相同的
        --nic_gateway docker nic gateway, 如果没有配置filename, 则应指定gateway, 默认无
            格式为: xxx.xxx.xxx.xxx, 如: 192.168.1.1
        --nic_vlan_id docker nic vlanid, 如果没有配置filename, 则按实际输入,默认为0(无vlan)
            格式为数字: 18
        --nic_tag docker nic tag, 如果没有配置filename, 则按实际输入,默认为admin
        --resolver docker 域名解析服务器, 如果没有配置filename, 则按实际输入, 可以多次设置或一次设置多个
            多次设置:--resolver 8.8.8.8 --resolver 4.4.4.4
            设置多个: --resolver "8.8.8.8 4.4.4.4"
            默认为: --resolver "8.8.8.8 4.4.4.4"
        --workdir 工作目录, 一般不需要设置
        --env 环境变量, 可以多次设置或一次设置多个, 会覆盖默认环境变量
            多次设置:--env varname1=varvalue1 --env varname2=varvalue2
            设置多个: --env "varname1=varvalue1 varname2=varvalue2"
        --cmd docker Cmd, 可以多次设置或一次设置多个, 如果多次设置请注意顺序
            多次设置:--cmd bash --cmd scriptfile
            设置多个: --cmd "bash scriptfile"
        --entrypoint docker Entrypoint, 可以多次设置或一次设置多个, 如果多次设置请注意顺序
            多次设置:--entrypoint bash --entrypoint scriptfile
            设置多个: --entrypoint "bash scriptfile"
        --lofs_volume docker lofs volume,  可以多次设置或一次设置多个
            单个volume格式为(不允许存在空格): [<source>]:<target>[:<options>]
                source: 为SmartOS主机上存在的目录或文件, 新版本SmartOS(>=20210506T001621Z)可以省略, 如果省略则会在容器下创建目录(zfs filesystem):/zones/<vm_uuid>/volumes/<volume_uuid>
                target: 挂载到容器中对应的目录
                options: 挂载选项, 可以省略, 支持多选, 以,隔开
            多次设置:
                --lofs_volume /zones/volumes/data1:/data1:ro --lofs_volume :/data1
            设置多个:
                --lofs_volume "/zones/volumes/data1:/data1:ro :/data1"
        -h 显示使用帮助, 可选

    基础payload file最少项:
        image_uuid: 类型为docker image uuid, 必须已经导入
            imgadm import <img_name>[:img_tag]
            imgadm list --docker
        nic: 必须设置一个主nic并设置为静态IP, 否则无法访问到容器
    ```

1. 根据基础配置文件创建docker zone
    ```
    [root@gen9san ~]# smartos-docker -f minio-docker-base.json
    payload file saved at cb93d53c-e061-11eb-83a2-5fea609133fb.json
    Successfully created VM cb93d53c-e061-11eb-83a2-5fea609133fb
    ```

1. 根据基础配置文件创建完整payload文件
    ```
    [root@gen9san ~]# smartos-docker -v -f minio-docker-base.json
    payload file saved at ff1e0f6c-e061-11eb-87ed-d714b711c9e5.json
    payload file:

    {
    "image_uuid": "4b86b1b3-5ce1-6077-e648-c1270bfacdb4",
    "nics": [
        {
        "nic_tag": "external",
        "ips": [
            "192.168.18.52/24"
        ],
        "gateway": "192.168.18.1",
        "primary": true
        }
    ],
    "uuid": "ff1e0f6c-e061-11eb-87ed-d714b711c9e5",
    "brand": "lx",
    "kernel_version": "4.3.0",
    "docker": true,
    "internal_metadata": {
        "docker:entrypoint": "[\"/usr/bin/docker-entrypoint.sh\"]",
        "docker:cmd": "[\"minio\"]",
        "docker:env": "[\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"container=oci\",\"MINIO_ACCESS_KEY_FILE=access_key\",\"MINIO_SECRET_KEY_FILE=secret_key\",\"MINIO_ROOT_USER_FILE=access_key\",\"MINIO_ROOT_PASSWORD_FILE=secret_key\",\"MINIO_KMS_SECRET_KEY_FILE=kms_master_key\",\"MINIO_UPDATE_MINISIGN_PUBKEY=RWTx5Zr1tiHQLwG9keckT0c45M3AGeHD6IvimQHpyRywVWGbP1aVSGav\"]",
        "docker:open_stdin": "true",
        "docker:tty": "true"
    }
    }
    ```

1. 根据选项创建完整payload文件
    ```
    [root@gen9san ~]# smartos-docker --image_uuid 4b86b1b3-5ce1-6077-e648-c1270bfacdb4 --name docker-minio --hostname docker-minio --nic_ip 192.168.18.52 --nic_gateway 192.168.18.1 --cmd "minio server /data"
    payload file saved at 20e2a8d8-e062-11eb-be04-6fe4cfd40cda.json
    payload file:

    {
    "uuid": "20e2a8d8-e062-11eb-be04-6fe4cfd40cda",
    "max_physical_memory": 512,
    "image_uuid": "4b86b1b3-5ce1-6077-e648-c1270bfacdb4",
    "resolvers": [
        "8.8.8.8",
        "4.4.4.4"
    ],
    "nics": [
        {
        "nic_tag": "admin",
        "ips": [
            "192.168.18.52/24"
        ],
        "primary": true,
        "gateway": "192.168.18.1"
        }
    ],
    "hostname": "docker-minio",
    "alias": "docker-minio",
    "kernel_version": "4.3.0",
    "brand": "lx",
    "docker": true,
    "internal_metadata": {
        "docker:entrypoint": "[\"/usr/bin/docker-entrypoint.sh\"]",
        "docker:cmd": "[\"minio\",\"server\",\"/data\"]",
        "docker:env": "[\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"container=oci\",\"MINIO_ACCESS_KEY_FILE=access_key\",\"MINIO_SECRET_KEY_FILE=secret_key\",\"MINIO_ROOT_USER_FILE=access_key\",\"MINIO_ROOT_PASSWORD_FILE=secret_key\",\"MINIO_KMS_SECRET_KEY_FILE=kms_master_key\",\"MINIO_UPDATE_MINISIGN_PUBKEY=RWTx5Zr1tiHQLwG9keckT0c45M3AGeHD6IvimQHpyRywVWGbP1aVSGav\"]",
        "docker:open_stdin": "true",
        "docker:tty": "true"
    }
    }
    ```

1. 混合创建docker zone
    ```
    [root@gen9san ~]# smartos-docker -f minio-docker-base.json --nic_ip 192.168.18.52 --cmd "minio server /data"
    payload file saved at 512faab8-e062-11eb-ba43-37bf4b791dce.json
    Successfully created VM 512faab8-e062-11eb-ba43-37bf4b791dce
    ```

1. 混合创建完整payload文件
    ```
    [root@gen9san ~]# smartos-docker -v -f minio-docker-base.json --nic_ip 192.168.18.52 --cmd "minio server /data"
    payload file saved at 764500be-e062-11eb-8e8a-ffda048b32f8.json
    payload file:

    {
    "image_uuid": "4b86b1b3-5ce1-6077-e648-c1270bfacdb4",
    "nics": [
        {
        "nic_tag": "external",
        "ips": [
            "192.168.18.52/24"
        ],
        "gateway": "192.168.18.1",
        "primary": true
        }
    ],
    "uuid": "764500be-e062-11eb-8e8a-ffda048b32f8",
    "docker": true,
    "kernel_version": "4.3.0",
    "brand": "lx",
    "internal_metadata": {
        "docker:entrypoint": "[\"/usr/bin/docker-entrypoint.sh\"]",
        "docker:cmd": "[\"minio\",\"server\",\"/data\"]",
        "docker:env": "[\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"container=oci\",\"MINIO_ACCESS_KEY_FILE=access_key\",\"MINIO_SECRET_KEY_FILE=secret_key\",\"MINIO_ROOT_USER_FILE=access_key\",\"MINIO_ROOT_PASSWORD_FILE=secret_key\",\"MINIO_KMS_SECRET_KEY_FILE=kms_master_key\",\"MINIO_UPDATE_MINISIGN_PUBKEY=RWTx5Zr1tiHQLwG9keckT0c45M3AGeHD6IvimQHpyRywVWGbP1aVSGav\"]",
        "docker:open_stdin": "true",
        "docker:tty": "true"
    }
    }
    ```

1. 指定容器 uuid 为 45e2eea8-e05e-11eb-bab0-0fad1a795854
    - 创建模式
    ```
    [root@gen9san ~]# smartos-docker -v -f minio-docker-base.json --uuid 45e2eea8-e05e-11eb-bab0-0fad1a795854 --cmd "minio server /data"
    payload file saved at 45e2eea8-e05e-11eb-bab0-0fad1a795854.json
    payload file:

    {
    "image_uuid": "4b86b1b3-5ce1-6077-e648-c1270bfacdb4",
    "nics": [
        {
        "nic_tag": "external",
        "ips": [
            "192.168.18.52/24"
        ],
        "gateway": "192.168.18.1",
        "primary": true
        }
    ],
    "uuid": "45e2eea8-e05e-11eb-bab0-0fad1a795854",
    "kernel_version": "4.3.0",
    "brand": "lx",
    "docker": true,
    "internal_metadata": {
        "docker:entrypoint": "[\"/usr/bin/docker-entrypoint.sh\"]",
        "docker:cmd": "[\"minio\",\"server\",\"/data\"]",
        "docker:env": "[\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"container=oci\",\"MINIO_ACCESS_KEY_FILE=access_key\",\"MINIO_SECRET_KEY_FILE=secret_key\",\"MINIO_ROOT_USER_FILE=access_key\",\"MINIO_ROOT_PASSWORD_FILE=secret_key\",\"MINIO_KMS_SECRET_KEY_FILE=kms_master_key\",\"MINIO_UPDATE_MINISIGN_PUBKEY=RWTx5Zr1tiHQLwG9keckT0c45M3AGeHD6IvimQHpyRywVWGbP1aVSGav\"]",
        "docker:open_stdin": "true",
        "docker:tty": "true"
    }
    }
    ```
    - 选项模式
    ```
    [root@gen9san ~]# smartos-docker --uuid 45e2eea8-e05e-11eb-bab0-0fad1a795854 --image_uuid 4b86b1b3-5ce1-6077-e648-c1270bfacdb4 --name docker-minio --hostname docker-minio --nic_ip 192.168.18.52 --nic_gateway 192.168.18.1 --cmd "minio server /data"
    payload file saved at 45e2eea8-e05e-11eb-bab0-0fad1a795854.json
    payload file:

    {
    "uuid": "45e2eea8-e05e-11eb-bab0-0fad1a795854",
    "max_physical_memory": 512,
    "image_uuid": "4b86b1b3-5ce1-6077-e648-c1270bfacdb4",
    "resolvers": [
        "8.8.8.8",
        "4.4.4.4"
    ],
    "nics": [
        {
        "nic_tag": "admin",
        "ips": [
            "192.168.18.52/24"
        ],
        "primary": true,
        "gateway": "192.168.18.1"
        }
    ],
    "hostname": "docker-minio",
    "alias": "docker-minio",
    "kernel_version": "4.3.0",
    "brand": "lx",
    "docker": true,
    "internal_metadata": {
        "docker:entrypoint": "[\"/usr/bin/docker-entrypoint.sh\"]",
        "docker:cmd": "[\"minio\",\"server\",\"/data\"]",
        "docker:env": "[\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"container=oci\",\"MINIO_ACCESS_KEY_FILE=access_key\",\"MINIO_SECRET_KEY_FILE=secret_key\",\"MINIO_ROOT_USER_FILE=access_key\",\"MINIO_ROOT_PASSWORD_FILE=secret_key\",\"MINIO_KMS_SECRET_KEY_FILE=kms_master_key\",\"MINIO_UPDATE_MINISIGN_PUBKEY=RWTx5Zr1tiHQLwG9keckT0c45M3AGeHD6IvimQHpyRywVWGbP1aVSGav\"]",
        "docker:open_stdin": "true",
        "docker:tty": "true"
    }
    }
    ```