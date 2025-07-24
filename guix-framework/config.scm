(use-modules (gnu)
	     (gnu packages version-control)
	     (gnu packages curl)
	     (gnu packages gnome)
	     (gnu packages compression) ; bluetooth
	     (gnu packages vim)
	     (gnu packages gnupg)
	     (gnu packages sync)
	     (nongnu packages linux)
	     (nongnu packages printers)
	     (nongnu system linux-initrd)
	     (nongnu packages firmware)) ; fwupd

(use-package-modules ssh
		     cups)

(use-service-modules cups 
		     desktop 
		     networking 
		     ssh 
		     xorg 
		     backup
		     virtualization 
		     authentication 
		     docker)
(modify-services %desktop-services
		 (gdm-service-type config =>
				   (gdm-configuration (inherit config) (wayland? #t))))


(operating-system
  (kernel linux)
  (initrd microcode-initrd)
  (firmware (list linux-firmware))
  (locale "en_IL.utf8")
  (timezone "Europe/Berlin")
  (keyboard-layout (keyboard-layout "us" #:options '("caps:escape_shifted_capslock")))
  (host-name "fwguix")
  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
		  (name "fwg")
		  (comment "Fwg")
		  (group "users")
		  (home-directory "/home/fwg")
		  (supplementary-groups '("wheel" "netdev" "audio" "video" "kvm")))
		%base-user-accounts))
  (packages 
    (append (list
	      ; Basic general utilities
	      neovim
	      git
	      curl
	      unzip
	      zip
	      gnupg
	      openssh
	      
	      ; Other admin tools
	      hplip ; necessary for printing services
	      hplip-plugin
	      fwupd-nonfree ; hardware update for fw13
	      
	      ; Backup tools 
	      rclone
	      
	      ; GNOME
	      gnome-tweaks
	      dconf-editor
	      )
	    %base-packages))
  ;; Below is the list of system services.  To search for available
  ;; services, run 'guix system search KEYWORD' in a terminal.
  (services
        (append (list (service gnome-desktop-service-type) ;; Currently version 46 of GNOME. 
		  ;(service fprintd-service-type) ;; Does not work right now - makes errors without fallback to password tries. So I keep it there to try with further updates of the system.
		  (service containerd-service-type)  
		  (service cups-service-type
			   (cups-configuration
			     (extensions
				(list cups-filters hplip-plugin))))
		  (service bluetooth-service-type
			   (bluetooth-configuration 
			     (auto-enable? #t)))
		  (set-xorg-configuration
		    (xorg-configuration
		      (keyboard-layout keyboard-layout)))) 
	    %desktop-services))
  (bootloader (bootloader-configuration
		(bootloader grub-efi-bootloader)
		(targets (list "/boot/efi"))
		(keyboard-layout keyboard-layout)))
  (swap-devices (list (swap-space
			(target (uuid
				  "XXX")))))
  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
			 (mount-point "/boot/efi")
			 (device (uuid "AF3A-B985"
				       'fat32))
			 (type "vfat"))
		       (file-system
			 (mount-point "/")
			 (device (uuid
				   "XXX"
				   'ext4))
			 (type "ext4"))
		       (file-system
			 (mount-point "/DATA")
			 (device (uuid
				   "XXX"
				   'ext4))
			 (type "ext4"))
			%base-file-systems)))
