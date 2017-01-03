#!/bin/sh -e
#
# Copyright (c) 2010-2016 Robert Nelson <robertcnelson@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

DIR=$PWD
TEMPDIR=$(mktemp -d)

ARCH=$(uname -m)
SYST=$(uname -n)

if [ "x${ARCH}" = "xi686" ] ; then
	echo "Linaro no longer supports 32bit cross compilers, thus 32bit is no longer suppored by this script..."
	exit
fi

# Number of jobs for make to run in parallel.
CORES=$(getconf _NPROCESSORS_ONLN)

. ./version.sh

git="git am"

#Debian 7 (Wheezy): git version 1.7.10.4 and later needs "--no-edit"
unset git_opts
git_no_edit=$(LC_ALL=C git help pull | grep -m 1 -e "--no-edit" || true)
if [ ! "x${git_no_edit}" = "x" ] ; then
	git_opts="--no-edit"
fi

mkdir -p ${DIR}/git/
mkdir -p ${DIR}/dl/
mkdir -p ${DIR}/deploy/

rm -rf ${DIR}/deploy/latest-bootloader.log || true

#export MIRROR="http://example.com"
#./build.sh
if [ ! "${MIRROR}" ] ; then
	MIRROR="http:"
fi

if [ -d $HOME/dl/gcc/ ] ; then
	gcc_dir="$HOME/dl/gcc"
else
	gcc_dir="${DIR}/dl"
fi

wget_dl="wget -c --directory-prefix=${gcc_dir}/"

dl_gcc_generic () {
	site="https://releases.linaro.org"
	archive_site="https://releases.linaro.org/archive"
	non_https_site="http://releases.linaro.org"
	non_https_archive_site="http://releases.linaro.org/archive"
	WGET="wget -c --directory-prefix=${gcc_dir}/"
	if [ ! -f "${gcc_dir}/${directory}/${datestamp}" ] ; then
		echo "Installing: ${toolchain_name}"
		echo "-----------------------------"
		${WGET} "${site}/${version}/${filename}" || ${WGET} "${archive_site}/${version}/${filename}" || ${WGET} "${non_https_site}/${version}/${filename}" || ${WGET} "${non_https_archive_site}/${version}/${filename}"
		if [ -d "${gcc_dir}/${directory}" ] ; then
			rm -rf "${gcc_dir}/${directory}" || true
		fi
		tar -xf "${gcc_dir}/${filename}" -C "${gcc_dir}/"
		if [ -f "${gcc_dir}/${directory}/${binary}gcc" ] ; then
			touch "${gcc_dir}/${directory}/${datestamp}"
		fi
	fi

	if [ "x${ARCH}" = "xarmv7l" ] ; then
		#using native gcc
		CC=
	else
		if [ -f /usr/bin/ccache ] ; then
			CC="ccache ${gcc_dir}/${directory}/${binary}"
		else
			CC="${gcc_dir}/${directory}/${binary}"
		fi
	fi
}

#NOTE: ignore formatting, as this is just: meld build.sh ../stable-kernel/scripts/gcc.sh
gcc_arm_embedded_4_9 () {
		#
		#https://releases.linaro.org/components/toolchain/binaries/4.9-2016.02/arm-eabi/gcc-linaro-5.3-2016.02-x86_64_arm-eabi.tar.xz
		#

		gcc_version="4.9"
		release="16.02"
		target="arm-eabi"

		version="components/toolchain/binaries/${gcc_version}-20${release}/${target}"
		filename="gcc-linaro-${gcc_version}-20${release}-x86_64_arm-eabi.tar.xz"
		directory="gcc-linaro-${gcc_version}-20${release}-x86_64_arm-eabi"

		datestamp="${gcc_version}-20${release}-${target}"

		binary="bin/arm-eabi-"

	dl_gcc_generic
}

