#!/bin/bash 

apt-get update
apt-get upgrade -y

adduser --system --group --no-create-home _apt
usermod -aG root _apt
ARCH="$(dpkg --print-architecture)"

OMV_SALT_PKG="./openmediavault-salt_8.0_${ARCH}.deb"
PHP_PAM_PKG="./php-pam_2.2.5-1+deb13u1_${ARCH}.deb"

if [ ! -f "$OMV_SALT_PKG" ] || [ ! -f "$PHP_PAM_PKG" ]; then
    echo "Packages for arch ${ARCH} are missing, running build_packs.sh..."
    chmod +x ./build_packs.sh
    ./build_packs.sh
else
    echo "Packages for arch ${ARCH} already exist:"
    echo "  $OMV_SALT_PKG"
    echo "  $PHP_PAM_PKG"
fi

apt-get install -y ./openmediavault_8.0-7_all.deb ./openmediavault-salt_8.0_${ARCH}.deb ./openmediavault-keyring_1.0.2-2_all.deb ./php-pam_2.2.5-1+deb13u1_${ARCH}.deb

systemctl stop wsdd.service 2>/dev/null
systemctl disable wsdd.service 2>/dev/null
mv /usr/lib/systemd/system/wsdd.service /etc/systemd/system/wsdd-server.service
systemctl daemon-reload
systemctl enable wsdd-server.service
systemctl start wsdd-server.service
mkdir /etc/wsdd-server

systemctl unmask openmediavault-beep-up.service
systemctl unmask openmediavault-beep-down.service
systemctl unmask openmediavault-cleanup-monit.service
systemctl unmask openmediavault-cleanup-php.service
systemctl unmask openmediavault-issue.service

apt-get install mc -y

mkdir -p /opt/saltstack/salt/bin
ln -s /usr/bin/python3 /opt/saltstack/salt/bin/python3

tar -xvf ./jc-1.25.6.tar.gz -C ./
cd ./jc-1.25.6
python3 setup.py install
cd ../

sed -i \
    -e "s|\$cmdArgs\[\] = \"-n=1\";|\$cmdArgs[] = \"-n\"; \$cmdArgs[] = \"1\";|g" \
    -e "s|\$cmdArgs\[\] = \"-w=512\";|\$cmdArgs[] = \"-w\"; \$cmdArgs[] = \"512\";|g" \
    /usr/share/openmediavault/engined/rpc/system.inc

sed -i 's|^\(\s*\)\$cmdArgs\[\] = "--output-all";|\1//\$cmdArgs[] = "--output-all";|' \
    /usr/share/php/openmediavault/system/mountpoint.inc


REQ_VER="3007.7"
CUR_VER="$(dpkg-query -W -f='${Version}' salt-minion 2>/dev/null || echo)"

if dpkg --compare-versions "$CUR_VER" lt "$REQ_VER"; then
	echo "Version mins $REQ_VER - prepare commands…"
	BASE_DIR="/srv/salt/omv/deploy"

	for dir in "$BASE_DIR"/*; do
	    svc="$(basename "$dir")"

	    for file in "$dir"/*.sls; do
		[ -f "$file" ] || continue

		sed -i -E "/^monitor_${svc}_service:/,/^$/{
		    s/^([[:space:]]*)- name:/    - m_name:/;
		    s/^([[:space:]]*)- monit.monitor:/\1- name: monit.monitor/;

		}" "$file"
	    done
	done

	for dir in "$BASE_DIR"/* "$BASE_DIR"/systemd-networkd/netplan; do
	    for file in "$dir"/*.sls; do
		[ -f "$file" ] || continue

		sed -i -E \
		  's/^([[:space:]]*)- file\.find:/\1  - name: file.find/' \
		  "$file"
	    done
	done

	sed -i 's|^[[:space:]]*- saltutil\.clear_cache:|    - name: saltutil.clear_cache|' \
	    /srv/salt/omv/sync/default.sls
	    
	sed -i -E "/^update_root_fstab_entry:/,/^$/{
	  s/^([[:space:]]*)- mount\.set_fstab:/\1  - name: mount.set_fstab/;
	  s/^([[:space:]]*)- name: \"\/\"/\1- m_name: \"\/\"/;
	}" /srv/salt/omv/setup/fstab/default.sls
    
else
	echo "No need chenges..."
fi



PHP_VER="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')"

ln -s /usr/bin/php${PHP_VER} /usr/bin/php8.4
sed -i \
  -e "s|php8.4-fpm|php${PHP_VER}-fpm|g" \
  -e "s|\"php-fpm8\.4 --test\"|\"php-fpm${PHP_VER} --test\"|g" \
   "$BASE_DIR"/phpfpm/default.sls
   
CONF="/etc/php/${PHP_VER}/fpm/pool.d/www.conf";
if [ -f "$CONF" ]; then
  sed -i 's/^user\s*=.*/user = openmediavault-webgui/' "$CONF";
  sed -i 's/^group\s*=.*/group = openmediavault-webgui/' "$CONF";
