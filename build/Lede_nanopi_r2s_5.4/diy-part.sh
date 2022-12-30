#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# DIY扩展二合一了，在此处可以增加插件
# 自行拉取插件之前请SSH连接进入固件配置里面确认过没有你要的插件再单独拉取你需要的插件
# 不要一下就拉取别人一个插件包N多插件的，多了没用，增加编译错误，自己需要的才好
# 修改IP项的EOF于EOF之间请不要插入其他扩展代码，可以删除或注释里面原本的代码



cat >$NETIP <<-EOF
uci set network.lan.delegate='0'                                            # 去掉LAN口使用内置的 IPv6 管理
uci set network.wan.delegate='0' 
uci delete network.lan
uci set network.lan=interface
uci set network.lan.ifname='eth0'
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.111.1'
uci set network.lan.netmask='255.255.255.0'
uci set network.wan=interface
uci set network.wan.proto='static'
#uci set network.wan.ifname='eth0.2' #vlan
uci set network.wan.ifname='eth1' #usb网卡
#uci set network.wan.username='' #拨号
#uci set network.wan.password=''
#uci set network.wan.keepalive='10 5'
uci set network.wan.ipaddr='192.168.110.2'
uci set network.wan.netmask='255.255.255.0'
uci set network.wan.gateway='192.168.110.1'
uci set network.wan.dns='192.168.110.1'
uci set network.wan.ipv6='0'
uci commit network
uci set upnpd.config.enabled='1'
uci commit upnpd
uci set cpufreq.cpufreq.governor='schedutil'
uci set cpufreq.cpufreq.upthreshold='50'
uci set cpufreq.cpufreq.factor='10'
uci set cpufreq.cpufreq.minifreq='600000'
uci set cpufreq.cpufreq.maxfreq='1200000'
uci commit cpufreq
uci add_list uhttpd.main.listen_http='0.0.0.0:6380'
uci add_list uhttpd.main.listen_http='[::]:6380'
uci set uhttpd.main.rfc1918_filter='0'
uci commit uhttpd
uci set hd-idle.@hd-idle[0].disk='sda1'
uci set hd-idle.@hd-idle[0].enabled='1'
uci commit hd-idle
uci set minidlna.config.enabled='0'
uci set minidlna.config.media_dir='/mnt/1t/TV'
uci set minidlna.config.interface='eth0'
uci commit minidlna
uci add firewall rule
uci rename firewall.@rule[-1]="6380"
uci set firewall.@rule[-1].name="6380"
uci set firewall.@rule[-1].target="ACCEPT"
uci set firewall.@rule[-1].src="wan"
uci set firewall.@rule[-1].proto="tcp"
uci set firewall.@rule[-1].dest_port="6380"
uci add firewall rule
uci rename firewall.@rule[-1]="6377"
uci set firewall.@rule[-1].name="6377"
uci set firewall.@rule[-1].target="ACCEPT"
uci set firewall.@rule[-1].src="wan"
uci set firewall.@rule[-1].proto="tcp"
uci set firewall.@rule[-1].dest_port="6377"
uci commit firewall
#uci set dhcp.lan.ignore='1'                                                 # 关闭DHCP功能
uci del dhcp.lan.ra
uci del dhcp.lan.dhcpv6
uci del dhcp.lan.ra_management
uci commit dhcp                                                             # 跟‘关闭DHCP功能’联动,同时启用或者删除跟注释
uci set system.@system[0].hostname='BKY'                            # 修改主机名称为OpenWrt-123
EOF

sed -i 's/$(DTS_DIR)\/$(DEVICE_DTS)/bkyrockchip/g' target/linux/rockchip/image/Makefile
sed -i 's/"$(STAGING_DIR_IMAGE)"\/$(UBOOT_DEVICE_NAME)-idbloader.img/idbloader2.img/g' target/linux/rockchip/image/Makefile
sed -i 's/"$(STAGING_DIR_IMAGE)"\/$(UBOOT_DEVICE_NAME)-u-boot.itb/uboot2.img/g' target/linux/rockchip/image/Makefile
sed -i 's/"$(STAGING_DIR_IMAGE)"\/$(UBOOT_DEVICE_NAME)-idbloader.bin/idbloader.img/g' target/linux/rockchip/image/Makefile
sed -i 's/"$(STAGING_DIR_IMAGE)"\/$(UBOOT_DEVICE_NAME)-uboot.img/uboot.img/g' target/linux/rockchip/image/Makefile
sed -i 's/"$(STAGING_DIR_IMAGE)"\/$(UBOOT_DEVICE_NAME)-trust.bin/trust.img/g' target/linux/rockchip/image/Makefile
sed -i '/IMAGE_KERNEL/a\$(CP) opt.zip $@.boot/opt.zip' target/linux/rockchip/image/Makefile

