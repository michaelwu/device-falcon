include device/qcom/msm8226/BoardConfig.mk

TARGET_NO_BOOTLOADER := true

BOARD_BOOTIMAGE_PARTITION_SIZE := 10485760
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1023410176
BOARD_USERDATAIMAGE_PARTITION_SIZE := 5930614784

BOARD_KERNEL_CMDLINE += vmalloc=400M utags.blkdev=/dev/block/platform/msm_sdcc.1/by-name/utags

# hack to prevent llvm from building
BOARD_USE_QCOM_LLVM_CLANG_RS := true
