# AWS VPC Peering: Project Report

Name: ____________  Batch: ____________  Region: ap-south-1  Completion date: ____________

## 1. Objective
Connect two VPCs with peering and prove private connectivity between App-A and App-B. Administer through one public bastion.

## 2. Architecture
Insert docs/architecture-diagram (export the SVG to PNG) and the inventory with real IDs from notes/resource-ids.md.

## 3. Network build
VPC, subnets, internet gateway and route table associations. Insert screenshots 01 and 02. Explain why each subnet is public or private.

## 4. Security groups
Insert screenshots 03 (three). For each rule, one sentence on why it is needed.

## 5. Instances
Insert screenshot 04. Note that only the bastion has a public IP.

## 6. Baseline test before peering
Insert screenshot 05 and explain why it fails (no route, no peering).

## 7. Peering and routes
Insert screenshots 06 and 07. Explain the forward route, the return route and the public-subnet route.

## 8. Verification
Insert screenshots 08 to 11. Label each with host, test and result.

## 9. Controlled failure and recovery
Insert screenshots 12 and 13. Explain in 2 or 3 sentences why this shows security groups control traffic even when routing is correct.

## 10. Forward path and return path
Write in your own words how a packet goes from App-A to App-B and back.

## 11. Cleanup
Insert screenshot 14 and list the deletion order you followed.

## 12. What I learned
3 to 5 sentences in your own words.

Do not include keys, passwords or tokens. Save as YourName_EWB_VPC_Peering.pdf and place it in docs/.
