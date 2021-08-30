# see configs/devices/i386/default.mak
# for additional devices which can be disabled
#
CONFIG_PCI_DEVICES=n

# we can't disable all machine types (boards) as of 6.1
# since the resulting binary fails to link
#CONFIG_ISAPC=y
#CONFIG_I440FX=y
CONFIG_Q35=y
CONFIG_MICROVM=y

CONFIG_VIRTIO_BLK=y
CONFIG_VIRTIO_SERIAL=y
CONFIG_VIRTIO_INPUT=y
CONFIG_VIRTIO_NET=y
CONFIG_VIRTIO_SCSI=y
CONFIG_VIRTIO_RNG=y
CONFIG_VIRTIO_CRYPTO=y
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MEM=y
CONFIG_VIRTIO_PMEM=y
