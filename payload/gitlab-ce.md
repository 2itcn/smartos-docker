# gitlab-ce
## docker images
gitlab/gitlab-ce:14.1.0-ce.0

## step
1. create docker payload file
  ```
  docker run -n \
  --uuid fc2abffa-ed6b-11eb-bfbf-bb0c94c0ac04 \
  --name docker-gitlab01 \
  --hostname gitlab01 \
  --network default \
  --ip dhcp \
  --memory 4096 \
  -v config:/etc/gitlab \
  -v logs:/var/log/gitlab \
  -v data:/var/opt/gitlab \
  --env GITLAB_ROOT_PASSWORD=P@ssw0rd \
  gitlab/gitlab-ce:14.1.0-ce.0
  ```

  - payload file: fc2abffa-ed6b-11eb-bfbf-bb0c94c0ac04.json
  ```
  {
    "uuid": "fc2abffa-ed6b-11eb-bfbf-bb0c94c0ac04",
    "max_physical_memory": 4096,
    "image_uuid": "8e821047-ec15-18b8-3b6c-de9ca77cbcf6",
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
    "hostname": "gitlab01",
    "alias": "docker-gitlab01",
    "filesystems": [
      {
        "source": "/export/lofs/docker-gitlab01/volumes/config",
        "type": "lofs",
        "target": "/etc/gitlab"
      },
      {
        "source": "/export/lofs/docker-gitlab01/volumes/logs",
        "type": "lofs",
        "target": "/var/log/gitlab"
      },
      {
        "source": "/export/lofs/docker-gitlab01/volumes/data",
        "type": "lofs",
        "target": "/var/opt/gitlab"
      }
    ],
    "docker": true,
    "brand": "lx",
    "kernel_version": "4.3.0",
    "internal_metadata": {
      "docker:cmd": "[\"/assets/wrapper\"]",
      "docker:env": "[\"PATH=/opt/gitlab/embedded/bin:/opt/gitlab/bin:/assets:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"LANG=C.UTF-8\",\"EDITOR=/bin/vi\",\"TERM=xterm\",\"GITLAB_ROOT_PASSWORD=P@ssw0rd\"]",
      "docker:open_stdin": "true",
      "docker:tty": "true",
      "itime:network": "default"
    },
    "internal_metadata_namespaces": [
      "itime"
    ]
  }
  ```
1. change paylad file f38a928e-ed67-11eb-8010-1bf1367f470a.json as needed.

1. create docker container with the payload file.
  ```
  [root@smartos02 ~]# docker run -k -f fc2abffa-ed6b-11eb-bfbf-bb0c94c0ac04.json
  docker container's ip is 192.168.59.87/24
  Successfully created VM fc2abffa-ed6b-11eb-bfbf-bb0c94c0ac04
  ```

## Visit:
http://192.168.59.87
root/P@ssw0rd

## Notice
1. memory >= 4GB
2. if there is a permission issue
  ```
  zlogin fc2abffa-ed6b-11eb-bfbf-bb0c94c0ac04 '/native/usr/vm/sbin/dockerexec update-permissions'
  vmadm reboot fc2abffa-ed6b-11eb-bfbf-bb0c94c0ac04
  ```