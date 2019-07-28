include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoAlerts
AutoAlerts_FILES = Tweak.xm AAConfigurationViewController.xm AAAppIconCell.m Model/AAAlertInfo.m AACoreDataStack.m AAAlertManager.m

AutoAlerts_FRAMEWORKS = CoreData

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += autoalertspreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
