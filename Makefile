TARGET = iphone:clang:18.6:15.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = YouTube

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = uYouUnofficial

uYouUnofficial_FILES = Tweak.xm \
	$(wildcard Classes/**/*.m) \
	$(wildcard Classes/**/*.mm) \
	$(wildcard Classes/**/*.xm) \
	Vendor/AFNetworking/*.m \
	Vendor/FMDB/*.m \
	Vendor/JGProgressHUD/*.m \
	Vendor/Lottie/*.m \
	Vendor/Others/*.m \
	Vendor/SDWebImage/*.m \
	Vendor/GCDWebServer/GCDWebServer/*.m

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
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/GCDWebServer/GCDWebServer
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/JGProgressHUD
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/Lottie
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/Others
uYouUnofficial_CFLAGS += -I$(THEOS_PROJECT_DIR)/Vendor/SDWebImage

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