gcc_arm_embedded_5 () {
		#
		#https://releases.linaro.org/components/toolchain/binaries/5.3-2016.05/arm-eabi/gcc-linaro-5.3.1-2016.05-rc2-i686_arm-eabi.tar.xz
		#

		gcc_version="5.3"
		release="16.05"
		target="arm-eabi"

		version="components/toolchain/binaries/${gcc_version}-20${release}/${target}"
		filename="gcc-linaro-${gcc_version}.1-20${release}-x86_64_arm-eabi.tar.xz"
		directory="gcc-linaro-${gcc_version}.1-20${release}-x86_64_arm-eabi"

		datestamp="${gcc_version}-20${release}-${target}"

		binary="bin/arm-eabi-"

	dl_gcc_generic
}

gcc_arm_embedded_6 () {
		#
		#https://releases.linaro.org/components/toolchain/binaries/6.2-2016.11/arm-eabi/gcc-linaro-6.2.1-2016.11-x86_64_arm-eabi.tar.xz
		#
		#site="https://snapshots.linaro.org"

		gcc_version="6.2"
		release="16.11"
		target="arm-eabi"

		version="components/toolchain/binaries/${gcc_version}-20${release}/${target}"
		filename="gcc-linaro-${gcc_version}.1-20${release}-x86_64_arm-eabi.tar.xz"
		directory="gcc-linaro-${gcc_version}.1-20${release}-x86_64_arm-eabi"

		datestamp="${gcc_version}-20${release}-${target}"

		binary="bin/arm-eabi-"

	dl_gcc_generic
}

gcc_linaro_gnueabihf_4_9 () {
		#
		#https://releases.linaro.org/components/toolchain/binaries/4.9-2016.02/arm-linux-gnueabihf/gcc-linaro-4.9-2016.02-x86_64_arm-linux-gnueabihf.tar.xz
		#

		gcc_version="4.9"
		release="16.02"
		target="arm-linux-gnueabihf"

		version="components/toolchain/binaries/${gcc_version}-20${release}/${target}"
		filename="gcc-linaro-${gcc_version}-20${release}-x86_64_${target}.tar.xz"
		directory="gcc-linaro-${gcc_version}-20${release}-x86_64_${target}"

		datestamp="${gcc_version}-20${release}-${target}"

		binary="bin/${target}-"

	dl_gcc_generic
}

gcc_linaro_gnueabihf_5 () {
		#
		#https://releases.linaro.org/components/toolchain/binaries/5.3-2016.02/arm-linux-gnueabihf/gcc-linaro-5.3-2016.02-x86_64_arm-linux-gnueabihf.tar.xz
		#

		gcc_version="5.3"
		release="16.05"
		target="arm-linux-gnueabihf"

		version="components/toolchain/binaries/${gcc_version}-20${release}/${target}"
		filename="gcc-linaro-${gcc_version}.1-20${release}-x86_64_${target}.tar.xz"
		directory="gcc-linaro-${gcc_version}.1-20${release}-x86_64_${target}"

		datestamp="${gcc_version}-20${release}-${target}"

		binary="bin/${target}-"

	dl_gcc_generic
}

gcc_linaro_gnueabihf_6 () {
		#
		#https://releases.linaro.org/components/toolchain/binaries/6.2-2016.11/arm-linux-gnueabihf/gcc-linaro-6.2.1-2016.11-x86_64_arm-linux-gnueabihf.tar.xz
		#
		#site="https://snapshots.linaro.org"

		gcc_version="6.2"
		release="16.11"
		target="arm-linux-gnueabihf"

		version="components/toolchain/binaries/${gcc_version}-20${release}/${target}"
		filename="gcc-linaro-${gcc_version}.1-20${release}-x86_64_${target}.tar.xz"
		directory="gcc-linaro-${gcc_version}.1-20${release}-x86_64_${target}"

		datestamp="${gcc_version}-20${release}-${target}"

		binary="bin/${target}-"

	dl_gcc_generic
}

