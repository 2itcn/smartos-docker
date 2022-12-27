# minio
## docker image
minio/minio:RELEASE.2022-05-26T05-48-41Z

```
docker pull minio/minio:RELEASE.2022-05-26T05-48-41Z
```

## step
1. create docker payload file
  ```
  docker run -n \
  --uuid b7dc24cc-ed5e-11eb-abcd-434a7243708b \
  --name docker-minio01 \
  --hostname minio01 \
  -v "data:/data" \
  -e "MINIO_ROOT_USER=YOURROOTUSER MINIO_ROOT_PASSWORD=YOUROOTPASSWORD" \
  --cmd 'minio server /data --console-address :9001' \
  minio/minio:RELEASE.2022-05-26T05-48-41Z
  ```
  - payload file
    ```
    {
      "uuid": "30971f84-7490-11ed-907e-54bf6464aaf5",
      "max_physical_memory": 512,
      "image_uuid": "57ea83a7-cf5a-3e3c-6acb-efe2156efd88",
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
      "hostname": "minio01",
      "alias": "docker-minio01",
      "filesystems": [
        {
          "source": "/export/lofs/docker-minio01/volumes/data",
          "type": "lofs",
          "target": "/data"
        }
      ],
      "brand": "lx",
      "docker": true,
      "kernel_version": "4.3.0",
      "internal_metadata": {
        "docker:entrypoint": "[\"/usr/bin/docker-entrypoint.sh\"]",
        "docker:cmd": "[\"minio\",\"server\",\"/data\",\"--console-address\",\":9001\"]",
        "docker:env": "[\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"container=oci\",\"MINIO_ACCESS_KEY_FILE=access_key\",\"MINIO_SECRET_KEY_FILE=secret_key\",\"MINIO_ROOT_USER_FILE=access_key\",\"MINIO_ROOT_PASSWORD_FILE=secret_key\",\"MINIO_KMS_SECRET_KEY_FILE=kms_master_key\",\"MINIO_UPDATE_MINISIGN_PUBKEY=RWTx5Zr1tiHQLwG9keckT0c45M3AGeHD6IvimQHpyRywVWGbP1aVSGav\",\"MINIO_CONFIG_ENV_FILE=config.env\",\"MINIO_ROOT_USER=YOURROOTUSER\",\"MINIO_ROOT_PASSWORD=YOUROOTPASSWORD\"]",
        "docker:open_stdin": true,
        "docker:tty": true,
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
  docker run -k -f b7dc24cc-ed5e-11eb-abcd-434a7243708b.json
  docker container's ip is 192.168.59.163/24
  Successfully created VM b7dc24cc-ed5e-11eb-abcd-434a7243708b
  ```

## Visit:
http://192.168.59.163:9001

## Note
1. Starting with RELEASE.2022-06-02T02-11-04Z, MinIO implements a zero-parity erasure coded backend for single-node single-drive deployments. This feature allows access to erasure coding dependent features without the requirement of multiple drives.
1. RELEASE.2022-10-29T06-21-33Z fully removes the deprecated Gateway/Filesystem backends. MinIO returns an error if it starts up and detects existing Filesystem backend files.
1. RELEASE.2022-05-26T05-48-41Z is latest version that support non-erasure coded backend for SNSD.
