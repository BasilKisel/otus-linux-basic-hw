iptables -t filter -F INPUT
iptables -t filter -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
iptables -t filter -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT # To let out connections be carring out.
iptables -t filter -A INPUT -p tcp -m multiport --dports 22,53,853,9100,5400,5401,5601,9200 -j ACCEPT # ssh, dns, dns, prometheus-node-exporter, nginx filebeat, apache2 filebeat, kibana, elasticsearch
iptables -t filter -A INPUT -p udp --dport 53 -j ACCEPT # DNS answers
iptables -t filter -P INPUT DROP
