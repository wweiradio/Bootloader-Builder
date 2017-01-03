cd deploy/am335x_boneblack
MLO=MLO-am335x_boneblack-v2016.11-r4
IMG=u-boot-am335x_boneblack-v2016.11-r4.img
echo sudo dd if=$MLO of=/dev/sdc seek=1 conv=notrunc bs=128k
read a
sudo dd if=$MLO of=/dev/sdc seek=1 conv=notrunc bs=128k
echo sudo dd if=$IMG of=/dev/sdc count=2 seek=1 conv=notrunc bs=384k
read a
#sudo dd if=$IMG of=/dev/sdc count=2 seek=1 conv=notrunc bs=384k
sudo dd if=$IMG of=/dev/sdc seek=1 conv=notrunc bs=384k
sudo blockdev --flushbufs /dev/sdc
sync