git_generic () {
	echo "Starting ${project} build for: ${board}"
	echo "-----------------------------"

	if [ ! -f ${DIR}/git/${project}/.git/config ] ; then
		git clone git://github.com/RobertCNelson/${project}.git ${DIR}/git/${project}/
	fi

    echo "pull the ${project}"
    if [ ! -d ${DIR}/git/${project} ] ; then
        cd ${DIR}/git/${project}/
        git pull ${git_opts} || true
        git fetch --tags || true
        cd -
    fi

    # need to keep the project
	if [ -d ${DIR}/scratch/${project} ] ; then
	    echo "keep the directory since it already there"
		#rm -rf ${DIR}/scratch/${project} || true
		cd ${DIR}/scratch/${project}
		NO_PATCH=1
	else

        mkdir -p ${DIR}/scratch/${project}
	    # clone to a local directory
	    git clone --shared ${DIR}/git/${project} ${DIR}/scratch/${project}

        # now in the scatch directory
        cd ${DIR}/scratch/${project}
        if [ "${GIT_SHA}" ] ; then
            echo "Checking out: ${GIT_SHA}"
            git checkout ${GIT_SHA} -b ${project}-scratch
        fi

	fi

}

git_cleanup () {
	cd ${DIR}/

	#rm -rf ${DIR}/scratch/${project} || true

	echo "${project} build completed for: ${board}"
	echo "-----------------------------"
}

halt_patching_uboot () {
	pwd
	echo "-----------------------------"
	echo "make ARCH=arm CROSS_COMPILE=\"${CC}\" distclean"
	echo "make ARCH=arm CROSS_COMPILE=\"${CC}\" ${uboot_config}"
	echo "make ARCH=arm CROSS_COMPILE=\"${CC}\" ${BUILDTARGET}"
	echo "-----------------------------"
	exit
}

file_save () {
	cp -v ./${filename_search} ${DIR}/${filename_id}
	md5sum=$(md5sum ${DIR}/${filename_id} | awk '{print $1}')
	check=$(ls "${DIR}/${filename_id}#*" 2>/dev/null | head -n 1)
	if [ "x${check}" != "x" ] ; then
		rm -rf "${DIR}/${filename_id}#*" || true
	fi
	touch ${DIR}/${filename_id}_${md5sum}
	echo "${board}#${MIRROR}/${filename_id}#${md5sum}" >> ${DIR}/deploy/latest-bootloader.log
}


