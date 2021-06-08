# https://github.com/danshui-git/shuoming
# https://github.com/281677160/AutoBuild-OpenWrt

cd openwrt && make menuconfig

检查更新(保留配置): bash /bin/AutoUpdate.sh

检查更新(不保留配置): bash /bin/AutoUpdate.sh -n

查看更多使用方法：bash /bin/AutoUpdate.sh -h
