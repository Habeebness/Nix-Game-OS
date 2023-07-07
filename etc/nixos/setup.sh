#!/run/current-system/sw/bin/bash

umount /mnt/boot
umount /mnt/home /mnt/nix
sleep 1
umount /mnt

sleep 5
printf "label: gpt\n,1GiB,U\n,32GiB,S\n,,L\n" | sfdisk /dev/disk/by-id/ata-Samsung_SSD_850_PRO_1TB_S2BBNWAJ402997Y -W always

sleep 5
mkfs.fat -F 32 -n BOOT /dev/disk/by-id/ata-Samsung_SSD_850_PRO_1TB_S2BBNWAJ402997Y-part1
mkswap -f -L SWAP /dev/disk/by-id/ata-Samsung_SSD_850_PRO_1TB_S2BBNWAJ402997Y-part2
mkfs.btrfs -f -L ROOT /dev/disk/by-id/ata-Samsung_SSD_850_PRO_1TB_S2BBNWAJ402997Y-part3

sleep 2
mount /dev/disk/by-id/ata-Samsung_SSD_850_PRO_1TB_S2BBNWAJ402997Y-part3 /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
umount /mnt

sleep 2
mount -o compress=zstd,subvol=root /dev/disk/by-id/ata-Samsung_SSD_850_PRO_1TB_S2BBNWAJ402997Y-part3 /mnt
mkdir /mnt/{home,nix}
mount -o compress=zstd,subvol=home /dev/disk/by-id/ata-Samsung_SSD_850_PRO_1TB_S2BBNWAJ402997Y-part3 /mnt/home
mount -o compress=zstd,noatime,subvol=nix /dev/disk/by-id/ata-Samsung_SSD_850_PRO_1TB_S2BBNWAJ402997Y-part3 /mnt/nix
mkdir /mnt/boot
mount /dev/disk/by-id/ata-Samsung_SSD_850_PRO_1TB_S2BBNWAJ402997Y-part1 /mnt/boot

sleep 2
mkdir -p /mnt/etc/nixos/
cp -vr /run/media/nixos/Data/etc/nixos/* /mnt/etc/nixos/
nixos-install --no-root-password
