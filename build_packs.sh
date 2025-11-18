make -j"$(nproc)" binary
cd php-pam
chmod +x ./build.sh
./build.sh
cd ../