# 把bootstrap替换成argon为源码必选主题（可自行修改您要的,主题名称必须对,比如下面代码的[argon],源码内必须有该主题,要不然编译失败）
sed -i "s/bootstrap/argon/ig" feeds/luci/collections/luci/Makefile


# 编译多主题时,设置固件默认主题（可自行修改您要的,主题名称必须对,比如下面代码的[argon],和肯定编译了该主题,要不然进不了后台）
#sed -i "/exit 0/i\uci set luci.main.mediaurlbase='/luci-static/argon' && uci commit luci" "${FIN_PATH}"


# 增加个性名字 ${Author} 默认为你的github帐号,修改时候把 ${Author} 替换成你要的
sed -i "s/OpenWrt /${Author} compiled in $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" "${ZZZ_PATH}"


# 设置首次登录后台密码为空（进入openwrt后自行修改密码）
sed -i '/CYXluq4wUazHjmCDBCqXF/d' "${ZZZ_PATH}"


# 删除默认防火墙
#sed -i '/to-ports 53/d' "${ZZZ_PATH}"


# 取消路由器每天跑分任务
sed -i "/exit 0/i\sed -i '/coremark/d' /etc/crontabs/root" "${FIN_PATH}"


# 修改默认内核（所有机型都适用，只要您编译的机型源码附带了其他内核，请至编译说明的第12条查看）
#sed -i 's/PATCHVER:=5.15/PATCHVER:=5.4/g' target/linux/rockchip/Makefile


# 更改使用OpenClash的分支代码，把下面的master改成dev就使用dev分支，改master就是用master分支，改错的话就默认使用master分支
export OpenClash_branch='master'


# K3专用，编译K3的时候只会出K3固件（其他机型也适宜,把phicomm_k3和对应路径替换一下，名字要绝对正确才行）
#sed -i 's|^TARGET_|# TARGET_|g; s|# TARGET_DEVICES += phicomm_k3|TARGET_DEVICES += phicomm_k3|' target/linux/bcm53xx/image/Makefile


# 在线更新时，删除不想保留固件的某个文件，在EOF跟EOF之间加入删除代码，记住这里对应的是固件的文件路径，比如： rm -rf /etc/config/luci
cat >$DELETE <<-EOF
EOF


# 修改插件名字
#sed -i 's/"aMule设置"/"电驴下载"/g' `egrep "aMule设置" -rl ./`
#sed -i 's/"网络存储"/"NAS"/g' `egrep "网络存储" -rl ./`
#sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' `egrep "Turbo ACC 网络加速" -rl ./`
#sed -i 's/"实时流量监测"/"流量"/g' `egrep "实时流量监测" -rl ./`
#sed -i 's/"KMS 服务器"/"KMS激活"/g' `egrep "KMS 服务器" -rl ./`
#sed -i 's/"TTYD 终端"/"命令窗"/g' `egrep "TTYD 终端" -rl ./`
#sed -i 's/"USB 打印服务器"/"打印服务"/g' `egrep "USB 打印服务器" -rl ./`
#sed -i 's/"Web 管理"/"Web管理"/g' `egrep "Web 管理" -rl ./`
#sed -i 's/"管理权"/"改密码"/g' `egrep "管理权" -rl ./`
#sed -i 's/"带宽监控"/"监控"/g' `egrep "带宽监控" -rl ./`


# 整理固件包时候,删除您不想要的固件或者文件,让它不需要上传到Actions空间（根据编译机型变化,自行调整需要删除的固件名称）
cat >"$CLEAR_PATH" <<-EOF
packages
config.buildinfo
feeds.buildinfo
openwrt-x86-64-generic-kernel.bin
openwrt-x86-64-generic.manifest
openwrt-x86-64-generic-squashfs-rootfs.img.gz
sha256sums
version.buildinfo
EOF
