apt-get install wget -y
wget -O - https://github.com/OpenMediaVault-Plugin-Developers/installScript/raw/master/install | sudo bash
make -j"$(nproc)" binary
cd php-pam
chmod +x ./build.sh
./build.sh
cd ../
