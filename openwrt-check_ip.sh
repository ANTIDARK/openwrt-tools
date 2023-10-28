#!/bin/ash
#参考了https://www.cnblogs.com/mustard27/p/Openwrt_CheckIP.html
#*/30 * * * * /check_ip.sh >> /dev/null 2>&1 &
echo "==========开始=========="
echo `date '+%Y-%m-%d %H:%M:%S'`
#获取ppoe-wan接口的ipv6
current_wan_ip=`ip -6 addr show pppoe-wan | grep -E '\binet6\b' | grep -v 'fe80' | awk '{print $2}' | cut -d'/' -f1`
echo "IP: $current_wan_ip"
#是否存在ip.txt
if [ ! -f "/ip.txt" ]; then
	echo "不存在ip.txt文件,已自动创建该文件"
    touch /ip.txt && chmod 660 /ip.txt
	#第一次推送ip
	content="?text=路由器IP已更新&""desp=当前IP:"$current_wan_ip
	url="Server酱的api"$content
	curl -s $url
	echo "已推送当前ip"
	echo ${current_wan_ip} > /ip.txt
	echo "当前IP已写入ip.txt"
else
    if [ $current_wan_ip ]; then
    	last_ip=`cat /ip.txt`
    	if [ "${current_wan_ip}" != "${last_ip}" ]; then
		#发送新ip并更新ip.txt
		content="?text=路由器IP已更新&""desp=当前IP:"$current_wan_ip
		url="Server酱的api"$content
		curl -s $url
		echo ${current_wan_ip} > /ip.txt
        # 推送到dynv6
        curl -s "https://dynv6.com/api/update?hostname=你的域名前缀.dynv6.net&ipv6=${current_wan_ip}&ipv6prefix=-&token=你的token"
		echo "已推送新ip并更新ip.txt"
    	else
		echo "IP无变化,不需要推送"
    	fi
    else 
    echo "IP为空,下一次再推送"
    fi
fi
echo `date '+%Y-%m-%d %H:%M:%S'`
echo -e "==========结束==========\n"
#end