### Dual Boot, Sway, proprietary nvidia drivers, linux arch installation

#### Connect to the Internet

**For Wi-Fi:**

```sh
iwctl
> device list
> station <NAME> get-networks
> station <NAME> connect <NETWORK NAME>
> exit
```

**For Wired:**

```sh
dhcpcd
```

**Test Connection:**

```sh
ping google.com
```

#### Partition the Disk

```sh
lsblk
# Example
# NAME           MAJ:MIN  RM SIZE  RO  TYPE
# sda              7:0    0  698G  0  disk
# └── sda1         8:1    0  698G  0  part
# nvme0n1        259:0    0  953G  0  disk
# ├── nvme0n1p1  259:5    0  100M  0  part
# ├── nvme0n1p2  259:6    0   16M  0  part
# ├── nvme0n1p3  259:7    0  487G  0  part
# └── nvme0n1p4  259:8    0  775M  0  part

cfdisk /dev/nvme0n1
```

<!-- prettier-ignore -->
- Create partitions (Example for 32GB RAM, 1T storage):
  - Free space > [NEW] > SIZE: 512M, TYPE: EFI System
  - Free space > [NEW] > SIZE:   8G, TYPE: Linux Swap
  - Free space > [NEW] > SIZE:  40G, TYPE: Linux filesystem
  - Free space > [NEW] > SIZE:  ALL, TYPE: Linux filesystem
- Write changes and exit.

#### Format partitions

```sh
lsblk
# Example
# NAME           MAJ:MIN  RM SIZE  RO  TYPE
# sda              7:0    0  698G  0  disk
# └── sda1         8:0    0  698G  0  part
# nvme0n1        259:0    0  953G  0  disk
# ├── nvme0n1p1  259:1    0  100M  0  part
# ├── nvme0n1p2  259:2    0   16M  0  part
# ├── nvme0n1p3  259:3    0  487G  0  part
# ├── nvme0n1p4  259:4    0  775M  0  part
# ├── nvme0n1p5  259:9    0  512M  0  part
# ├── nvme0n1p6  259:10   0  7.5G  0  part
# ├── nvme0n1p7  259:11   0   40G  0  part
# └── nvme0n1p8  259:12   0  417G  0  part

# Format EFI
mkfs.fat -F32 /dev/nvme0n1p5

# Format Swap
mkswap /dev/nvme0n1p6
swapon /dev/nvme0n1p6

# Format Root
mkfs.ext4 /dev/nvme0n1p7

# Format Home
mkfs.ext4 /dev/nvme0n1p8
```

#### Mount partitions

```sh
# Mount Root partition
mount /dev/nvme0n1p7 /mnt

# Mount EFI partition
mkdir /mnt/boot
mount /dev/nvme0n1p5 /mnt/boot

# Mount Home partition
mkdir /mnt/home
mount /dev/nvme0n1p8 /mnt/home
```

#### Install the Base System

```sh
pacstrap /mnt base linux linux-firmware nano sudo networkmanager
```

#### Generate fstab

```sh
genfstab -U /mnt >> /mnt/etc/fstab
```

#### Change Root into the New System

```sh
arch-chroot /mnt
```

#### Set Root Password and Create User

```sh
passwd

useradd -m -g users -G wheel,storage,power,video,audio -s /bin/bash <USERNAME>
passwd <USERNAME>

EDITOR=nano visudo
# uncomment:
# %wheel ALL=(ALL:ALL) ALL
# %sudo ALL=(ALL:ALL) ALL
# CTRL + o, enter, CTRL + x
```

#### Configure Time Zone and Localization

```sh
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc

nano /etc/locale.gen
# uncomment en_GB.UTF-8 UTF-8
# CTRL + o, enter, CTRL + x

echo "LANG=en_GB.UTF-8" > /etc/local.conf
```

#### Set Hostname

```sh
echo "archlinux" > /etc/hostname

nano /etc/hosts
# Add the following lines
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain archlinux
# CTRL + o, enter, CTRL + x
```

#### Install and Configure GRUB

```sh
pacman -S grub efibootmgr dosfstools mtools os-prober

# Install GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Enable NetworkManager
systemctl enable NetworkManager

exit
```

#### Unmount and Reboot

```sh
umount -lR /mnt
shutdown now
# Unplug USB
```

### Post-Installation

```sh
nmcli dev status # Check network
nmcli radio wifi on
nmcli dev wifi list

sudo nmcli dev wifi connect "<SSID>" password "<PASSWORD>"

ping google.com # Test connection

git clone https://github.com/Maxdep0/dotfiles.git
cd dotfiles
bash setup.sh
```
