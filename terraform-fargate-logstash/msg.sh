#!/bin/bash
# 
# Sending a message to ECS Fargate

set -e

target="$1"    # nlb dns or fqdn
type="$2"
echo
echo "sending messages to $1..."
if [ $type == "1" ]; then
  echo "simple message..."
  echo "terraform message at $(date) from khong's mac" | openssl s_client -connect $1:6514 -ign_eof
elif [ $type == "2" ]; then
  echo "a sample cortex DL message, traffic/end..."
  echo "656 <14>1 2021-07-17T01:44:07.177Z stream-logfwd20-770056070-07121417-2vx8-harness-qcb5 logforwarder - panwlogs - 2021-07-17T01:44:05.000000Z,no-serial,TRAFFIC,end,9.1,2021-07-17T01:43:41.000000Z,192.168.137.48,192.168.137.1,,,intrazone-default,ehill@tripactions.com,,dns,vsys1,trust,trust,tunnel.1,tunnel.1,Cortex Data lake Log Forwarding,235544,1,52175,53,0,0,udp,allow,235,89,146,2,2021-07-17T01:43:11.000000Z,0,any,6713474,192.168.0.0-192.168.255.255,192.168.0.0-192.168.255.255,1,1,aged-out,17,0,0,0,,GP cloud service,from-policy,,,0,,0,1970-01-01T00:00:00.000000Z,N/A,0,0,0,0,10b5afb1-4f3d-4227-a452-9eb16ff8c446,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  | openssl s_client -connect $1:6514 -ign_eof
elif [ $type == "3" ]; then
  echo "a sample cortex DL message, threat/url..."
  echo -e "646 <14>1 2021-08-28T05:36:31.990Z stream-logfwd20-770056070-08171336-2frn-harness-qrq5 logforwarder - panwlogs - 2021-08-28T05:36:30.000000Z,no-serial,TRAFFIC,end,9.1,2021-08-28T05:36:20.000000Z,192.168.10.2,192.168.254.13,,,GPCS-sc-interfw-rule,,,express-mode,vsys1,trust,inter-fw,tunnel.102,tunnel.2013,gpcs-sc-log-fwd-profile,777146,1,42086,5007,0,0,tcp,allow,592,148,444,8,2021-08-28T05:35:52.000000Z,17,any,1881995,192.168.0.0-192.168.255.255,192.168.0.0-192.168.255.255,2,6,aged-out,14,0,0,0,,aws-net-pa-a,from-policy,,,0,,0,1970-01-01T00:00:00.000000Z,N/A,0,0,0,0,00000000-0000-0000-1111-000000000014,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  | openssl s_client -connect $1:6514 -ign_eof
elif [ $type == "4" ]; then   # non-standard : messages for /comment S3 folder 
  echo "a non standard syslog cortex DL message, comment..."
  echo -e '2021-08-25T17:11:27.018Z , Message: Agent Disable, Comment: disable allowed.. Override(s)=2",success,,0,,0,GlobalProtect_External_Gateway,154993,,,,,,,17,0,0,0,,GPGW_158042_us-west-201_tripact,1'  | openssl s_client -connect $1:6514 -ign_eof
else  # $type == "5"
  echo "a multiple lines of cortex DL messages with return key..."
  echo -e '646 <14>1 2021-08-28T05:36:31.990Z stream-logfwd20-770056070-08171336-2frn-harness-qrq5 logforwarder - panwlogs - 2021-08-28T05:36:30.000000Z,no-serial,TRAFFIC,end,9.1,2021-08-28T05:36:20.000000Z,192.168.10.2,192.168.254.13,,,GPCS-sc-interfw-rule,,,express-mode,vsys1,trust,inter-fw,tunnel.102,tunnel.2013,gpcs-sc-log-fwd-profile,777146,1,42086,5007,0,0,tcp,allow,592,148,444,8,2021-08-28T05:35:52.000000Z,17,any,1881995,192.168.0.0-192.168.255.255,192.168.0.0-192.168.255.255,2,6,aged-out,14,0,0,0,,aws-net-pa-a,from-policy,,,0,,0,1970-01-01T00:00:00.000000Z,N/A,0,0,0,0,00000000-0000-0000-1111-000000000014,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

647 <14>1 2021-08-28T05:36:31.990Z stream-logfwd20-770056070-08171336-2frn-harness-qrq5 logforwarder - panwlogs - 2021-08-28T05:36:30.000000Z,no-serial,TRAFFIC,end,9.1,2021-08-28T05:36:20.000000Z,192.168.10.2,192.168.254.13,,,GPCS-sc-interfw-rule,,,express-mode,vsys1,trust,inter-fw,tunnel.102,tunnel.2013,gpcs-sc-log-fwd-profile,777146,1,42086,5007,0,0,tcp,allow,592,148,444,8,2021-08-28T05:35:52.000000Z,17,any,1881995,192.168.0.0-192.168.255.255,192.168.0.0-192.168.255.255,2,6,aged-out,14,0,0,0,,aws-net-pa-a,from-policy,,,0,,0,1970-01-01T00:00:00.000000Z,N/A,0,0,0,0,00000000-0000-0000-1111-000000000014,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'  | openssl s_client -connect $1:6514 -ign_eof
fi
echo