build_u_boot () {
	project="u-boot"
	git_generic
	# now in the scratch directory
	RELEASE_VER="-r0"

	make ARCH=arm CROSS_COMPILE="${CC}" distclean
	UGIT_VERSION=$(git describe)

	#v2016.09
	p_dir="${DIR}/patches/${uboot_old}"
	if [ "${old}" ] ; then
		#r1: initial release
		#r2: am335x_evm: enable CONFIG_OF_LIBFDT_OVERLAY
		#r3: am335x_evm: fix m10a
		#r4: am335x_evm: rewrite blank eeprom
		#r5: am335x_evm: lots of dts fixes, fits in 1MB hole..
		#r6: am335x_evm: eMMC on A5A/A6 is BROKEN with spl-dtb...
		#r7: am335x_evm: fix eMMC, thanks Dr.-Ing. Krzysztof Piotrowski!
		#r8: am335x_evm: bring back 1GB memory fix.. (might be my board..)
		#r9: am335x_evm: give sancloud more id's by default...
		#r10: (pending)
		RELEASE_VER="-r9" #bump on every change...
		#halt_patching_uboot

		case "${board}" in
		am335x_evm)
			echo "patch -p1 < \"${p_dir}/0001-Updated-to-include-uboot-support-for-MSCC-MINI-PHY-f.patch\""
			echo "patch -p1 < \"${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch\""
			${git} "${p_dir}/0001-Updated-to-include-uboot-support-for-MSCC-MINI-PHY-f.patch"
			${git} "${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch"
			;;
		am335x_boneblack)
			echo "patch -p1 < \"${p_dir}/0001-Updated-to-include-uboot-support-for-MSCC-MINI-PHY-f.patch\""
			echo "patch -p1 < \"${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch\""
			echo "patch -p1 < \"${p_dir}/0002-NFM-Production-eeprom-assume-device-is-BeagleBone-Bl.patch\""
			${git} "${p_dir}/0001-Updated-to-include-uboot-support-for-MSCC-MINI-PHY-f.patch"
			${git} "${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch"
			${git} "${p_dir}/0002-NFM-Production-eeprom-assume-device-is-BeagleBone-Bl.patch"
			;;
		esac
	fi

	#v2016.11
	p_dir="${DIR}/patches/${uboot_stable}"
	if [ "${stable}" ] &&  [ ! "${NO_PATCH}" ] ; then
		#r1: initial release
		#r2: am335x_evm: enable CONFIG_OF_LIBFDT_OVERLAY
		#r3: am335x_evm: arm: am33xx: Initialize EMIF REG_PR_OLD_COUNT for BBB and am335x-evm
		#r4: am335x_boneblack: arm: add_lcd_driver
		#r5: (pending)
		RELEASE_VER="-r4" #bump on every change...
		#halt_patching_uboot

		case "${board}" in
		am335x_evm)
			echo "patch -p1 < \"${p_dir}/0001-Adding-MSCC-PHY-VSC8530-VSC8531-VSC8540-VSC8541.patch\""
			echo "patch -p1 < \"${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch\""
			${git} "${p_dir}/0001-Adding-MSCC-PHY-VSC8530-VSC8531-VSC8540-VSC8541.patch"
			${git} "${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch"
			;;
		am335x_boneblack)
			echo "patch -p1 < \"${p_dir}/0001-Adding-MSCC-PHY-VSC8530-VSC8531-VSC8540-VSC8541.patch\""
			echo "patch -p1 < \"${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch\""
			echo "patch -p1 < \"${p_dir}/0002-NFM-Production-eeprom-assume-device-is-BeagleBone-Bl.patch\""
			echo "patch -p1 < \"${p_dir}/001.add_lcd_driver.patch\""
			${git} "${p_dir}/0001-Adding-MSCC-PHY-VSC8530-VSC8531-VSC8540-VSC8541.patch"
			${git} "${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch"
			${git} "${p_dir}/0002-NFM-Production-eeprom-assume-device-is-BeagleBone-Bl.patch"
			${git} "${p_dir}//001.add_lcd_driver.patch"
			;;
		esac
	fi

	#v2017.01
	p_dir="${DIR}/patches/${uboot_testing}"
	if [ "${testing}" ] ; then
		#r1: initial release
		#r2: am335x_evm: arm: am33xx: Initialize EMIF REG_PR_OLD_COUNT for BBB and am335x-evm
		#r3: am335x_evm: dtb_overlay=file.dtbo
		#r4: am335x_evm: dtb_overlay=file.dtbo (call fdt resize)
		#r5: am335x_evm: cape manager...
		#r6: (pending)
		RELEASE_VER="-r5" #bump on every change...
		#halt_patching_uboot

		case "${board}" in
		am335x_evm)
			echo "patch -p1 < \"${p_dir}/0001-Adding-MSCC-PHY-VSC8530-VSC8531-VSC8540-VSC8541.patch\""
			echo "patch -p1 < \"${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch\""
			echo "patch -p1 < \"${p_dir}/0002-U-Boot-BeagleBone-Cape-Manager.patch\""
			${git} "${p_dir}/0001-Adding-MSCC-PHY-VSC8530-VSC8531-VSC8540-VSC8541.patch"
			${git} "${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch"
			${git} "${p_dir}/0002-U-Boot-BeagleBone-Cape-Manager.patch"
			;;
		am335x_boneblack)
			echo "patch -p1 < \"${p_dir}/0001-Adding-MSCC-PHY-VSC8530-VSC8531-VSC8540-VSC8541.patch\""
			echo "patch -p1 < \"${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch\""
			echo "patch -p1 < \"${p_dir}/0002-U-Boot-BeagleBone-Cape-Manager.patch\""
			echo "patch -p1 < \"${p_dir}/0002-NFM-Production-eeprom-assume-device-is-BeagleBone-Bl.patch\""
			${git} "${p_dir}/0001-Adding-MSCC-PHY-VSC8530-VSC8531-VSC8540-VSC8541.patch"
			${git} "${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch"
			${git} "${p_dir}/0002-U-Boot-BeagleBone-Cape-Manager.patch"
			${git} "${p_dir}/0002-NFM-Production-eeprom-assume-device-is-BeagleBone-Bl.patch"
			;;
		esac
	fi

	p_dir="${DIR}/patches/next"
	if [ "${next}" ] ; then
		#r1: initial release
		#r2: (pending)
		RELEASE_VER="-r1" #bump on every change...
		#halt_patching_uboot

		case "${board}" in
		am335x_evm)
			echo "patch -p1 < \"${p_dir}/0001-Adding-MSCC-PHY-VSC8530-VSC8531-VSC8540-VSC8541.patch\""
			echo "patch -p1 < \"${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch\""
			echo "patch -p1 < \"${p_dir}/0002-U-Boot-BeagleBone-Cape-Manager.patch\""
			${git} "${p_dir}/0001-Adding-MSCC-PHY-VSC8530-VSC8531-VSC8540-VSC8541.patch"
			${git} "${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch"
			${git} "${p_dir}/0002-U-Boot-BeagleBone-Cape-Manager.patch"
			;;
		am335x_boneblack)
			echo "patch -p1 < \"${p_dir}/0001-Adding-MSCC-PHY-VSC8530-VSC8531-VSC8540-VSC8541.patch\""
			echo "patch -p1 < \"${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch\""
			echo "patch -p1 < \"${p_dir}/0002-U-Boot-BeagleBone-Cape-Manager.patch\""
			echo "patch -p1 < \"${p_dir}/0002-NFM-Production-eeprom-assume-device-is-BeagleBone-Bl.patch\""
			${git} "${p_dir}/0001-Adding-MSCC-PHY-VSC8530-VSC8531-VSC8540-VSC8541.patch"
			${git} "${p_dir}/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch"
			${git} "${p_dir}/0002-U-Boot-BeagleBone-Cape-Manager.patch"
			${git} "${p_dir}/0002-NFM-Production-eeprom-assume-device-is-BeagleBone-Bl.patch"
			;;

		esac
	fi

	unset BUILDTARGET

	if [ -f "${DIR}/stop.after.patch" ] ; then
		echo "-----------------------------"
		pwd
		echo "-----------------------------"
		echo "make ARCH=arm CROSS_COMPILE=\"${CC}\" ${uboot_config}"
		echo "make ARCH=arm CROSS_COMPILE=\"${CC}\" ${BUILDTARGET}"
		echo "-----------------------------"
		exit
	fi

	uboot_filename="${board}-${UGIT_VERSION}${RELEASE_VER}"

	mkdir -p ${DIR}/deploy/${board}

	unset pre_built
	if [ -f ${DIR}/deploy/${board}/u-boot-${uboot_filename}.imx ] ; then
		pre_built=1
	fi

	if [ -f ${DIR}/deploy/${board}/u-boot-${uboot_filename}.sb ] ; then
		pre_built=1
	fi

	if [ -f ${DIR}/deploy/${board}/MLO-${uboot_filename} ] ; then
		pre_built=1
	fi

	if [ -f ${DIR}/deploy/${board}/u-boot-${uboot_filename}.sunxi ] ; then
		pre_built=1
	fi

	if [ -f ${DIR}/deploy/${board}/u-boot-${uboot_filename}.bin ] ; then
		pre_built=1
	fi

	if [ -f ${DIR}/force_rebuild ] ; then
		unset pre_built
	fi

	if [ ! "${pre_built}" ] ; then
		make ARCH=arm CROSS_COMPILE="${CC}" ${uboot_config} > /dev/null
		echo "Building ${project}: ${uboot_filename}:"
		make ARCH=arm CROSS_COMPILE="${CC}" -j${CORES} ${BUILDTARGET} > /dev/null

		unset UBOOT_DONE

		#SPL based targets, need MLO and u-boot.img from u-boot
		if [ ! "${UBOOT_DONE}" ] && [ -f ${DIR}/scratch/${project}/MLO ] && [ -f ${DIR}/scratch/${project}/u-boot.img ] ; then
			filename_search="MLO"
			filename_id="deploy/${board}/MLO-${uboot_filename}"
			file_save

			filename_search="u-boot.img"
			filename_id="deploy/${board}/u-boot-${uboot_filename}.img"
			file_save
			UBOOT_DONE=1
		fi

		#Just u-boot.bin
		if [ ! "${UBOOT_DONE}" ] && [ -f ${DIR}/scratch/${project}/u-boot.bin ] ; then
			filename_search="u-boot.bin"
			filename_id="deploy/${board}/u-boot-${uboot_filename}.bin"
			file_save
			UBOOT_DONE=1
		fi
		echo "-----------------------------"
	else
		echo "-----------------------------"
		echo "Skipping Binary Build: as [${uboot_filename}] was previously built."
		echo "To override skipping(and force rebuild): [touch force_rebuild]"
		echo "-----------------------------"
	fi

	git_cleanup
}

