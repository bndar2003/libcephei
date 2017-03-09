export TARGET = iphone:clang:latest:5.0
export ADDITIONAL_CFLAGS = -Wextra -Wno-unused-parameter

INSTALL_TARGET_PROCESSES = Preferences

ifeq ($(RESPRING),1)
INSTALL_TARGET_PROCESSES += SpringBoard
endif

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = Cephei
Cephei_FILES = $(wildcard *.m) $(wildcard *.x) $(wildcard CompactConstraint/*.m)
Cephei_PUBLIC_HEADERS = HBOutputForShellCommand.h HBPreferences.h HBRespringController.h LSStatusBarItem.h UIColor+HBAdditions.h $(wildcard CompactConstraint/*.h) statusbar/UIStatusBarCustomItem.h statusbar/UIStatusBarCustomItemView.h
Cephei_FRAMEWORKS = CoreGraphics UIKit
Cephei_WEAK_PRIVATE_FRAMEWORKS = FrontBoardServices SpringBoardServices
Cephei_EXTRA_FRAMEWORKS = CydiaSubstrate
Cephei_LIBRARIES = rocketbootstrap
Cephei_CFLAGS = -include Global.h -fobjc-arc

SUBPROJECTS = prefs statusbar defaults containersupport

include $(THEOS_MAKE_PATH)/framework.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-Cephei-stage::
	@# create directories
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/usr/{include,lib} $(THEOS_STAGING_DIR)/DEBIAN $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries$(ECHO_END)

	@# libhbangcommon.dylib -> Cephei.framework
	$(ECHO_NOTHING)ln -s /Library/Frameworks/Cephei.framework/Cephei $(THEOS_STAGING_DIR)/usr/lib/libhbangcommon.dylib$(ECHO_END)

	@# libcephei.dylib -> Cephei.framework
	$(ECHO_NOTHING)ln -s /Library/Frameworks/Cephei.framework/Cephei $(THEOS_STAGING_DIR)/usr/lib/libcephei.dylib$(ECHO_END)

	@# postinst -> DEBIAN/post{inst,rm}
	$(ECHO_NOTHING)cp postinst postrm $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)

	@# TODO: this is kind of a bad idea. maybe it should be in its own daemon?
	@# CepheiPreferencesSupport.dylib -> Cephei.framework
	$(ECHO_NOTHING)ln -s /Library/Frameworks/Cephei.framework/Cephei $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/CepheiPreferencesSupport.dylib$(ECHO_END)

	@# copy CepheiPreferencesSupport.plist
	$(ECHO_NOTHING)cp CepheiPreferencesSupport.plist $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries$(ECHO_END)

after-install::
ifneq ($(RESPRING)$(PACKAGE_BUILDNAME),1)
	install.exec "uiopen 'prefs:root=Cephei%20Demo'"
endif
