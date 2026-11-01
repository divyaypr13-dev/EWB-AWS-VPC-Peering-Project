# Viva preparation

1. **Why is the return route needed?**
   Traffic is two-way. App-B can only answer 10.10.2.10 if its subnet has a route to VPC A through the peering connection. Without it, requests arrive but replies are lost.

2. **Why is the App-B SSH source the bastion private IP?**
   With ProxyJump the bastion opens a separate SSH connection to App-B, so App-B sees 10.10.1.10 as the source, not my laptop.

3. **Why does Active peering not guarantee a successful ping?**
   Active only means the link exists. Both sides need routes to it, and the destination security group (and any network ACL) must allow the traffic.

4. **Can VPC B use VPC A's internet gateway over peering?**
   No. Peering is one-to-one and non-transitive and does not carry traffic to a gateway in the other VPC. VPC B has no internet access.

More to be ready for:
- Why the CIDRs must not overlap.
- Why the private subnet has no 0.0.0.0/0 route and no NAT gateway.
- Why the public subnet also needs the 10.20.0.0/16 peering route (ProxyJump).
- What "stateful" means for security groups.
- Why the controlled failure proves the security group, not the route, blocked the ping.
