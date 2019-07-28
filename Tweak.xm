#import "AutoAlerts.h"
#import "AAConfigurationViewController.h"
#import "AAAlertManager.h"

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

BOOL autoAlertsEnabled = YES;

%hook UIAlertController

%property (nonatomic, retain) AAAlertInfo *alertInfo;
%property (nonatomic, retain) UIViewController *dummyViewController;
%property (nonatomic, assign) BOOL automated;

-(void)viewDidLoad {
    %orig;

    if (self.preferredStyle != UIAlertControllerStyleAlert || !autoAlertsEnabled) {
        return;
    }

    NSLog(@"[AutoAlerts] is automated: %i alert info: %@ custom app actions: %@", self.automated, self.alertInfo, self.alertInfo ? self.alertInfo.customAppActions : nil);

    self.view.hidden = self.automated;
    self._dimmingView.hidden = self.automated;

    [self setTextFieldsCanBecomeFirstResponder:!self.automated];

    UILongPressGestureRecognizer *longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)] autorelease];

    _UIAlertControllerView *theView = (_UIAlertControllerView *)self.view;

    [[theView valueForKey:@"_contentViewTopItemsView"] addGestureRecognizer:longPress];
}

%new
-(void)saveAndRunAction:(int)action {
    [self aa_runSelectedAction:action];
}

%new
-(void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.dummyViewController = [[[UIViewController alloc] init] autorelease];
        self.dummyViewController.view.backgroundColor = [UIColor clearColor];
        self.dummyViewController.view.userInteractionEnabled = NO;

        [self.window addSubview:self.dummyViewController.view];

        NSMutableArray *actionTitles = [NSMutableArray array];

        for (UIAlertAction *action in self.actions) {
            [actionTitles addObject:action.title];
        }

        NSMutableArray *textFieldValues = [NSMutableArray array];

        BOOL secure = NO;

        for (UITextField *textField in self.textFields) {
            if (textField.text) {
                [textFieldValues addObject:textField.text];
            }

            if (textField.secureTextEntry) {
                secure = YES;
            }
        }

        NSDictionary *customAppActions = self.alertInfo ? self.alertInfo.customAppActions : [NSDictionary dictionary];

        AAConfigurationViewController *configCtrl = [[[AAConfigurationViewController alloc] initWithActions:actionTitles title:self.title message:self.message textFieldValues:textFieldValues customAppActions:customAppActions secure:secure] autorelease];
        configCtrl.view.backgroundColor = [UIColor whiteColor];
        configCtrl.delegate = self;
        
        [self.dummyViewController presentViewController:configCtrl animated:YES completion:nil];
    }
}

-(void)viewWillAppear:(BOOL)arg1 {
    %orig;

    if (self.preferredStyle != UIAlertControllerStyleAlert || !autoAlertsEnabled) {
        return;
    }

    self.view.hidden = self.automated;
    self._dimmingView.hidden = self.automated;
}

%new
-(void)autoPopulateTextFields {
    if (self.automated) {
        for (int i = 0; i < self.textFields.count; i++) {
            [self.textFields[i] setText:@""];
            [self.textFields[i] insertText:self.alertInfo.textFieldValues[i]];
        }
    }
}

%new
-(void)aa_runSelectedAction:(int)selectedAction {
    if (selectedAction > 0) {
        if ([self isKindOfClass:[%c(_SBAlertController) class]]) {
            if (selectedAction == 1) {
                [UIView performWithoutAnimation:^{
                    SBAlertItem *item = [self valueForKey:@"alertItem"];
                    
                    [item dismiss];
                }];
            } else {
                [self autoPopulateTextFields];

                [self _dismissWithAction:[self._actions objectAtIndex:selectedAction - 2] dismissCompletion:nil];
            }
        } else {
            if (selectedAction == 1) {
                [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
            } else {
                [self autoPopulateTextFields];

                [self _dismissWithAction:[self._actions objectAtIndex:selectedAction - 2] dismissCompletion:nil];
            }
        }
    }
}

-(void)viewDidAppear:(BOOL)arg1 {
    %orig;

    if (self.preferredStyle != UIAlertControllerStyleAlert || !autoAlertsEnabled) {
        return;
    }

    self.view.hidden = self.automated;
    self._dimmingView.hidden = self.automated;

    if (self.automated) {
        int selectedAction = self.alertInfo.selectedAction;

        if ([self.alertInfo.bundleID isEqual:@"com.apple.springboard"] && self.alertInfo.customAppActions.count > 0) {
            SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];

            id currentApp = [sb _accessibilityFrontMostApplication];

            if (currentApp) {
                NSString *currentAppBundleID = [currentApp valueForKey:@"bundleIdentifier"];

                id customAction = self.alertInfo.customAppActions[currentAppBundleID];

                if (customAction) {
                    selectedAction = [customAction intValue];
                }
            }
        }

        [self aa_runSelectedAction:selectedAction];
    }
}

-(void)dealloc {
    self.alertInfo = nil;

    if (self.dummyViewController) {
        [self.dummyViewController.view removeFromSuperview];

        self.dummyViewController = nil;
    }

    %orig;
}

%end

%hook UIViewController

