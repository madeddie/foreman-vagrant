#!/bin/sh

# Run on VM to bootstrap the Foreman server
# Gary A. Stafford - 01/15/2015
# Modified - 08/19/2015
# Downgrade Puppet on box from 4.x to 3.x for Foreman 1.9 
# http://theforeman.org/manuals/1.9/index.html#3.1.2PuppetCompatibility

if puppet agent --version | grep "^3."; then
  echo "Puppet Agent already installed, exiting"
  exit
fi

echo "Installing Puppet Agent and Foreman..."

wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb && \
sudo dpkg -i puppetlabs-release-trusty.deb && \
echo "deb http://deb.theforeman.org/ trusty 1.9" | sudo tee /etc/apt/sources.list.d/foreman.list
echo "deb http://deb.theforeman.org/ plugins 1.9" | sudo tee -a /etc/apt/sources.list.d/foreman.list
wget -q http://deb.theforeman.org/pubkey.gpg -O- | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y puppet foreman-installer
sudo sed -i 's/START=no/START=yes/' /etc/default/puppet
sudo foreman-installer --foreman-admin-password admin

# First run the Puppet agent on the Foreman host which will send the first Puppet report to Foreman,
# automatically creating the host in Foreman's database
sudo puppet agent --test --waitforcert=60

# Optional, install some optional puppet modules on Foreman server to get started...
sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-ntp
sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-git
sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-vcsrepo
sudo puppet module install -i /etc/puppet/environments/production/modules jfryman-nginx
sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-postgresql
#sudo puppet module install -i /etc/puppet/environments/production/modules garethr-docker
#sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-haproxy
#sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-apache
#sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-java
