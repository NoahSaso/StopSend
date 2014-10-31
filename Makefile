ARCHS = arm64 armv7
TARGET = iphone:clang:latest

include theos/makefiles/common.mk

TWEAK_NAME = StopSend
StopSend_FILES = Tweak.xm
StopSend_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSMS"
