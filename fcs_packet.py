from scapy.all import Ether, IP, TCP

# Create an Ethernet frame with destination MAC address '00:11:22:33:44:55'
# and source MAC address 'aa:bb:cc:dd:ee:ff'
eth_frame = Ether(dst='00:11:22:33:44:55', src='aa:bb:cc:dd:ee:ff')

# Add an IP packet inside the Ethernet frame
ip_packet = IP(dst='192.168.0.1', src='192.168.0.2')

# Add a TCP segment inside the IP packet
tcp_segment = TCP(dport=80, sport=1234)

# Combine all layers to create the final packet
packet = eth_frame / ip_packet / tcp_segment

# Display the packet summary
print(packet.summary())

# Send the packet
sendp(packet)