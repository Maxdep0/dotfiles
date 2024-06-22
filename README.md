### Dual Boot, Sway, proprietary nvidia drivers, linux arch installation

#### Step 1: Connect to the Internet

**For Wi-Fi:**

```sh
iwctl
> device list
> station <DEVICE> get-networks
> station <DEVICE> connect <SSID>
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

#### Step 2: Partition the Disk

```sh
lsblk
cfdisk /dev/nvme0n1
```

- Create partitions (Example for 32GB RAM, 1T storage):
  - EFI partition: 512M
  - Linux Swap: 8G
  - Root partition: 40G
  - Home partition: Remaining space
- Write changes and exit.

#### Step 3: Format partitions

```sh
# Format EFI
mkfs.fat -F32 /dev/nvme0n1p1

# Format Swap
mkswap /dev/nvme0n1p2
swapon /dev/nvme0n1p2

# Format Root
mkfs.ext4 /dev/nvme0n1p3

# Format Home
mkfs.ext4 /dev/nvme0n1p4
```

#### Step 4: Mount partitions

```sh
# Mount Root partition
mount /dev/nvme0n1p3 /mnt

# Mount EFI partition
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# Mount Home partition
mkdir /mnt/home
mount /dev/nvme0n1p4 /mnt/home
```

#### Step 5: Install the Base System

```sh
pacstrap /mnt base linux linux-firmware nano
```

#### Step 6: Generate fstab

```sh
genfstab -U /mnt >> /mnt/etc/fstab
```

#### Step 7: Change Root into the New System

```sh
arch-chroot /mnt
```

#### Step 8: Set Root Password and Create User

```sh
passwd

useradd -m -g users -G wheel,storage,power,video,audio -s /bin/bash <USERNAME>
passwd <USERNAME>
```

#### Step 9: Configure Time Zone and Localization

```sh
nano /etc/local.gen
# uncomment en_GB.UTF-8 UTF-8
# CTRL + o, enter, CTRL + x

ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc

echo "LANG=en_GB.UTF-8" > /etc/locale.conf
```

#### Step 10: Set Hostname and Configure /etc/hosts

```sh
echo "archlinux" > /etc/hostname

nano /etc/hosts
# Add the following lines
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain archlinux
# CTRL + o, enter, CTRL + x
```

#### Step 11: Install and Configure GRUB

```sh
pacman -S grub efibootmgr dosfstools mtools os-prober git

# Install GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Enable NetworkManager
systemctl enable NetworkManager

exit
```

#### Step 12: Unmount and Reboot

```sh
umount -lR /mnt
shutdown now
# Unplug USB
```

### Post-Installation: Connect to Wi-Fi (if needed)

```sh
nmcli dev status # Check network
nmcli radio wifi on
nmcli dev wifi list

sudo nmcli dev wifi connect "<WIFI NAME>" password "<PASSWORD>"

ping google.com # Test connection
```
