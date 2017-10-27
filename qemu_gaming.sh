#!/bin/bash

# device ID's:
# NOTE: these also need to be in /etc/udev/rules.d/10-qemu-hw-users.rules
# 06a3:0762 - saitek x52 pro
# 044f:b108 - thrustmaster
# 28de:1142 - steam controller dongle
# 413c:2106 - dell keyboard
# 046d:c52b - logitech mx705
# 045e:028e - xbox360 wired controller
  # -usb -usbdevice host:045e:028e \
# 046d:c332 - proteus mouse
  # -usb -usbdevice host:046d:c332 \

export QEMU_PA_FRAGSIZE=256
echo "... QEMU_PA_FRAGSIZE=$QEMU_PA_FRAGSIZE"

echo "... sleeping 2s to avoid enter key getting grabbed"
sleep 2

cp /usr/share/edk2.git/ovmf-x64/OVMF_VARS-pure-efi.fd /tmp/my_vars.fd
echo "Starting VM ..."
# qemu-system-x86_64 -enable-kvm \
/home/dusty/gits/qemu/build/x86_64-softmmu/qemu-system-x86_64 -enable-kvm \
  -soundhw hda \
  -smp 4,sockets=1,cores=4,threads=1 \
  -cpu host,kvm=off \
  -m 16384 \
  -vga none \
  -rtc base=localtime \
  -device vfio-pci,host=01:00.0,multifunction=on \
  -device vfio-pci,host=01:00.1 \
  -object input-linux,id=kbd2,evdev=/dev/input/by-id/usb-Cooler_Master_Technology_Inc._MASTERKEYS_PRO_S_with_intelligent_RGB-if02-event-kbd,grab_all=on,repeat=on \
  -usb -usbdevice host:046d:c332 \
  -usb -usbdevice host:045e:028e \
  -drive if=pflash,format=raw,readonly,file=/usr/share/edk2.git/ovmf-x64/OVMF_CODE-pure-efi.fd \
  -drive if=pflash,format=raw,file=/tmp/my_vars.fd \
  -device virtio-scsi-pci,id=scsi \
  -drive file=/media/gaming/kvm/win.img,id=disk,format=qcow2,if=none,cache=writeback -device scsi-hd,drive=disk \
  -drive file=/media/storage/repo1/kvm/win_storage.img,id=disk2,format=qcow2,if=none,cache=writeback -device scsi-hd,drive=disk2 \
  -drive file=/media/storage/repo2/kvm/win_storage.img,id=disk3,format=qcow2,if=none,cache=writeback -device scsi-hd,drive=disk3 \
  -drive file=/home/dusty/kvm/virt.iso,id=virtiocd,if=none,format=raw -device ide-cd,bus=ide.1,drive=virtiocd \
  -net nic,model=virtio \
  -net tap,ifname=tap0,script=no,downscript=no


# random notes...
# enable sound
  # -soundhw hda \
# if you wanted to write directly to a physical device instead of img container
  # -drive file=/dev/sdb,id=disk,format=raw,if=none -device scsi-hd,drive=disk
# use this to insert windows install iso
  # -drive file=/home/dusty/kvm/win10.iso,id=isocd,format=raw,if=none -device scsi-cd,drive=isocd
# working network config
  #  -net nic,model=virtio \
  #  -net tap,ifname=tap0,script=no,downscript=no
# to display to a window on the host...
  #
# to display to a window on the host and NOT grab the second display...
# or, to grab the entire second display and NOT display in a window on host...
  # use `-vga none`

# working evdev passthrough...
  # -object input-linux,id=mouse1,evdev=/dev/input/by-id/usb-Logitech_Gaming_Mouse_G502_107B357D3130-event-mouse \
  # -object input-linux,id=mouse2,evdev=/dev/input/by-id/usb-Logitech_Gaming_Mouse_G502_107B357D3130-if01-event-kbd \
  # -object input-linux,id=kbd1,evdev=/dev/input/by-id/usb-Cooler_Master_Technology_Inc._MASTERKEYS_PRO_S_with_intelligent_RGB-event-kbd,grab_all=on,repeat=on \
  # -device virtio-mouse-pci \
  # -device virtio-keyboard-pci \

echo "VM closed ..."
