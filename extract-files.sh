#!/bin/bash

# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DEVICE=falcon
MANUFACTURER=motorola

if [[ -z "${ANDROIDFS_DIR}" ]]; then
    ANDROIDFS_DIR=../../../backup-${DEVICE}
fi

if [[ ! -d ../../../backup-${DEVICE}/system ]]; then
    echo Backing up system partition to backup-${DEVICE}
    mkdir -p ../../../backup-${DEVICE} &&
    adb root &&
    sleep 1 &&
    adb wait-for-device &&
    adb pull /system ../../../backup-${DEVICE}/system
fi

if [[ -z "${ANDROIDFS_DIR}" ]]; then
    echo Pulling files from device
    DEVICE_BUILD_ID=`adb shell cat /system/build.prop | grep ro.build.display.id | sed -e 's/ro.build.display.id=//' | tr -d '\n\r'`
else
    echo Pulling files from ${ANDROIDFS_DIR}
    DEVICE_BUILD_ID=`cat ${ANDROIDFS_DIR}/system/build.prop | grep ro.build.display.id | sed -e 's/ro.build.display.id=//' | tr -d '\n\r'`
fi

BASE_PROPRIETARY_DEVICE_DIR=vendor/$MANUFACTURER/$DEVICE/proprietary
PROPRIETARY_DEVICE_DIR=../../../vendor/$MANUFACTURER/$DEVICE/proprietary

mkdir -p $PROPRIETARY_DEVICE_DIR

for NAME in audio hw wifi etc egl etc/firmware
do
    mkdir -p $PROPRIETARY_DEVICE_DIR/$NAME
done

BLOBS_LIST=../../../vendor/$MANUFACTURER/$DEVICE/$DEVICE-vendor-blobs.mk

(cat << EOF) | sed s/__DEVICE__/$DEVICE/g | sed s/__MANUFACTURER__/$MANUFACTURER/g > ../../../vendor/$MANUFACTURER/$DEVICE/$DEVICE-vendor-blobs.mk
# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Prebuilt libraries that are needed to build open-source libraries
PRODUCT_COPY_FILES :=

# All the blobs
PRODUCT_COPY_FILES += \\
EOF

# copy_file
# pull file from the device and adds the file to the list of blobs
#
# $1 = src/dst name
# $2 = directory path on device
# $3 = directory name in $PROPRIETARY_DEVICE_DIR
copy_file()
{
    echo Pulling \"$1\"
    if [[ -z "${ANDROIDFS_DIR}" ]]; then
        NAME=$1
        adb pull /$2/$1 $PROPRIETARY_DEVICE_DIR/$3/$2
    else
        NAME=`basename ${ANDROIDFS_DIR}/$2/$1`
        rm -f $PROPRIETARY_DEVICE_DIR/$3/$NAME
        cp ${ANDROIDFS_DIR}/$2/$NAME $PROPRIETARY_DEVICE_DIR/$3/$NAME
    fi

    if [[ -f $PROPRIETARY_DEVICE_DIR/$3/$NAME ]]; then
        echo   $BASE_PROPRIETARY_DEVICE_DIR/$3/$NAME:$2/$NAME \\ >> $BLOBS_LIST
    else
        echo Failed to pull $1. Giving up.
        exit -1
    fi
}

# copy_files
# pulls a list of files from the device and adds the files to the list of blobs
#
# $1 = list of files
# $2 = directory path on device
# $3 = directory name in $PROPRIETARY_DEVICE_DIR
copy_files()
{
    for NAME in $1
    do
        copy_file "$NAME" "$2" "$3"
    done
}

# copy_local_files
# puts files in this directory on the list of blobs to install
#
# $1 = list of files
# $2 = directory path on device
# $3 = local directory path
copy_local_files()
{
    for NAME in $1
    do
        echo Adding \"$NAME\"
        echo device/$MANUFACTURER/$DEVICE/$3/$NAME:$2/$NAME \\ >> $BLOBS_LIST
    done
}

