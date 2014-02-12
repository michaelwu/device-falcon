$(call inherit-product, device/qcom/msm8226/msm8226.mk)

PRODUCT_COPY_FILES := \
  device/motorola/falcon/rootdir/fstab.qcom:root/fstab.qcom \
  device/motorola/falcon/rootdir/init.mmi.boot.sh:root/init.mmi.boot.sh \
  device/motorola/falcon/rootdir/init.mmi.radio.sh:root/init.mmi.radio.sh \
  device/motorola/falcon/rootdir/init.mmi.rc:root/init.mmi.rc \
  device/motorola/falcon/rootdir/init.mmi.touch.sh:root/init.mmi.touch.sh \
  device/motorola/falcon/rootdir/init.mmi.usb.rc:root/init.mmi.usb.rc \
  device/motorola/falcon/rootdir/init.mmi.usb.sh:root/init.mmi.usb.sh \
  device/motorola/falcon/rootdir/init.qcom.class_main.sh:root/init.qcom.class_main.sh \
  device/motorola/falcon/rootdir/init.qcom.rc:root/init.qcom.rc \
  device/motorola/falcon/rootdir/init.rc:root/init.rc \
  device/motorola/falcon/rootdir/init.target.rc:root/init.target.rc \
  device/motorola/falcon/rootdir/ueventd.qcom.rc:root/ueventd.qcom.rc \
  device/motorola/falcon/rootdir/ueventd.rc:root/ueventd.rc \
  device/motorola/falcon/touchscreen.idc:system/usr/idc/synaptics_dsc_i2c.idc \


$(call inherit-product-if-exists, vendor/motorola/falcon/falcon-vendor-blobs.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic.mk)

PRODUCT_NAME := full_falcon
PRODUCT_DEVICE := falcon
PRODUCT_BRAND := motorola
PRODUCT_MANUFACTURER := qcom
PRODUCT_MODEL := falcon
