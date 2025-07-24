(use-modules (gnu home)
	     (gnu home services)
	     (guix profiles)
	     (gnu home services sway)
	     (gnu home services shells)
	     (gnu packages tmux)
	     (gnu packages video)
	     (gnu packages gnuzilla)
	     (gnu packages password-utils)
	     (gnu packages ncdu) 
	     (gnu packages disk)
	     (gnu packages package-management)
	     (gnu packages python-xyz)
	     (gnu packages virtualization) 
	     (nongnu packages messaging)
	     (gnu services)
	     (gnu packages cups)
	     (gnu packages tor-browsers)
	     (gnu packages tor)
	     (gnu packages sync)
	     (gnu packages xdisorg)
	     (gnu system shadow)
	     (gnu packages vim)
	     (gnu packages linux)
	     (gnu packages pdf)
	     (gnu packages ocr)
	     (gnu packages libreoffice)
	     (gnu packages engineering)
	     (gnu packages admin)
	     (nongnu packages game-client)
	     (guix gexp))

;; This is a sample Guix Home configuration which can help setup your
;; home directory in the same declarative manner as Guix System.
;; For more information, see the Home Configuration section of the manual.
(home-environment
  (packages (list neovim 
		  ranger
		  strace 
		  btop 
		  ncdu 
		  gparted
		  pdftk 
		  netcat
		  tmux
		  neofetch
		  keepassxc
		  
		  virt-manager 
		  libreoffice 
		  vlc

		  icecat
		  torbrowser 
		  torsocks 
		  tesseract-ocr 


		  signal-desktop
		  nextcloud-client
		  icedove

		  freecad
		  prusa-slicer
		  
		  flatpak
		  steam
		  ))
  (services
    (append
      (list
	;; Uncomment the shell you wish to use for your user:
	;(service home-sway-service-type)
	(service home-bash-service-type
		 (home-bash-configuration
		   (aliases '(("grep" . "grep --color=auto")
			      ("vi" . "nvim")
			      ("vim" . "nvim")
			      ;; Two commands usefull to get differences between current and last version of configurations (resp. home and system)
			      ("diffconf" . "diff -u --color $(guix system list-generations| grep 'configuration file'|tail -n 2|cut -d' ' -f5)")
			      ("diffhome" . "diff -u --color $(guix home list-generations| grep 'configuration file'|tail -n 2|cut -d' ' -f5)")

		       ("l" . "ls -laF --color=auto")))
		   ;; https://lists.gnu.org/archive/html/help-guix/2021-02/msg00028.html
		   (bash-profile (list (plain-file "bash-profile" "\
# MAKE FLATPAK APPLICATION LAUNCHERS AVAILABLE IN GUIX'S GNOME
export XDG_DATA_DIRS=\"$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share\"
export XDG_DATA_DIRS=\"$XDG_DATA_DIRS:/var/lib/flatpak/exports/share\""
		    )))))

       (service home-files-service-type
				`((".guile" ,%default-dotguile)
				  (".Xdefaults" ,%default-xdefaults)))

       (service home-xdg-configuration-files-service-type
				`(("gdb/gdbinit" ,%default-gdbinit)
				  ("nano/nanorc" ,%default-nanorc))))

     %base-home-services)))
