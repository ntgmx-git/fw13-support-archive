# Migration from Fedora to GuixSD on the Framework 13 AMD

## Principle
I would like to transfer my daily driver laptop from Fedora 42 to Guix System. Without having issue continuing my current workload, and adding some capabilities specific to Guix. 

The idea is to lost a few things as possible during the migration, and be as close as possible from a full Guix managed system.

I need the system to be working as soon at it release. I then used the guix capacity to be "plug and play" once you have a working configuration file. I took one on Framework 250GB expansions card, installed Guix System on top of it and ran tests until getting a "transparent" transition. 

Once the system is ready, the idea is to backup and wipeup fedora's partition, and throw up Guix on that new partition. Then, just send channels, system configuration and home configuration files. And just launch the install.

## Applications management
Guix uses channels as kind of repos where packages are available. Since the Framework laptop includes some proprietary blobs, I have to use the nonguix channel. 

With the default channel and nonguix channel, I was able to get almost everything done. 

There are only two applications that required flatpak for 

## Configuration
A snippet of the current system and home configuration is available on this repo. Lets describe some of them.


## Migration itself
Since I already had a guix system instance installed on the second "disk" (framework 250GB expension card), I wanted to avoid going through the installation process with a live USB. Also, installing Guix from my first Guix instance would be nice because I wanted to duplicate the system.

Also, its always useful to have access to a nice and clean web browser and to be able to c&p stuff to your terminal from during an installation. 

The setup was:
Disk A
	Part1 EFI
	Part2 FEDORA
	Part3 DATA
Disk B (expansion card)
	Part1 EFI 
	Part2 SWAP
	Part3 GUIX

And for this simple first installation, the final setup should be:
Disk A	
	Part1 EFI (new)
	Part2 GUIX (whole / part)
	Part3 DATA (untouched)


So steps where:
1. Wipe out the DiskA part 1 & Part 2 stuff
2. Create some new partitions with cfdisk on these 
3. mkfs.fat -F 32 /DiskA/part1 && mkfs.ext4 -L GUIX /DiskA/part2
4. Follow roughly all classic Guix manual install - aside from the `herd start cow-store` part. That service is only available on the installation ISO. I just skipped this part and it seems to be alright.
	4.1 Mount /dev/diskA/part2 on /mnt
	4.2 Create `/etc/boot/efi` 
	4.3 Mount /dev/diskA/part1 on /mnt/boot/efi 
	4.4 Copy system configuration to /mnt/etc/config.scm
	4.5 Copy channels.scm file to /mnt/etc/channels.scm
	4.6 Copy user home.scm to /etc (to move it later)
	4.7 Run `guix system init /mnt`
	4.8 Unmount and reboot

5. At that point rebooting worked first try. Then its pull & reconfigure both home and system stuff. 
#### Custom services and stuff
On top of classical service, I wanted to get some specific:
- A synchronization service that is able to backup some important data to me with:
	Remote server -> Local
	- Local -> Local (different disk or partition)
	- Local -> NFS Share
	- Local -> Cloud drive (Coonfigured with Proton Drive, but if it works for it I am pretty sure it would be the case for other Cloud storage services)
Both for small files of configuration an broader folders. 


