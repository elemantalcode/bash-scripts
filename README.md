# bash-scripts
Mixed BASH scripts with varying usefulness

* recover-artifactory-rpm.bash
Specific use case when using "Artifactory" as a rpm store and it's in the cloud and it breaks, but you have the disk store backed up (snapshot), you can trawl through the .rpmcache directory to restore specific RPMs

* bashCoin.bash
Proof of Concept to create a blockchain in BASH in under 100 lines of code. It's not pretty, but it works (depending on how loose your definition of "works" is)

* awsGetSecurityGroups.bash
Script to extract all security groups from all regions under all profiles in AWS. Used to create a quick audit of the security applied across an AWS account
