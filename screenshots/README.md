# Screenshots checklist

Save real screenshots here with these names. Show the hostname or the Region where possible.
Blur your public IP if you do not want it published. Never capture the .pem key.

- [ ] 01-vpc-a-subnets-routes.png    Checkpoint 01: subnet associations and public 0.0.0.0/0 route
- [ ] 02-vpcs-list.png               Your VPCs list: both names and CIDRs
- [ ] 03-sg-bastion.png              ewb-sg-bastion inbound rules
- [ ] 03-sg-app-a.png                ewb-sg-app-a inbound rules
- [ ] 03-sg-app-b.png                ewb-sg-app-b inbound rules
- [ ] 04-instances.png               Checkpoint 02: IDs, private IPs, bastion public IP, empty public IP on apps
- [ ] 05-baseline-ping-fail.png      App-A: ping 10.20.1.10 BEFORE peering fails
- [ ] 06-peering-active.png          Checkpoint 03: ewb-a-b-peer Active, both VPC IDs
- [ ] 07-route-tables.png            Checkpoint 04: all three route tables with associations
- [ ] 08-ping-a-to-b.png             App-A to App-B: 4 replies, 0% loss
- [ ] 09-ping-b-to-a.png             App-B to App-A: 4 replies, 0% loss
- [ ] 10-ssh-app-b.png               ssh ewb-app-b from laptop through bastion
- [ ] 11-no-public-ip.png            App-A and App-B: Public IPv4 address empty
- [ ] 12-icmp-removed-fail.png       ICMP rule removed on App-B SG, ping fails
- [ ] 13-icmp-restored-ok.png        Exact rule restored, ping works
- [ ] 14-cleanup.png                 Empty instances, volumes and VPC list after cleanup
