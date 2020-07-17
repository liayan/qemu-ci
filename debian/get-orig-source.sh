#! /bin/sh

set -e

base=https://download.qemu.org/
comp=.xz

dir() {
  if [ -d $1 ]; then
     echo removing $1/...
     rm -rf $1
  fi
}

clean_dfsg() {
# remove only those blobs which does not have packaged source
# remove all other blobs too

rm -vf pc-bios/bios.bin		# roms/seabios/
rm -vf pc-bios/bios-256k.bin	# roms/seabios/
rm -vf pc-bios/bios-microvm.bin	# roms/qboot/
rm -vf pc-bios/hppa-firmware.img	# roms/seabios-hppa/
rm -vf pc-bios/sgabios.bin	# roms/sgabios/
rm -vf pc-bios/slof.bin		# roms/SLOF/
rm -vf pc-bios/vgabios*.bin	# roms/vgabios/
rm -vf pc-bios/pxe-*.rom	# roms/ipxe/
rm -vf pc-bios/efi-*.rom	# roms/ipxe/
rm -vf pc-bios/edk2-*.fd.bz2	# roms/edk2/
rm -vf pc-bios/bamboo.dtb	# pc-bios/bamboo.dts
rm -vf pc-bios/canyonlands.dtb
rm -vf pc-bios/openbios-*	# roms/openbios/
rm -vf pc-bios/opensbi-*.bin	# roms/opensbi/
rm -vf pc-bios/palcode-clipper	# roms/qemu-palcode/ alpha palcode
rm -vf pc-bios/s390-ccw.img	# pc-bios/s390-ccw/
rm -vf pc-bios/s390-netboot.img	# pc-bios/s390-ccw/
rm -vf pc-bios/kvmvapic.bin	# pc-bios/optionrom/
rm -vf pc-bios/linuxboot*.bin	# ditto
rm -vf pc-bios/multiboot.bin	# ditto
rm -vf pc-bios/pvh.bin		# ditto
rm -vf pc-bios/skiboot.lid	# roms/skiboot/
rm -vf pc-bios/u-boot.e500	# roms/u-boot/
rm -vf pc-bios/u-boot-sam460-20100605.bin	# roms/u-boot-sam460ex/
rm -vf pc-bios/QEMU,*.bin	# roms/openbios/
rm -vf pc-bios/qemu_vga.ndrv	# roms/QemuMacDrivers/

# remove other software (git submodules)
dir roms/ipxe		# separate package
dir roms/seabios	# separate package
rm -vf roms/SLOF/board-js2x/rtas/i2c_bmc.oco
rm -vf roms/SLOF/board-js2x/rtas/ipmi_oem.oco
rm -vf roms/SLOF/clients/takeover/takeover.oco
rm -vf roms/SLOF/lib/libipmi/libipmi.oco
dir roms/edk2		# separate package
dir roms/u-boot		# separate package
rm -vf roms/u-boot.tar.*
#dir roms/u-boot-sam460ex # this one is not built by u-boot and requires older compiler
dir roms/QemuMacDrivers

dir dtc		# system dtc exists and used
dir capstone	# system capstone exists and used
dir slirp	# system libslirp exists and used

}

case "$#$1" in
  1clean | 1dfsg)
    if [ -f softmmu/vl.c -a -f hw/block/block.c -a -d pc-bios ]; then
      clean_dfsg
      exit 0
    fi
    echo "apparently not a qemu source dir" >&2; exit 1
    ;;

  1[2-6].*) ;;

  *)
    echo "unknown arguments.  Should be either 'dfsg' or a version number" >&2
    exit 1
    ;;
esac

deb="${1%-*}" # strip debian revision number
upstream="${deb%+dfsg}"
case "$upstream" in
   *~rc*) upstream=$(echo "$upstream" | sed 's/~rc/-rc/') ;;
esac
case "$upstream" in
   [2-6].[0-9] | [2-6].[0-9][!0-9.]* ) # add .0 to a version number
     upstream=$(echo "$upstream" | sed 's/^.\../&.0/') ;;
esac

tempdir=qemu-$upstream-tmp
basetar=qemu-$upstream.tar$comp
debtar=qemu_$deb.orig.tar.xz

if [ ! -f $basetar ]; then

  echo getting upstream version $upstream ...
  wget -Nc $base/$basetar

fi

if [ ! -f $debtar ]; then

  echo extracting source in $tempdir and cleaning up ...
  rm -rf $tempdir
  mkdir $tempdir
  cd $tempdir
  tar -x -f ../$basetar --strip-components=1
  clean_dfsg

  echo repacking to $debtar ...
  find . -type f -print | sort \
    | XZ_OPT="-v6" \
      tar -caf ../$debtar -T- --owner=root --group=root --mode=a+rX \
         --xform "s/^\\./qemu-$upstream/"

  cd ..
  rm -rf $tempdir

fi
