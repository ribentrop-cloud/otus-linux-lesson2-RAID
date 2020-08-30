# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :otuslinux => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.101',
	:disks => {
		:sata1 => {
			:dfile => './sata1.vdi',
			:size => 250,
			:port => 1
		},
		:sata2 => {
                        :dfile => './sata2.vdi',
                        :size => 250, # Megabytes
			:port => 2
		},
                :sata3 => {
                        :dfile => './sata3.vdi',
                        :size => 250,
                        :port => 3
                },
                :sata4 => {
                        :dfile => './sata4.vdi',
                        :size => 250, # Megabytes
                        :port => 4
                },
		:sata5 => {
                        :dfile => './sata5.vdi',
                        :size => 250, # Megabytes
                        :port => 5
		}
	}		
  },
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

      config.vm.define boxname do |box|

          box.vm.box = boxconfig[:box_name]
          box.vm.host_name = boxname.to_s

          #box.vm.network "forwarded_port", guest: 3260, host: 3260+offset

          box.vm.network "private_network", ip: boxconfig[:ip_addr]

          box.vm.provider :virtualbox do |vb|
            	  vb.customize ["modifyvm", :id, "--memory", "1024"]
                  needsController = false
		  boxconfig[:disks].each do |dname, dconf|
			  unless File.exist?(dconf[:dfile])
				vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                                needsController =  true
                          end

		  end
                  if needsController == true
                     vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                     boxconfig[:disks].each do |dname, dconf|
                         vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                     end
                  end
          end
 	  box.vm.provision "shell", inline: <<-SHELL
			mkdir -p ~root/.ssh
              cp ~vagrant/.ssh/auth* ~root/.ssh
			yum install -y mdadm smartmontools hdparm gdisk sgdisk
			sudo sh -c "yes |  mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}"
			sleep 3
			sudo mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}

			while  [ "$(sudo mdadm -D /dev/md0 | grep "Rebuild Status")" ] ; do
			  echo "...rebuilding RAID. Rebuild status : $(sudo mdadm -D /dev/md0 | grep "Rebuild Status" | awk '{print $4}')"
			  sleep 1
			done
			echo "RAID rebuild done"

			echo "$(sudo mdadm -D /dev/md0) | grep "Raid Level")" &&
			echo "$(sudo mdadm -D /dev/md0) | grep "Array Size")" &&
			echo "$(sudo mdadm -D /dev/md0) | grep "Raid Devices")" &&

			sudo mkdir /etc/mdadm
			sudo sh -c 'echo "DEVICE partitions" > /etc/mdadm/mdadm.conf'
			sudo sh -c 'sudo mdadm --detail --scan --verbose | grep ARRAY >> /etc/mdadm/mdadm.conf'
			echo "--- FIN ---"
			
			sudo sgdisk --clear /dev/md0
			sudo sgdisk -n 1:34:10000 -n 2:10001:20000 -n 3:20001:30000 -n 4:30001:40000 -n 5:40001:50000 /dev/md0
			sudo sgdisk --print /dev/md0
			for item in {1..5}
				do
				sudo mkfs.ext4 /dev/md0p$item
				sleep 3
				sudo mkdir /mnt/raid10_$item
				sudo echo 'UUID='`blkid /dev/md0p$item -s UUID -o value`' /mnt/raid10_'$item'           ext4    defaults        0 1' >> /etc/fstab
			done
  	  SHELL
      end
  end
end