-(void)presentViewController:(id)arg1 animated:(BOOL)arg2 completion:(id)arg3 {
    if (![arg1 isKindOfClass:[UIAlertController class]]) {
        %orig;
    } else {
        UIAlertController *alert = (UIAlertController *)arg1;
        if (alert.preferredStyle == UIAlertControllerStyleAlert && autoAlertsEnabled) {
            NSMutableArray *actionTitles = [NSMutableArray array];

            for (UIAlertAction *action in alert.actions) {
                [actionTitles addObject:action.title];
            }

            NSMutableArray *textFieldValues = [NSMutableArray array];

            for (UITextField *textField in alert.textFields) {
                if (textField.text) {
                    [textFieldValues addObject:textField.text];
                }
            }

            NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;

            AAAlertInfo *info = [[[AAAlertInfo alloc] initWithActions:actionTitles title:alert.title message:alert.message textFieldValues:textFieldValues selectedAction:0 customAppActions:[NSMutableDictionary dictionary] bundleID:bundleID] autorelease];

            alert.alertInfo = [[AAAlertManager sharedManager] alertWithID:info.identifier];

            if (alert.alertInfo) {
                if ([alert.alertInfo.bundleID isEqual:@"com.apple.springboard"] && alert.alertInfo.customAppActions.count > 0) {
                    SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];

                    id currentApp = [sb _accessibilityFrontMostApplication];

                    if (currentApp) {
                        NSString *currentAppBundleID = [currentApp valueForKey:@"bundleIdentifier"];

                        alert.automated = alert.alertInfo.customAppActions[currentAppBundleID] != nil && [alert.alertInfo.customAppActions[currentAppBundleID] intValue] > 0;
                    } else {
                        alert.automated = NO;
                    }
                } else {
                    alert.automated = alert.alertInfo.selectedAction > 0;
                }
            } else {
                alert.automated = NO;
            }
            
            %orig(arg1, alert.automated ? NO : arg2, arg3);
        } else {
            %orig;
        }
    }
}

%end

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSString *prefix = @"com.shiftcmdk.autoalerts.save.";
    NSString *deletePrefix = @"com.shiftcmdk.autoalerts.delete.";
    NSString *deleteWithBundleIDPrefix = @"com.shiftcmdk.autoalerts.deletewithbundleid.";

    if ([(NSString *)name hasPrefix:prefix]) {
        NSString *stripped = [(NSString *)name substringFromIndex:[prefix length]];
        NSString *bundleID;

        NSScanner *scanner = [NSScanner scannerWithString:stripped];
        [scanner scanUpToString:@" " intoString:&bundleID];

        NSString *prefixWithBundleID = [NSString stringWithFormat:@"%@%@ ", prefix, bundleID];

        NSString *content = [(NSString *)name substringFromIndex:prefixWithBundleID.length];

        NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];

        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&error];

        NSLog(@"[AutoAlerts] content: %@", jsonDict);

        if (!error) {
            NSArray *actions = [jsonDict objectForKey:@"actions"];
            NSString *title = [jsonDict objectForKey:@"title"];
            NSString *message = [jsonDict objectForKey:@"message"];
            int selectedAction = [[jsonDict objectForKey:@"selectedaction"] intValue];
            NSArray *textFieldValues = [jsonDict objectForKey:@"textfieldvalues"];
            NSMutableDictionary *customAppActions = [jsonDict objectForKey:@"customappactions"];

            AAAlertInfo *info = [[[AAAlertInfo alloc] initWithActions:actions title:title message:message textFieldValues:textFieldValues selectedAction:selectedAction customAppActions:customAppActions bundleID:bundleID] autorelease];

            [[AAAlertManager sharedManager] saveAlert:info error:nil];

            NSLog(@"[AutoAlerts] saved alert: %@", [[AAAlertManager sharedManager] alertWithID:info.identifier]);
        }
    } else if ([(NSString *)name hasPrefix:deletePrefix]) {
        NSString *alertID = [(NSString *)name substringFromIndex:[deletePrefix length]];

        NSLog(@"[AutoAlerts] delete: %@", alertID);

        [[AAAlertManager sharedManager] deleteAlertWithID:alertID error:nil];
    } else if ([(NSString *)name hasPrefix:deleteWithBundleIDPrefix]) {
        NSString *bundleID = [(NSString *)name substringFromIndex:[deleteWithBundleIDPrefix length]];

        NSLog(@"[AutoAlerts] delete bundle id: %@", bundleID);

        [[AAAlertManager sharedManager] deleteAlertsWithBundleID:bundleID error:nil];
    } else if ([(NSString *)name isEqual:@"com.shiftcmdk.autoalerts.toggle"]) {
        NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithSuiteName:@"com.shiftcmdk.autoalertspreferences"] autorelease];

        autoAlertsEnabled = [defaults objectForKey:@"enabled"] == nil || [defaults boolForKey:@"enabled"];

        NSLog(@"[AutoAlerts] toggle: %i", autoAlertsEnabled);
    }
}

static void *sbObserver = NULL;

%ctor {
    BOOL isSpringBoard = [[NSBundle mainBundle].bundleIdentifier isEqual:@"com.apple.springboard"];

    if (isSpringBoard) {
        NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithSuiteName:@"com.shiftcmdk.autoalertspreferences"] autorelease];

        autoAlertsEnabled = [defaults objectForKey:@"enabled"] == nil || [defaults boolForKey:@"enabled"];
    } else {
        NSDictionary *prefsDict = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.shiftcmdk.autoalertspreferences.plist"];

        autoAlertsEnabled = !prefsDict || [prefsDict objectForKey:@"enabled"] == nil || [[prefsDict objectForKey:@"enabled"] boolValue];
    }

    [[AAAlertManager sharedManager] initialize];

    if (isSpringBoard) {
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDistributedCenter(),
            &sbObserver,
            notificationCallback,
            NULL,
            NULL,
            CFNotificationSuspensionBehaviorDeliverImmediately
        );
    }
}

%dtor {
    BOOL isSpringBoard = [[NSBundle mainBundle].bundleIdentifier isEqual:@"com.apple.springboard"];

    if (isSpringBoard) {
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDistributedCenter(),
            &sbObserver,
            NULL,
            NULL
        );
    }
}

