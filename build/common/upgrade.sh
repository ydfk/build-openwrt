#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001
# AutoBuild Functions

GET_TARGET_INFO() {
	case "${TARGET_PROFILE}" in
	x86-64)
		if [ `grep -c "CONFIG_TARGET_IMAGES_GZIP=y" ${Home}/.config` -eq '1' ]; then
			Firmware_sfxo="img.gz"
		else
			Firmware_sfxo="img"
		fi
	;;
	esac
	case "${REPO_BRANCH}" in
	"master")
		LUCI_Name="18.06"
		REPO_Name="lede"
		ZUOZHE="Lean's"
		if [[ "${TARGET_PROFILE}" == "x86-64" ]]; then
			Legacy_Firmware="openwrt-x86-64-generic-squashfs-combined.${Firmware_sfxo}"
			UEFI_Firmware="openwrt-x86-64-generic-squashfs-combined-efi.${Firmware_sfxo}"
			Firmware_sfx="${Firmware_sfxo}"
		elif [[ "${TARGET_PROFILE}" == "phicomm_k3" ]]; then
			Up_Firmware="openwrt-bcm53xx-generic-phicomm_k3-squashfs.trx"
			Firmware_sfx="trx"
		else
			Up_Firmware="openwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade.bin"
			Firmware_sfx="bin"
		fi
	;;
	"19.07") 
		LUCI_Name="19.07"
		REPO_Name="lienol"
		ZUOZHE="Lienol's"
		if [[ "${TARGET_PROFILE}" == "x86-64" ]]; then
			Legacy_Firmware="openwrt-x86-64-combined-squashfs.${Firmware_sfxo}"
			UEFI_Firmware="openwrt-x86-64-combined-squashfs-efi.${Firmware_sfxo}"
			Firmware_sfx="${Firmware_sfxo}"
		elif [[ "${TARGET_PROFILE}" == "phicomm-k3" ]]; then
			Up_Firmware="openwrt-bcm53xx-phicomm-k3-squashfs.trx"
			Firmware_sfx="trx"
		else
			Up_Firmware="openwrt-${TARGET_BOARD}-${TARGET_SUBTARGET}-${TARGET_PROFILE}-squashfs-sysupgrade.bin"
			Firmware_sfx="bin"
		fi
	;;
	esac
	[ ${REGULAR_UPDATE} == "true" ] && {
		AutoUpdate_Version=$(egrep -o "V[0-9].+" ${Home}/package/base-files/files/bin/AutoUpdate.sh | awk 'END{print}')
	} || AutoUpdate_Version=OFF
	In_Firmware_Info="${Home}/package/base-files/files/etc/openwrt_info"
	Github_Release="${Github}/releases/download/AutoUpdate"
	Github_Tags="https://api.github.com/repos/${Apidz}/releases/tags/AutoUpdate"
	Github_UP_RELEASE="${Github}/releases/AutoUpdate"
	Openwrt_Version="${REPO_Name}-${TARGET_PROFILE}-${Compile_Date}"
	Egrep_Firmware="${LUCI_Name}-${REPO_Name}-${TARGET_PROFILE}"
}

Diy_Part1() {
	sed -i '/luci-app-autoupdate/d' .config > /dev/null 2>&1
	echo -e "\nCONFIG_PACKAGE_luci-app-autoupdate=y" >> .config
	sed -i '/luci-app-ttyd/d' .config > /dev/null 2>&1
	echo -e "\nCONFIG_PACKAGE_luci-app-ttyd=y" >> .config
}

Diy_Part2() {
	GET_TARGET_INFO
	cat >${In_Firmware_Info} <<-EOF
	Github=${Github}
	Author=${Author}
	CangKu=${CangKu}
	Luci_Edition=${OpenWrt_name}
	CURRENT_Version=${Openwrt_Version}
	DEFAULT_Device=${TARGET_PROFILE}
	Firmware_Type=${Firmware_sfx}
	LUCI_Name=${LUCI_Name}
	REPO_Name=${REPO_Name}
	Github_Release=${Github_Release}
	Github_Tags=${Github_Tags}
	Egrep_Firmware=${Egrep_Firmware}
	Download_Path=/tmp/Downloads
	EOF
}

Diy_Part3() {
	GET_TARGET_INFO
	AutoBuild_Firmware="${LUCI_Name}-${Openwrt_Version}"
	Firmware_Path="${Home}/upgrade"
	Mkdir ${Home}/bin/Firmware
	if [[ `ls ${Home}/upgrade | grep -c "sysupgrade.bin"` -eq '1' ]]; then
		mv ${Home}/upgrade/*sysupgrade.bin ${Home}/bin/Firmware/${Up_Firmware}
		mv ${Home}/bin/Firmware/${Up_Firmware} ${Home}/upgrade/${Up_Firmware}
	fi
	cd ${Firmware_Path}
	case "${TARGET_PROFILE}" in
	x86-64)
		[[ -f ${Legacy_Firmware} ]] && {
			cp ${Legacy_Firmware} ${Home}/bin/Firmware/${AutoBuild_Firmware}-Legacy.${Firmware_sfx}
		}
		[[ -f ${UEFI_Firmware} ]] && {
			cp ${UEFI_Firmware} ${Home}/bin/Firmware/${AutoBuild_Firmware}-UEFI.${Firmware_sfx}
		}
	;;
	friendlyarm_nanopi-r2s | friendlyarm_nanopi-r4s | armvirt) 
		echo "R2S/R4S/N1/晶晨系列,暂不支持定时更新固件!" > Update_Logs.json
		cp Update_Logs.json ${Home}/bin/Firmware/Update_Logs.json
	;;
	*)
		[[ -f ${Up_Firmware} ]] && {
			cp ${Up_Firmware} ${Home}/bin/Firmware/${AutoBuild_Firmware}.${Firmware_sfx}
		} || {
			echo "Firmware is not detected !"
		}
	;;
	esac
	cd ${Home}
}

Mkdir() {
	_DIR=${1}
	if [ ! -d "${_DIR}" ];then
		mkdir -p ${_DIR}
	fi
	unset _DIR
}

Diy_xinxi() {
	Diy_xinxi_Base
}
