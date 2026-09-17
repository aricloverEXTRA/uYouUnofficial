TARGET = iphone:clang:18.6:15.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = YouTube

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = uYouUnofficial

# Core source files
# Use find instead of wildcard ** so nested .m/.mm/.xm files are included.
uYouUnofficial_FILES = Tweak.xm \
	$(shell find Classes -type f \( -name '*.m' -o -name '*.mm' -o -name '*.xm' \)) \
	$(filter-out \
		Vendor/LNPopup/LNPopupControllerExample/% \
		Vendor/Lottie/Example% \
		Vendor/Lottie/Example-Swift/% \
		Vendor/Lottie/lottie-ios/% \
		Vendor/Lottie/MacOS_Viewer/% \
		Vendor/SDWebImage/Examples/% \
		Vendor/SDWebImage/Tests/% \
		Vendor/SDWebImage/UIKit+AFNetworking/% \
		Vendor/AFNetworking/Example/% \
		Vendor/AFNetworking/Tests/% \
		Vendor/GCDWebServer/Tests/% \
		Vendor/FMDB/Tests/% \
		Vendor/SDWebImage/NSBezierPath+SDRoundedCorners.m \
		Vendor/SDWebImage/NSButton+WebCache.m \
		Vendor/SDWebImage/NSImage+Compatibility.m \
		Vendor/SDWebImage/SDAnimatedImageRep.m \
		Vendor/SDWebImage/SDWebImageMapKit/% \
		Vendor/SDWebImage/MKAnnotationView+WebCache.m \
		Vendor/SDWebImage/FLAnimatedImage/% \
		,$(shell find Vendor -type f \( -name '*.m' -o -name '*.mm' \)))

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

uYouUnofficial_LIBRARIES = bz2 c++ iconv z sqlite3

# Bundle is installed via Layout/ to match:
# /Library/Application Support/uYouBundle.bundle
#
# Theos EMBED_BUNDLES would place it under:
# /Library/MobileSubstrate/DynamicLibraries
#
# so the bundle remains installed through Layout/.

include $(THEOS_MAKE_PATH)/tweak.mk

# Multi-arch build targets
.PHONY: package-all
package-all:
	$(MAKE) package ARCHS="arm64"
	$(MAKE) package ARCHS="arm64e"
	$(MAKE) package ARCHS="armv7"

.PHONY: clean-all
clean-all:
	$(MAKE) clean ARCHS="arm64"
	$(MAKE) clean ARCHS="arm64e"
	$(MAKE) clean ARCHS="armv7"