include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AutoAlertsPreferences
AutoAlertsPreferences_FILES = AARootListController.xm ../Model/AAAlertInfo.m ../AAAlertManager.m ../AACoreDataStack.m AAApp.m AAAppOverviewController.xm AAAlertOverviewController.xm
AutoAlertsPreferences_INSTALL_PATH = /Library/PreferenceBundles
AutoAlertsPreferences_FRAMEWORKS = UIKit
AutoAlertsPreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/AutoAlertsPreferences.plist$(ECHO_END)
