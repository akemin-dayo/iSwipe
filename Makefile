DEBUG = 0
ARCHS = armv7 arm64 armv7s
SOURCE = src
TARGET =: clang

ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
TWEAK_NAME = iSwipe
iSwipe_FILES = $(SOURCE)/Tweak.xm $(SOURCE)/ISAlgoAngleDiffGreedy.m $(SOURCE)/ISController.m $(SOURCE)/ISScribbleView.m $(SOURCE)/CGPointWrapper.m $(SOURCE)/ISData.m $(SOURCE)/ISKey.m $(SOURCE)/ISModel.m $(SOURCE)/ISSuggestionsView.m $(SOURCE)/ISWord.m
iSwipe_FRAMEWORKS = Foundation UIKit CoreGraphics

include $(THEOS)/makefiles/tweak.mk