COMMON_LIBS="
	libcnefeatureconfig.so
	libdashplayer.so
	libqomx_core.so
	libmmjpeg_interface.so
	libaudioroute.so
	libmmcamera_interface.so
	libmotext_inf.so
	libmdmcutback.so
	"

copy_files "$COMMON_LIBS" "system/lib" ""

COMMON_VENDOR_LIBS="
	libacdbloader.so
	libacdbmapper.so
	libacdbrtac.so
	libadiertac.so
	libadreno_utils.so
	libadsprpc.so
	libalarmservice_jni.so
	libaudcal.so
	libaudioalsa.so
	libbt-vendor.so
	libC2D2.so
	libc2d2_z180.so
	libc2d30-a3xx.so
	libc2d30-a4xx.so
	libc2d30.so
	libCB.so
	libchromatix_imx135_common.so
	libchromatix_imx135_default_video.so
	libchromatix_imx135_hfr_120.so
	libchromatix_imx135_preview.so
	libchromatix_imx135_snapshot.so
	libchromatix_ov2720_common.so
	libchromatix_ov2720_default_video.so
	libchromatix_ov2720_hfr.so
	libchromatix_ov2720_liveshot.so
	libchromatix_ov2720_preview.so
	libchromatix_ov2720_zsl.so
	libchromatix_ov8825_common.so
	libchromatix_ov8825_default_video.so
	libchromatix_ov8825_hfr_120fps.so
	libchromatix_ov8825_hfr_60fps.so
	libchromatix_ov8825_hfr_90fps.so
	libchromatix_ov8825_liveshot_hd.so
	libchromatix_ov8825_liveshot.so
	libchromatix_ov8825_preview_hd.so
	libchromatix_ov8825_preview.so
	libchromatix_ov8825_snapshot_hd.so
	libchromatix_ov8825_snapshot.so
	libchromatix_ov8825_video_hd.so
	libchromatix_ov8825_zsl.so
	libchromatix_ov9724_common.so
	libchromatix_ov9724_default_video.so
	libchromatix_ov9724_liveshot.so
	libchromatix_ov9724_preview.so
	libchromatix_s5k3l1yx_common.so
	libchromatix_s5k3l1yx_default_video.so
	libchromatix_s5k3l1yx_hfr_120fps.so
	libchromatix_s5k3l1yx_hfr_60fps.so
	libchromatix_s5k3l1yx_hfr_90fps.so
	libchromatix_s5k3l1yx_liveshot.so
	libchromatix_s5k3l1yx_preview.so
	libchromatix_s5k3l1yx_snapshot.so
	libchromatix_s5k3l1yx_video_hd.so
	libchromatix_s5k3l1yx_zsl.so
	libchromatix_SKUAA_ST_gc0339_common.so
	libchromatix_SKUAA_ST_gc0339_default_video.so
	libchromatix_SKUAA_ST_gc0339_preview.so
	libchromatix_skuab_shinetech_gc0339_common.so
	libchromatix_skuab_shinetech_gc0339_default_video.so
	libchromatix_skuab_shinetech_gc0339_liveshot.so
	libchromatix_skuab_shinetech_gc0339_preview.so
	libchromatix_skuab_shinetech_gc0339_snapshot.so
	libchromatix_skuab_shinetech_gc0339_zsl.so
	libchromatix_SKUAB_ST_s5k4e1_common.so
	libchromatix_SKUAB_ST_s5k4e1_default_video.so
	libchromatix_SKUAB_ST_s5k4e1_hfr_120fps.so
	libchromatix_SKUAB_ST_s5k4e1_hfr_60fps.so
	libchromatix_SKUAB_ST_s5k4e1_hfr_90fps.so
	libchromatix_SKUAB_ST_s5k4e1_liveshot.so
	libchromatix_SKUAB_ST_s5k4e1_preview.so
	libchromatix_SKUAB_ST_s5k4e1_snapshot.so
	libchromatix_SKUAB_ST_s5k4e1_video_hd.so
	libchromatix_SKUAB_ST_s5k4e1_zsl.so
	libchromatix_skuf_ov12830_p12v01c_common.so
	libchromatix_skuf_ov12830_p12v01c_default_video.so
	libchromatix_skuf_ov12830_p12v01c_hfr_60fps.so
	libchromatix_skuf_ov12830_p12v01c_hfr_90fps.so
	libchromatix_skuf_ov12830_p12v01c_preview.so
	libchromatix_skuf_ov12830_p12v01c_snapshot.so
	libchromatix_skuf_ov12830_p12v01c_video_hd.so
	libchromatix_skuf_ov12830_p12v01c_zsl.so
	libchromatix_skuf_ov5648_p5v23c_common.so
	libchromatix_skuf_ov5648_p5v23c_default_video.so
	libchromatix_skuf_ov5648_p5v23c_preview.so
	libchromatix_skuf_ov5648_p5v23c_snapshot.so
	libCommandSvc.so
	libconfigdb.so
	libDiagService.so
	libdiag.so
	libDivxDrm.so
	lib-dplmedia.so
	libdrmdiag.so
	libdrmfs.so
	libdrmtime.so
	libdsi_netctrl.so
	libdsnetutils.so
	libdsucsd.so
	libdsutils.so
	libExtendedExtractor.so
	libfastcvopt.so
	libFileMux.so
	libgeofenceServices.so
	libgeofence.so
	libgsl.so
	libHevcSwDecoder.so
	libI420colorconvert.so
	libidl.so
	lib-imsdpl.so
	lib-imsqimf.so
	lib-imsrcs.so
	lib-imsSDP.so
	lib-imsvt.so
	lib-imsxml.so
	libizat_core.so
	libjpegdhw.so
	libjpegehw.so
	liblistensoundmodel.so
	libllvm-a3xx.so
	libllvm-qcom.so
	liblocationservice.so
	libloc_ext.so
	liblowi_client.so
	libmm-abl-oem.so
	libmm-abl.so
	libmmcamera2_c2d_module.so
	libmmcamera2_cpp_module.so
	libmmcamera2_iface_modules.so
	libmmcamera2_imglib_modules.so
	libmmcamera2_isp_modules.so
	libmmcamera2_pproc_modules.so
	libmmcamera2_sensor_modules.so
	libmmcamera2_stats_algorithm.so
	libmmcamera2_stats_modules.so
	libmmcamera2_vpe_module.so
	libmmcamera2_wnr_module.so
	libmmcamera_faceproc.so
	libmmcamera_hdr_gb_lib.so
	libmmcamera_hdr_lib.so
	libmmcamera_hi256.so
	libmmcamera_imglib.so
	libmmcamera_imx135.so
	libmmcamera_mt9m114.so
	libmmcamera_ov2720.so
	libmmcamera_ov8825.so
	libmmcamera_ov9724.so
	libmmcamera_s5k3l1yx.so
	libmmcamera_SKUAA_ST_gc0339.so
	libmmcamera_skuab_shinetech_gc0339.so
	libmmcamera_SKUAB_ST_s5k4e1.so
	libmmcamera_skuf_ov12830_p12v01c.so
	libmmcamera_skuf_ov5648_p5v23c.so
	libmmcamera_sp1628.so
	libmmcamera_sunny_p12v01m_eeprom.so
	libmmcamera_sunny_p5v23c_eeprom.so
	libmmcamera_tintless_algo.so
	libmmcamera_truly_cm7700_eeprom.so
	libmmcamera_tuning.so
	libmmcamera_wavelet_lib.so
	libmm-color-convertor.so
	libmmhttpstack.so
	libmmiipstreammmihttp.so
	libmmipl.so
	libmmipstreamaal.so
	libmmipstreamnetwork.so
	libmmipstreamsourcehttp.so
	libmmipstreamutils.so
	libmmjpeg.so
	libmmosal.so
	libmmparser.so
	libmmqjpeg_codec.so
	libmmrtpdecoder.so
	libmmrtpencoder.so
	libnetmgr.so
	liboemcamera.so
	liboemcrypto.so
	libOmxAacDec.so
	libOmxAmrwbplusDec.so
	libOmxEvrcDec.so
	libOmxQcelp13Dec.so
	libOmxWmaDec.so
	libOpenCL.so
	libOpenVG.so
	libP11Notify.so
	libprdrmdecrypt.so
	libqcci_legacy.so
	libqc-opt.so
	libqdi.so
	libqdp.so
	libqmi_cci.so
	libqmi_client_qmux.so
	libqmi_common_so.so
	libqmi_csi.so
	libqmi_csvt_srvc.so
	libqmi_encdec.so
	libqmiservices.so
	libqmi.so
	libqomx_jpegenc.so
	libQSEEComAPI.so
	libquipc_os_api.so
	libquipc_ulp_adapter.so
	libril-qc-qmi-1.so
	libril-qcril-hook-oem.so
	librpmb.so
	lib-rtpcommon.so
	lib-rtpcore.so
	lib-rtpdaemoninterface.so
	lib-rtpsl.so
	libsc-a2xx.so
	libsc-a3xx.so
	libSecureTouchPerfApp.so
	libsensor1.so
	libSHIMDivxDrm.so
	libssd.so
	libSSEPKCS11.so
	libStDrvInt.so
	libsubsystem_control.so
	libSubSystemShutdown.so
	libswdec_2dto3d.so
	libthermalclient.so
	libtime_genoff.so
	libTimeService.so
	libtzdrmgenprov.so
	libtzplayready.so
	libulp2.so
	libv8.so
	libwfdcommonutils.so
	libwvdrm_L1.so
	libwvm.so
	libWVStreamControlAPI_L1.so
	libxml.so
	libxt_native.so
	libxtwifi_ulp_adaptor.so
	libxtwifi_zpp_adaptor.so
	"

