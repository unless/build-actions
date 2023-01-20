#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# DIY扩展二合一了，在此处可以增加插件
# 自行拉取插件之前请SSH连接进入固件配置里面确认过没有你要的插件再单独拉取你需要的插件
# 不要一下就拉取别人一个插件包N多插件的，多了没用，增加编译错误，自己需要的才好
# 修改IP项的EOF于EOF之间请不要插入其他扩展代码，可以删除或注释里面原本的代码



cat >$NETIP <<-EOF
uci delete network.lan
uci set network.lan=interface
uci set network.lan.ifname='eth0'
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.111.1'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.delegate='0'      # 去掉LAN口使用内置的 IPv6 管理(若用IPV6请把'0'改'1')
uci set network.wan=interface
uci set network.wan.proto='static'
uci set network.wan.ifname='eth0.110'
uci set network.wan.ipaddr='192.168.110.3'
uci set network.wan.netmask='255.255.255.0'
uci set network.wan.gateway='192.168.110.1'
uci set network.wan.dns='192.168.110.1'
uci set network.wan.ipv6='0'
uci set network.wan.delegate='0'    # 去掉WAN口使用内置的 IPv6 管理(若用IPV6请把'0'改'1')
uci commit network
uci set upnpd.config.enabled='1'
uci commit upnpd
uci del_list openvpn.myvpn.push='route 192.168.1.0 255.255.255.0'
uci del_list openvpn.myvpn.push='dhcp-option DNS 192.168.1.1'
uci add_list openvpn.myvpn.push='route 192.168.111.0 255.255.255.0'
uci add_list openvpn.myvpn.push='route dhcp-option DNS 192.168.111.1'
uci commit openvpn
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
uci rename firewall.@rule[-1]="6376"
uci set firewall.@rule[-1].name="6376"
uci set firewall.@rule[-1].target="ACCEPT"
uci set firewall.@rule[-1].src="wan"
uci set firewall.@rule[-1].proto="tcp"
uci set firewall.@rule[-1].dest_port="6376"
uci add firewall rule
uci rename firewall.@rule[-1]="6377"
uci set firewall.@rule[-1].name="6377"
uci set firewall.@rule[-1].target="ACCEPT"
uci set firewall.@rule[-1].src="wan"
uci set firewall.@rule[-1].proto="tcp"
uci set firewall.@rule[-1].dest_port="6377"
uci add firewall rule
uci rename firewall.@rule[-1]="6378"
uci set firewall.@rule[-1].name="6378"
uci set firewall.@rule[-1].target="ACCEPT"
uci set firewall.@rule[-1].src="wan"
uci set firewall.@rule[-1].proto="tcp"
uci set firewall.@rule[-1].dest_port="6378"
uci add firewall rule
uci rename firewall.@rule[-1]="6379"
uci set firewall.@rule[-1].name="6379"
uci set firewall.@rule[-1].target="ACCEPT"
uci set firewall.@rule[-1].src="wan"
uci set firewall.@rule[-1].proto="tcp"
uci set firewall.@rule[-1].dest_port="6379"
uci add firewall rule
uci rename firewall.@rule[-1]="6380"
uci set firewall.@rule[-1].name="6380"
uci set firewall.@rule[-1].target="ACCEPT"
uci set firewall.@rule[-1].src="wan"
uci set firewall.@rule[-1].proto="tcp"
uci set firewall.@rule[-1].dest_port="6380"
uci commit firewall
#uci set dhcp.lan.ignore='1'                                                 # 关闭DHCP功能
uci del dhcp.lan.ra
uci del dhcp.lan.dhcpv6
uci del dhcp.lan.ra_management 
uci set dhcp.@dnsmasq[0].filter_aaaa='1'    # 禁止解析 IPv6 DNS记录(若用IPV6请把'1'改'0')
uci commit dhcp                                                             # 跟‘关闭DHCP功能’联动,同时启用或者删除跟注释
uci set system.@system[0].hostname='BKY'                            # 修改主机名称为OpenWrt-123
uci set ttyd.@ttyd[0].command='/bin/login -f root'           # 设置ttyd免帐号登录（去掉uci前面的#生效）
# 如果有用IPV6的话,可以使用以下命令创建IPV6客户端(LAN口)（去掉全部代码uci前面#号生效）
#uci set network.ipv6=interface
#uci set network.ipv6.proto='dhcpv6'
#uci set network.ipv6.ifname='@lan'
#uci set network.ipv6.reqaddress='try'
#uci set network.ipv6.reqprefix='auto'
#uci set firewall.@zone[0].network='lan ipv6'
uci set amlogic.config.amlogic_firmware_repo='https://github.com/unless/build-actions'
uci set amlogic.config.amlogic_firmware_tag='armvirt'
uci set amlogic.config.amlogic_shared_fstype='btrfs'
uci commit amlogic
EOF

sed -i 's/PATCHVER:=5.10/PATCHVER:=5.15/g' target/linux/rockchip/Makefile

# 把bootstrap替换成argon为源码必选主题（可自行修改您要的,主题名称必须对,比如下面代码的[argon],源码内必须有该主题,要不然编译失败）
sed -i "s/bootstrap/argon/ig" feeds/luci/collections/luci/Makefile


# 编译多主题时,设置固件默认主题（可自行修改您要的,主题名称必须对,比如下面代码的[argon],和肯定编译了该主题,要不然进不了后台）
#sed -i "/exit 0/i\uci set luci.main.mediaurlbase='/luci-static/argon' && uci commit luci" "${FIN_PATH}"


# 增加个性名字 ${Author} 默认为你的github帐号,修改时候把 ${Author} 替换成你要的
sed -i "s/OpenWrt /${Author} compiled in $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" "${ZZZ_PATH}"


# 设置首次登录后台密码为空（进入openwrt后自行修改密码）
sed -i '/CYXluq4wUazHjmCDBCqXF/d' "${ZZZ_PATH}"


# 取消路由器每天跑分任务
sed -i "/exit 0/i\sed -i '/coremark/d' /etc/crontabs/root" "${FIN_PATH}"


# 更改使用OpenClash的分支代码，把下面的master改成dev就使用dev分支，改master就是用master分支，改错的话就默认使用master分支
export OpenClash_branch='master'


# 设置打包固件的机型，内核组合（可用内核是时时变化的,过老的内核就删除的，所以要选择什么内核请看说明）
# 当前可用机型
# s905x3 s905d s912 a311d s922x s922x-n2 s922x-reva s905x3 s905x3-b s905x2
# s912-m8s s905d s905d-ki s905x s905w s905 s905l3a s905x2-km3 s912
# 可选内核 （5.4） （5.10） （5.15） （5.19） （6.0）

cat >"$AMLOGIC_SH_PATH" <<-EOF
amlogic_model=rk3328
amlogic_kernel=6.1.1
auto_kernel=true
rootfs_size=960
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


# 整理固件包时候,删除您不想要的固件或者文件,让它不需要上传到Actions空间
cat >"$CLEAR_PATH" <<-EOF
packages
config.buildinfo
feeds.buildinfo
sha256sums
version.buildinfo
EOF