### Backup service
The best thing I can think of right now is a shephred service for this. And with this, I could either "wait for automatic backup" on a cron like management or just start it when I want by "starting" the service. [To be done, 

### Apps
### Wireguard VPN
I already had multiple VPN configurations for remote accesses and so on. The thing is that these connections are not always compatible with each other and should not be up all the time. 

I had the choice between using the home configuration, the system configuration, the wg-quick tool, the ip tool, the GNOME GUI tool and maybe some others. 

Since I already have all configuration files already available (wgX.conf) and because it ran smoothly, I decided to use the GNOME setting configuration. With the import option, I setup once my 3-4 interfaces and I can toggle them whenever I want. 

I would like to try setting up these with a shephred service (like herd start wg0, wg1 etc.) but I will take a look at it later.

## Things that does not work yet
- The fingerprint service works but when I was not able to login with this. Plus, the system did not fallback in password login mode so I was just not able to login via the GUI. I keep the service commented waiting for other tests or another update.
- Wayland monitor: when I plug the laptop to an external display everything is fine both on Xorg & Wayland. But on Walyand ("GNOME" option of the login screen), as soon as I unplug the external display I get dark borders on the whole screen (like 1 centimeter). I did not investigate more so far, staying on the other option works fine so far.

## Switches
- Thunderbird is not available by default -> the icedove packet replace it 100%. You could just not see the difference if the name wasn't changed. Import / Export tools compatibles of course. 
- Firefox uses some invasive telemetry stuff -> Icecat is the free software version.


### Errors and tips 
#### Finding modules for packets
Beginners read this if you are like me at the beginning, wondering what module to import at the beginning of a configuration file to get one package.
You just have to get 

### Flatpak applications not showing in GNOME launcher menu
I had to install two apps with flatpak to get them quickly, but they did not appeared at first in the GNOME launching menu. I was able to run them with `flatpak run com.XXX.XXX` but this is not very convenient. From some messages of the mailling list, the problem can be solved by setting some XDG_DATA_DIRS variable in the bash_profile of the user. Therefore, I modified the service such as:
```bash
(service home-bash-service-type
 (home-bash-configuration
  (aliases '(("grep" . "grep --color=auto")
	     ("vi" . "nvim")
	     ("vim" . "nvim")
	     ;; Two commands usefull to get differences between current and last version of configurations (resp. home and system)
	     ("diffconf" . "diff -u --color $(guix system list-generations| grep 'configuration file'|tail -n 2|cut -d" " -f5)")
	     ("diffhome" . "diff -u --color $(guix home list-generations| grep 'configuration file'|tail -n 2|cut -d" " -f5)")

	     ("l" . "ls -laF --color=auto")))

  ;; https://lists.gnu.org/archive/html/help-guix/2021-02/msg00028.html
  (bash-profile (list (plain-file "bash-profile" "\
# MAKE FLATPAK APPLICATION LAUNCHERS AVAILABLE IN GUIX'S GNOME
		       export XDG_DATA_DIRS=\"$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share\"
		       export XDG_DATA_DIRS=\"$XDG_DATA_DIRS:/var/lib/flatpak/exports/share\""
		      )))))
```

## Usefull command
Two lines of codes are quite usefull to check differences between you current configuration and the previous one. Here are both versions for guix system and guix home:

```bash
# guix home
diff -u --color $(guix home list-generations| grep 'configuration file'|tail -n 2|cut -d" " -f5)


# guix system
diff -u --color $(guix system list-generations|grep 'configuration file'|tail -n 2|cut -d" " -f5)
```

Adding two aliases `diffhome` and `diffconf` (home.scm and config.scm) as shown in bash home service configuration is nice to have. 

## HP printer
I was not able to register a new printer at first. Also, not able to print with an HP 38xx device. Solving the issue consisted to just configure the cups service as:
```bash
(use-package-modules 
		...
		cups
		...)
...
(packages (append (list 
		...
		hplip
		hplip-plugin
		...
		)))
(services (append (list
		...
		(service cups-service-type
			   (cups-configuration
			     (extensions
				(list cups-filters hplip-plugin))))
		...)))
```

Then, just logout and login. Start the HP device manager app and add the printer. Then everything worked fine for me.


### `no code for module (nongnu)`
Often you do not really want to pull when you changed just a tiny bit of your configuration. A beginner frustrating error is when guix throws the message: `No code for module xxx`. Here, just export the path as mentionned in a pull command execution solves the problem on my side: 
```
export PATH="/root/.config/guix/current/bin:$PATH"
hash guix
```

## Using a pull mirror
Using substitutes urls is very usefull since original servers are not always as available as wished (503 errors mainly).
I do not want to have to remember all the time substitutes urls. Therefore, I just added one or two inside a file and call them with:
```
guix pull --url=$(cat substitutes)
```

# Trying to contribute and adding packages
The appealing part of Guix is the provided capability to help quite easily to package some stuff. I will try to learn about this - knowing that I am coming from far away since I am not a developer. 
## Simple cases
First things first, the easiest packages to learn are packages from gnu like the gnu hello wolrd, some simples packages such as `ls` command for instance.

## A harder one - Apache Guacamole
On long term I wish I could use Guix on servers, at least for package management and if possible with a full Guix System instance running. On such server, I would like to get some software as Apache Guacamole. So far I did not find it in Guix packages so I guess it would be a good try. 

### Guacamole server
I was able to get a running service with this code. However, I do not have time to get further right now. I hope I will have some more time at one point.
