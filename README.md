A simple setup for setting up Magento environment using vagrant and puppet

1. Add your git key (public and private) in 
puppet\modules\git\files
2. If it is a fresh Magento install, change install flag to true and uncomment version you wish to install in  puppet/manifests/base.pp file. Make sure you switch install flag to false after the first install.
3. Check the vagrantfile for vm RAM etc configuration.
4. 'vagrant up'


-------------------------------------------------------------
