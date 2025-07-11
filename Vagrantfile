Vagrant.configure("2") do |config|
  config.vm.box = "boxomatic/centos-7"
  #this centos box has active repositories configured and latest vbox guest additions
  config.vm.hostname = "shebang-con-vm"
  config.vm.network "private_network", ip: "192.168.56.101"
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  # config.vm.provision "shell", path: "pre_bootstrap.sh", privileged: true

  
  # config.ssh.username = 'vagrant'
	# config.ssh.password = 'vagrant'
	config.ssh.insert_key = 'true'

  config.vm.provision "shell", path: "bootstrap.sh"
  config.vm.provider "virtualbox" do |vb|
    vb.name = "shebang-con-vm"

    vb.memory = 4086
    vb.cpus = 2
  end
end
