<details>
<summary>Arch Linux Installation</summary>
<br>

<blockquote>
  <strong style="color:orange">Warning:</strong> 
        This guide is not intended for others, but for me.
        If by chance someone install linux arch using this guide,
        you have to change the <a href="#Partition-the-disks">partition size</a>, <a href="#Select-the-mirrors">mirrors</a> and <a href="#Time-And-localization">Time and Localization</a>.<br>
</blockquote>

<span style="font-size:17px"> [Arch Linux Downloads](https://archlinux.org/download/)
</span><br>
<span style="font-size:17px"> [Open source tool to create bootable driver with multiple ISOs + storage](https://www.ventoy.net/en/index.html)
</span><br>
<span style="font-size:17px">[Turn off fast startup in wondows 11](https://www.elevenforum.com/t/turn-on-or-off-fast-startup-in-windows-11.1212/)
</span><br>
<span style="font-size:17px"> [Disable fast start up and hibernation](https://wiki.archlinux.org/title/Dual_boot_with_Windows#Disable_Fast_Startup_and_disable_hibernation)
</span><br>
<span style="font-size:17px"> [Secure Boot](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#Before_booting_the_OS)
</span>

# [Installation](https://wiki.archlinux.org/title/Installation_guide#Configure_the_system)

### Connect to the internet

```zsh
$ iwctl

> device list
> station "wlan" get-networks
> station "wlan" connect "Network Name"
> "Enter Password"
> exit

# Test connecton
$ ping google.com

# Update keyring ( Without latest ISO it probably throw storage error )
$ pacman -Syu archlinux-keyring

```

### Partition the disks

[Recommended Partition Scheme](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/installation_guide/s2-diskpartrecommend-x86#idm140491990747664)
<span style="font-size:15px"> </span>

```zsh
$ lsblk
# NAME           MAJ:MIN  RM    SIZE  RO   TYPE   MOUNTPOINTS
# loop0            7:0     0  792.2M   1   loop   /run/archiso/airroofs
# sda              8:0     0  698.6G   0   disk
# ├── sda1         8:1     0  698.6G   0   part
# │   └── ventoy 254:0     0    1.1G   1     dm
# └── sda2         8:2     0     32M   0   part
# nvme0n1        259:0     0  953.9G   0   disk   <<
# ├── nvme0n1p1  259:1     0    100M   0   part
# ├── nvme0n1p2  259:2     0     16M   0   part
# ├── nvme0n1p3  259:3     0  464.7G   0   part
# └── nvme0n1p4  259:4     0    775M   0   part

$ cfdisk /dev/nvme0n1
> Select free space > [ New ] >   1G > [ Type ] > EFI System
> Select free space > [ New ] >  40G > [ Type ] > Linux filesystem
> Select free space > [ New ] > 440G > [ Type ] > Linux filesystem
> Select free space > [ New ] > 7.3G > [ Type ] > Linux Swap
> [ write ]
> [ quit ]

```

### Format the partitions

```zsh

$ lsblk
# NAME           MAJ:MIN  RM    SIZE  RO   TYPE   MOUNTPOINTS
# loop0            7:0     0  792.2M   1   loop   /run/archiso/airroofs
# sda              8:0     0  698.6G   0   disk
# ├── sda1         8:1     0  698.6G   0   part
# │   └── ventoy 254:0     0    1.1G   1     dm
# └── sda2         8:2     0     32M   0   part
# nvme0n1        259:0     0  953.9G   0   disk
# ├── nvme0n1p1  259:1     0    100M   0   part
# ├── nvme0n1p2  259:2     0     16M   0   part
# ├── nvme0n1p3  259:3     0  464.7G   0   part
# └── nvme0n1p4  259:4     0    775M   0   part
# ├── nvme0n1p5  259:13    0      1G   0   part   # EFI
# ├── nvme0n1p6  259:14    0     40G   0   part   # Root
# ├── nvme0n1p7  259:15    0    440G   0   part   # Home
# └── nvme0n1p8  259:16    0    7.3G   0   part   # Swap

# EFI
$ mkfs.fat -F32 /dev/nvme0n1p5

# Root
$ mkfs.ext4 /dev/nvme0n1p6

# Home
$ mkfs.ext4 /dev/nvme0n1p7

# Swap
$ mkswap /dev/nvme0n1p8
$ swapon /dev/nvme0n1p8

```

### Mount the file systems

```zsh

# Root
$ mount /dev/nvme0n1p6 /mnt

# Home
$ mkdir /mnt/home
$ mount /dev/nvme0n1p7 /mnt/home

# EFI
$ mkdir -p /mnt/boot/efi
$ mount /dev/nvme0n1p5 /mnt/boot/efi

$ lsblk

# NAME           MAJ:MIN  RM    SIZE  RO   TYPE   MOUNTPOINTS
# loop0            7:0     0  792.2M   1   loop   /run/archiso/airroofs
# sda              8:0     0  698.6G   0   disk
# ├── sda1         8:1     0  698.6G   0   part
# │   └── ventoy 254:0     0    1.1G   1     dm
# └── sda2         8:2     0     32M   0   part
# nvme0n1        259:0     0  953.9G   0   disk
# ├── nvme0n1p1  259:1     0    100M   0   part
# ├── nvme0n1p2  259:2     0     16M   0   part
# ├── nvme0n1p3  259:3     0  464.7G   0   part
# └── nvme0n1p4  259:4     0    775M   0   part
# ├── nvme0n1p5  259:13    0      1G   0   part  /mnt/boot/efi
# ├── nvme0n1p6  259:14    0     40G   0   part  /mnt
# ├── nvme0n1p7  259:15    0    440G   0   part  /mnt/home
# └── nvme0n1p8  259:16    0    7.3G   0   part  [Swap]
```

### Select the [mirrors](https://en.wikipedia.org/wiki/ISO_3166-1)

<span style="font-size:15px">[Reclector](https://wiki.archlinux.org/title/reflector), [examples](https://man.archlinux.org/man/reflector.1#EXAMPLES)</span><br>
<span style="font-size:15px">[Two-letter country codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements)
</span>

```zsh
$ cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

$ reflector --country GB,DE,FR,NL,SE,CZ,SK --protocol https --latest 20 --sort rate --age 48 --completion-percent 100 --fastest 10 --save /etc/pacman.d/mirrorlist
```

### Install essential [packages](https://wiki.archlinux.org/title/installation_guide#Select_the_mirrors)

```zsh
$ pacstrap -K /mnt base linux linux-firmware base-devel sudo vim
```

### Configure the system

```zsh
# Generate an fstab file
$ genfstab -U /mnt >> /mnt/etc/fstab

# Change root into the new system
$ arch-chroot /mnt
```

### Time and Localization

```zsh
# Set the time zone
$ ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

$ hwclock --systohc

#Edit locale.gen and uncomment needed UTF-8 locales.
$ vim /etc/locale.gen
# en_GB.UTF-8 UTF-8

$ locale-gen

$ echo "LANG=en_GB.UTF-8" > /etc/locale.conf
```

### Network Configuration

```zsh
$ echo "archlinux" > /etc/hostname

$ vim /etc/hosts
#     127.0.0.1		localhost
#     ::1			localhost
#     127.0.1.1		archlinux.localdomain	archlinux

```

### Create User

<span style="font-size:15px">[Users and groups](https://wiki.archlinux.org/title/users_and_groups) </span><br>
<span style="font-size:15px">[Security](https://wiki.archlinux.org/title/security) </span>

```zsh
$ passwd

$ useradd -m -g users -G wheel,storage,power,video,audio -s /bin/bash "USERNAME"
$ passwd "USERNAME"

$ EDITOR=vim visudo
# Uncomment:
# %wheel ALL=(ALL:ALL) ALL
# %wheel ALL=(ALL:ALL) NOPASSWD: ALL
```

### Setup [GRUB](https://wiki.archlinux.org/title/GRUB) and [Network Manager](https://wiki.archlinux.org/title/Network_configuration#Network_management)

<span style="font-size:15px">[Boot Loaders](https://wiki.archlinux.org/title/Arch_boot_process#Boot_loader) </span>

```zsh
$ pacman -Syu grub efibootmgr networkmanager git openssh stow

$ lsblk
# NAME           MAJ:MIN  RM    SIZE  RO   TYPE   MOUNTPOINTS
# loop0            7:0     0  792.2M   1   loop   /run/archiso/airroofs
# sda              8:0     0  698.6G   0   disk
# ├── sda1         8:1     0  698.6G   0   part
# │   └── ventoy 254:0     0    1.1G   1     dm
# └── sda2         8:2     0     32M   0   part
# nvme0n1        259:0     0  953.9G   0   disk
# ├── nvme0n1p1  259:1     0    100M   0   part
# ├── nvme0n1p2  259:2     0     16M   0   part
# ├── nvme0n1p3  259:3     0  464.7G   0   part
# └── nvme0n1p4  259:4     0    775M   0   part
# ├── nvme0n1p5  259:13    0      1G   0   part  /boot/efi
# ├── nvme0n1p6  259:14    0     40G   0   part  /
# ├── nvme0n1p7  259:15    0    440G   0   part  /home
# └── nvme0n1p8  259:16    0    7.3G   0   part  [Swap]

$ grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
$ grub-mkconfig -o /boot/grub/grub.cfg

$ systemctl enable NetworkManager

$ exit
$ umount -lR /mnt
$ shutdown now

# Disconnect USB
```

### Post-installation

<span style="font-size:15px">[General recommendations](https://wiki.archlinux.org/title/General_recommendations) </span><br>
<span style="font-size:15px">[Avoid certain pacman commands](https://wiki.archlinux.org/title/System_maintenance#Avoid_certain_pacman_commands)
</span>

```zsh
# Connect to the internet
$ nmcli dev status
$ nmcli radio wifi on
$ nmcli dev wifi list
$ nmcli dev wifi connect "SSID" password "PASSWORD"

$ sudo pacman -Syu

# Clone dotfiles
$ https://github.com/Maxdep0/dotfiles.git

$ chsh -s `which zsh`

$ reboot

# Create SSH
$ ssh-keygen -t ed25519 -C "EMAIL ADDRESS"
> "Enter"
> "PASSWORD"
> "PASSWORD"
$ eval `ssh-agent -s`
$ ssh-add ~/.ssh/id_ed25519
$ cat ~/.ssh/id_ed25519.pub

# Add SSH to GitHub and change url
$ git remote set-url origin git@github.com/Maxdep0/dotfiles.git
```

</details>
