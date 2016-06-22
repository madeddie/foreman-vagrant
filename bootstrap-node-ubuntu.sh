#!/bin/sh

# Run on VM to bootstrap Puppet Agent Ubuntu-based Linux nodes
# Gary A. Stafford - 02/27/2015
# Downgrade Puppet on box from 4.x to 3.x for Foreman 1.9
# http://theforeman.org/manuals/1.9/index.html#3.1.2PuppetCompatibility

if puppet agent --version | grep "^3."; then
  echo "Puppet Agent already installed, exiting"
  exit
fi

echo "Installing Puppet Agent..."

wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb && \
sudo dpkg -i puppetlabs-release-trusty.deb && \
sudo apt-get update && \
sudo apt-get install -y puppet

sudo sed -i 's/START=no/START=yes/' /etc/default/puppet

# Add agent section to /etc/puppet/puppet.conf (set run interval to 120s for testing)
echo "[agent]" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null && \
echo "server=theforeman.example.com" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null && \
echo "runinterval=120s" | sudo tee --append /etc/puppet/puppet.conf 2> /dev/null

sudo service puppet stop
sudo puppet resource service puppet ensure=running enable=true
sudo puppet agent --enable

# Unless you have Foreman autosign certs, each agent will hang on this step until you manually
# sign each cert in the Foreman UI (Infrastrucutre -> Smart Proxies -> Certificates -> Sign)
# Aternative, run manually on each host, after provisioning is complete...
#sudo puppet agent --test --waitforcert=60
