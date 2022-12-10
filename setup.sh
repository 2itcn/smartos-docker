mkdir -p /opt/tools/etc/smartos-docker.conf
[[ -f /opt/tools/etc/smartos-docker.conf ]] || cp src/smartos-docker.conf /opt/tools/etc/smartos-docker.conf
cp src/smartos-docker /opt/tools/bin/smartos-docker
chmod +x /opt/tools/bin/smartos-docker
ln -s /opt/tools/bin/smartos-docker /opt/tools/bin/docker