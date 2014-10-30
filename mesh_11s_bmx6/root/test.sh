c=0
for h in $(bmx6 -c originators | awk '{print $3}'); do
	ping6 -c2 $h -w 10
	[ $? -eq 0 ] && c=$(($c+1))
done
echo $c >> /save/meshnodes.log
