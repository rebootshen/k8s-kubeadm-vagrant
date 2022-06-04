BOX_IMAGE = "generic/centos7"
#"Centos/7"
SETUP_MASTER = true
SETUP_NODES = true
NODE_COUNT = 2
MASTER_IP = "192.168.100.2"
NODE_IP_NW = "192.168.100."
POD_NW_CIDR = "10.244.0.0/16"


#Generate new using steps in README
KUBETOKEN = "b029ee.968a33e8d8e6bb0d"

Vagrant.configure("2") do |config|
  config.vm.box = BOX_IMAGE
  config.vm.box_check_update = false
  
  config.vagrant.plugins = [
    "vagrant-env",
    "vagrant-reload"
  ]
  config.env.enable
  config.vagrant.sensitive = [
    ENV['SMB_USERNAME'],
    ENV['SMB_PASSWORD'],
  ]
  config.vm.synced_folder ".", "/vagrant", type: "smb", smb_username: ENV['SMB_USERNAME'], smb_password: ENV['SMB_PASSWORD']

  config.trigger.before :up do |trigger|
      trigger.info = "Creating 'VagrantNATSwitch' Hyper-V switch if it does not exist..."
      trigger.run = {privileged: "true", powershell_elevated_interactive: "true", path: "./scripts/create-nat-hyperv-switch.ps1"}
  end


  if SETUP_MASTER
    config.vm.define "master" do |subconfig|
      subconfig.vm.provider "hyperv" do |h|
        h.cpus = 2
        h.memory = "6144"
        h.maxmemory = "6144"
        h.vmname = "master"
      end
      subconfig.vm.hostname = "master"
      
      subconfig.vm.provision :shell, preserve_order: true do |shell|
        shell.path = "./scripts/configure-static-ip.sh"
        shell.env = {"IP" => MASTER_IP}
      end
      
      subconfig.vm.provision :reload, preserve_order: true

      subconfig.trigger.before :reload do |trigger|
          trigger.info = "Setting Hyper-V switch to 'VagrantNATSwitch' to allow for static IP..."
          trigger.run = {privileged: "true", powershell_elevated_interactive: "true", path: "./scripts/set-hyperv-switch.ps1", args: [" -vmname master"]}
      end
  
      subconfig.vm.provision :shell, path: "scripts/common.sh"
      subconfig.vm.provision :shell, path: "scripts/master.sh"
    end
  end
  
  if SETUP_NODES
    (1..NODE_COUNT).each do |i|
      config.vm.define "node#{i}" do |subconfig|
        subconfig.vm.provider "hyperv" do |h|
          h.cpus = 2
          h.memory = "6144"
          h.maxmemory = "6144"
          h.vmname = "node#{i}"
        end
      
        subconfig.vm.hostname = "node#{i}"
        
        subconfig.vm.provision :shell, preserve_order: true do |shell|
          shell.path = "./scripts/configure-static-ip.sh"
          shell.env = {"IP" => NODE_IP_NW + "#{i + 2}"}
        end
        
        subconfig.vm.provision :reload, preserve_order: true

        subconfig.trigger.before :reload do |trigger|
            trigger.info = "Setting Hyper-V switch to 'VagrantNATSwitch' to allow for static IP..."
            trigger.run = {
              privileged: "true", 
              powershell_elevated_interactive: "true", 
              path: "./scripts/set-hyperv-switch.ps1", 
              args: [
                " -vmname node#{i}"
              ]
            }
        end
      
        subconfig.vm.provision :shell, path: "scripts/common.sh"
        subconfig.vm.provision :shell, path: "scripts/node.sh"
      end
    end
  end
end
