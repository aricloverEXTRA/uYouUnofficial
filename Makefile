TARGET = iphone:clang:18.6:15.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = YouTube

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = uYouUnofficial

uYouUnofficial_FILES = Tweak.xm \
	$(wildcard Classes/**/*.m) \
	$(wildcard Classes/**/*.mm) \
	$(wildcard Classes/**/*.xm) \
	$(shell find Vendor -type f \( -name '*.m' -o -name '*.mm' \) \
		! -path 'Vendor/LNPopup/LNPopupControllerExample/*' \
		! -path 'Vendor/Lottie/Example*' \
		! -path 'Vendor/Lottie/Example-Swift/*' \
		! -path 'Vendor/Lottie/lottie-ios/*' \
		! -path 'Vendor/Lottie/MacOS_Viewer/*' \
		! -path 'Vendor/SDWebImage/Examples/*' \
		! -path 'Vendor/SDWebImage/Tests/*' \
		! -path 'Vendor/AFNetworking/Example/*' \
		! -path 'Vendor/AFNetworking/Tests/*' \
		! -path 'Vendor/GCDWebServer/Tests/*' \
		! -path 'Vendor/FMDB/Tests/*' \
		! -path 'Vendor/SDWebImage/SDWebImageMapKit/*' \
		! -path 'Vendor/SDWebImage/FLAnimatedImage/*' \
		-print)

uYouUnofficial_CFLAGS = -fobjc-arc \
	-Wno-deprecated-declarations \
	-Wno-unused-variable \
	-Wno-unused-function \
	-DTWEAK_VERSION=\"3.0.6-unofficial\"

uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes/Core
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes/Core/Downloads
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes/Core/Gestures
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes/Core/Models
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes/Core/Player
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes/Core/Settings
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes/Core/Utils
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes/Core/Welcome
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes/Core/MediaKit
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes/UI
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes/UI/Cells
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes/UI/ViewControllers
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Classes/UI/Views
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/AFNetworking
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/FMDB
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/GCDWebServer
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/JGProgressHUD
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/LNPopup
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/LNPopup/LNPopupController
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/LNPopup/LNPopupController/LNPopupController
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/LNPopup/LNPopupController/LNPopupController/Private
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/Lottie
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/Others
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/SDWebImage

uYouUnofficial_FRAMEWORKS = \
	UIKit \
	Foundation \
	AVFoundation \
	AVKit \
	Photos \
	CoreMotion \
	VideoToolbox \
	Security \
	MediaPlayer

uYouUnofficial_LIBRARIES = bz2 iconv z sqlite3

include $(THEOS_MAKE_PATH)/tweak.mk

.PHONY: package-all
package-all:
	$(MAKE) package ARCHS="arm64 arm64e"

.PHONY: clean-all
clean-all:
	$(MAKE) clean ARCHS="arm64 arm64e"