cleanup () {
	unset GIT_SHA
	unset transitioned_to_testing
	unset uboot_config
	build_old="false"
	build_stable="false"
	build_testing="false"
}


build_uboot_old () {
	if [ "x${build_old}" = "xtrue" ] ; then
		old=1
		if [ "${uboot_old}" ] ; then
			GIT_SHA=${uboot_old}
			build_u_boot
		fi
		unset old
		build_old="false"
	fi
}

build_uboot_stable () {
	if [ "x${build_stable}" = "xtrue" ] ; then
		stable=1
		if [ "${uboot_stable}" ] ; then
			GIT_SHA=${uboot_stable}
			build_u_boot
		fi
		unset stable
		build_stable="false"
	fi
}

build_uboot_testing () {
	if [ "x${build_testing}" = "xtrue" ] ; then
		testing=1
		if [ "${uboot_testing}" ] ; then
			GIT_SHA=${uboot_testing}
			build_u_boot
		fi
		unset testing
		build_testing="false"
	fi

}

build_uboot_latest () {
	next=1
	if [ "${uboot_latest}" ] ; then
		GIT_SHA=${uboot_latest}
		build_u_boot
	fi
	unset next
}

build_uboot_eabi () {
	if [ "x${uboot_config}" = "x" ] ; then
		uboot_config="${board}_defconfig"
	fi
	gcc_arm_embedded_5
	build_uboot_old
	gcc_arm_embedded_6
	build_uboot_stable
	build_uboot_testing
	build_uboot_latest
}

