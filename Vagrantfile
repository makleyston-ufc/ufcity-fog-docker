Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "ufcity-fog"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "6144"
    vb.cpus = 1
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.name = "ufcity"
  end

  config.vm.network "public_network", bridge: "wlp3s0"
  config.vm.provision "shell", path: "ufcity-fog-install.sh"
end