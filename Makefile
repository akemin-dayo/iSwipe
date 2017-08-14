TARGET =: clang
ARCHS = armv7 armv7s arm64
DEBUG = 0
GO_EASY_ON_ME = 1

SOURCE = src

THEOS_PACKAGE_DIR_NAME = debs
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
TWEAK_NAME = iSwipe
iSwipe_FILES = $(SOURCE)/Tweak.xm $(SOURCE)/ISAlgoAngleDiffGreedy.m $(SOURCE)/ISController.m $(SOURCE)/ISScribbleView.m $(SOURCE)/CGPointWrapper.m $(SOURCE)/ISData.m $(SOURCE)/ISKey.m $(SOURCE)/ISModel.m $(SOURCE)/ISSuggestionsView.m $(SOURCE)/ISWord.m
iSwipe_FRAMEWORKS = Foundation UIKit CoreGraphics

include $(THEOS)/makefiles/tweak.mk

after-install::
	install.exec "killall backboardd"
#	install.exec "killall SpringBoard"