build_uboot_gnueabihf () {
	if [ "x${uboot_config}" = "x" ] ; then
		uboot_config="${board}_defconfig"
	fi
	gcc_linaro_gnueabihf_5
	build_uboot_old
	gcc_linaro_gnueabihf_6
	build_uboot_stable
	build_uboot_testing
	build_uboot_latest
}

build_uboot_gnueabihf_only_old () {
	if [ "x${uboot_config}" = "x" ] ; then
		uboot_config="${board}_defconfig"
	fi
	gcc_linaro_gnueabihf_5
	build_uboot_old
}

build_uboot_gnueabihf_only_stable () {
	if [ "x${uboot_config}" = "x" ] ; then
		uboot_config="${board}_defconfig"
	fi
	gcc_linaro_gnueabihf_6
	build_uboot_stable
}

always_stable_n_testing () {
	cleanup
	if [ ! "x${build_stable}" = "x" ] ; then
		build_stable="true"
	fi
	if [ ! "x${uboot_testing}" = "x" ] ; then
		build_testing="true"
	fi
	build_uboot_gnueabihf
}

always_testing () {
	cleanup
	if [ ! "x${uboot_testing}" = "x" ] ; then
		build_testing="true"
	fi
	build_uboot_gnueabihf
}


am335x_boneblack_flasher () {
	cleanup
	rm -rf deploy/am335x_boneblack/*
#	build_old="true"
	build_stable="true"
#	build_testing="true"

	board="am335x_boneblack"
	uboot_config="am335x_evm_defconfig"
	#build_uboot_gnueabihf
	build_uboot_gnueabihf_only_stable
}


am335x_boneblack_flasher

#rpi_2


#
