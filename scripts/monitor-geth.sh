# run & detatch process again
# sudo influxd &

# get token
auth_line=$(influx auth list | grep "gethinflux") || echo " "
parts=(${auth_line//:/ })
INFLUX_TOKEN="${parts[3]}"
echo "TOKEN: ${INFLUX_TOKEN}"

# 
# line=$(ps -aux | grep influx*)
# _parts=(${line//:/ })
# influx_pid=${_parts[1]}
# echo $influx_pid
# kill $influx_pid

# push metrics
sudo geth --metrics --metrics.influxdbv2 --metrics.influxdb.endpoint "http://localhost:8086/" --metrics.influxdb.bucket "gethinflux-bucket" --metrics.influxdb.organization "ethgeth"  --metrics.influxdb.token $INFLUX_TOKEN &
sudo influxd &
# tail -f /proc/<pid>/fd/1