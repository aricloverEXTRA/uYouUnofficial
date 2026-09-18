TARGET = iphone:clang:18.6:15.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = YouTube

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = uYouUnofficial

UYOU_ROOT = $(CURDIR)

# Recursively include every Objective-C / Objective-C++ source file
# anywhere under Classes/.
uYouUnofficial_FILES = Tweak.xm \
	$(shell find Classes -type f \( \
		-name '*.m' -o \
		-name '*.mm' -o \
		-name '*.xm' \
	\) -print) \
	$(wildcard Vendor/AFNetworking/*.m) \
	$(wildcard Vendor/FMDB/*.m) \
	$(wildcard Vendor/JGProgressHUD/*.m) \
	$(wildcard Vendor/Lottie/*.m) \
	$(wildcard Vendor/Others/*.m) \
	$(wildcard Vendor/SDWebImage/*.m)

uYouUnofficial_CFLAGS = -fobjc-arc \
	-Wno-deprecated-declarations \
	-Wno-unused-variable \
	-Wno-unused-function \
	-DTWEAK_VERSION=\"3.0.6-unofficial\"

# Classes include paths
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Classes
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Classes/Core
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Classes/Core/Downloads
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Classes/Core/Models
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Classes/Core/Player
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Classes/Core/Settings
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Classes/Core/Utils
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Classes/Core/Welcome
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Classes/Core/MediaKit
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Classes/UI
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Classes/UI/Cells
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Classes/UI/ViewControllers

# Vendor include paths
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Vendor
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Vendor/AFNetworking
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Vendor/FMDB
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Vendor/GCDWebServer
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Vendor/JGProgressHUD
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Vendor/Lottie
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Vendor/Others
uYouUnofficial_CFLAGS += -I$(UYOU_ROOT)/Vendor/SDWebImage

uYouUnofficial_FRAMEWORKS = UIKit Foundation AVFoundation AVKit Photos CoreMotion VideoToolbox Security MediaPlayer
uYouUnofficial_LIBRARIES = bz2 c++ iconv z sqlite3

include $(THEOS_MAKE_PATH)/tweak.mk

.PHONY: package-all
package-all:
	$(MAKE) package ARCHS="arm64"
	$(MAKE) package ARCHS="arm64e"

.PHONY: clean-all
clean-all:
	$(MAKE) clean ARCHS="arm64"
	$(MAKE) clean ARCHS="arm64e"
