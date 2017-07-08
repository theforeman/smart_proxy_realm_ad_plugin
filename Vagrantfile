# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|

  config.vm.define "smart_proxy" do |smart_proxy|
    smart_proxy.vm.box = "centos/7"
    smart_proxy.vm.network "public_network"
    smart_proxy.vm.hostname = "smartproxy"
    smart_proxy.vm.synced_folder ".", "/src"
    smart_proxy.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
    smart_proxy.vm.provision "shell", inline: <<-SHELL
      yum update -y
    SHELL
    smart_proxy.vm.provision "shell", path: "./scripts/setup_smart_proxy.sh"
  end

  #config.vm.define "domain_controller" do |domain_controller|
  #  domain_controller.vm.box = "mwrock/Windows2012R2"
  #  domain_controller.vm.network "public_network"
  #  domain_controller.vm.network "forwarded_port", guest: 3389, host: 3389
  #  domain_controller.vm.hostname = "dc"
  #  domain_controller.vm.provider "virtualbox" do |vb|
  #    vb.memory = "2048"
  #  end
  #end

  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"
  # config.vm.synced_folder "../data", "/vagrant_data"
  # config.vm.provider "virtualbox" do |vb|
  #   vb.gui = true
  #   vb.memory = "1024"
  # end
end