copy_files "$COMMON_VENDOR_LIBS" "system/vendor/lib" ""

COMMON_BINS="
	adsprpcd
	ap_gain_mmul.bin
	batt_health
	bridgemgrd
	fm_qsoc_patches
	fmconfig
	hci_qcomm_init
	mm-qcamera-daemon
	netmgrd
	port-bridge
	qmi_motext_hook
	qmiproxy
	qmuxd
	radish
	rmt_storage
	"

copy_files "$COMMON_BINS" "system/bin" ""

COMMON_HW="
	audio.r_submix.default.so
	audio_policy.msm8226.so
	audio.primary.msm8226.so
	camera.msm8226.so
	gps.default.so
	sensors.msm8226.so
	"
copy_files "$COMMON_HW" "system/lib/hw" "hw"

COMMON_WIFI="
	"
copy_files "$COMMON_WIFI" "system/lib/modules" "wifi"

COMMON_ETC="
	General_cal.acdb
	Global_cal.acdb
	Handset_cal.acdb
	Hdmi_cal.acdb
	Headset_cal.acdb
	audio_policy.conf
	gps.conf
	media_codecs.xml
	media_profiles.xml
	mixer_paths.xml
	mixer_paths_boost.xml
	mixer_paths_p1.xml
	"
copy_files "$COMMON_ETC" "system/etc" "etc"

COMMON_AUDIO="
	"
#copy_files "$COMMON_AUDIO" "system/lib" "audio"

COMMON_EGL="
	egl.cfg
	libGLES_android.so
	"
copy_files "$COMMON_EGL" "system/lib/egl" "egl"

COMMON_VENDOR_EGL="
	eglsubAndroid.so
	libEGL_adreno.so
	libGLESv1_CM_adreno.so
	libGLESv2_adreno.so
	libq3dtools_adreno.so
	"
copy_files "$COMMON_VENDOR_EGL" "system/vendor/lib/egl" "egl"

COMMON_FIRMWARE="
	a225p5_pm4.fw
	a225_pfp.fw
	a225_pm4.fw
	a300_pfp.fw
	a300_pm4.fw
	a330_pfp.fw
	a330_pm4.fw
	leia_pfp_470.fw
	leia_pm4_470.fw
	synaptics-s2316-13091704-175833-falcon.tdat
	"
copy_files "$COMMON_FIRMWARE" "system/etc/firmware" "etc/firmware"

echo $BASE_PROPRIETARY_DEVICE_DIR/libcnefeatureconfig.so:obj/lib/libcnefeatureconfig.so \\ >> $BLOBS_LIST