fi


cp /etc/php/8.4/mods-available/pam.ini /etc/php/"$PHP_VER"/mods-available
ln -s /etc/php/"$PHP_VER"/mods-available/pam.ini /etc/php/"$PHP_VER"/cli/conf.d/20-pam.ini
ln -s /etc/php/"$PHP_VER"/mods-available/pam.ini /etc/php/"$PHP_VER"/fpm/conf.d/20-pam.ini

service php${PHP_VER}-fpm restart

usermod -aG openmediavault-admin admin
usermod -aG openmediavault-webgui admin
usermod -aG _ssh pico

chmod +x ./postfix_fixmans.sh
./postfix_fixmans.sh

service salt-minion restart
service nginx restart
service nmbd restart
service smbd restart
service openmediavault-engined restart
omv-salt stage run prepare
omv-salt deploy run nginx
PHP_FPM_CONF="/etc/php/${PHP_VER}/fpm/pool.d/www.conf"
NGINX_SITE="/etc/nginx/sites-available/openmediavault-webgui"
sock="$(awk -F'=' '/^listen *=/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}' "$PHP_FPM_CONF")"
if [ -n "$sock" ]; then
    sed -i "s|unix:/run/php/php8.4-fpm-openmediavault-webgui.sock|unix:${sock}|" "$NGINX_SITE"
    echo "Updated socket in $NGINX_SITE on unix:${sock}"
else
    echo "listen not found in $PHP_FPM_CONF, nginx not reload"
fi
service nginx restart
omv-salt stage run setup
omv-salt deploy run webgui
omv-salt deploy run monit
service monit restart
omv-salt deploy run collectd
service collectd restart

if command -v luckfox-config >/dev/null 2>&1 && [ ! -f /data/ethaddr.txt ]; then
    echo "Luckfox finded..."
    echo "Fix MAC address on eth0"
    echo "IF you want use typeC as host need launch luckfox-config and Advanced Options -> USB -> host and restart board"
    MAC=$(ip -o link show eth0 2>/dev/null | awk '{print $17}' | tr '[:lower:]' '[:upper:]')
    [ -n "$MAC" ] || exit 1

    mkdir -p /data
    echo "$MAC" > /data/ethaddr.txt

    # Вставляем пустую строку + блок после #!/bin/bash
    if [ -f /etc/rc.local ]; then
        if ! grep -q 'ethaddr2=$(cat /data/ethaddr.txt)' /etc/rc.local; then
            sed -i '1a \
\
ethaddr2=$(cat /data/ethaddr.txt)\
ifconfig eth0 down\
ifconfig eth0 hw ether \$ethaddr2\
ifconfig eth0 up\
ifup eth0' /etc/rc.local

            chmod +x /etc/rc.local
        fi
    fi
fi

echo "Complite goto http://IP and login admin password openmediavault"


