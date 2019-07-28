#import "AAConfigurationViewController.h"
#import "AAAppIconCell.h"
#import "CoreData/CoreData.h"

@interface AAConfigurationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray<NSString *> *actions;
@property (nonatomic, retain) NSIndexPath *selectedActionIndexPath;
@property (nonatomic, retain) NSIndexPath *selectedLimitationIndexPath;
@property (nonatomic, retain) UIView *fakeNavBar;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIButton *doneButton;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, retain) NSArray<NSString *> *textFieldValues;
@property (nonatomic, retain) NSDictionary<NSString *, NSNumber *> *customAppActions;
@property (nonatomic, assign) BOOL isSpringBoard;
@property (nonatomic, assign) BOOL secure;

@end

@interface UIImage ()

+(id)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2 scale:(double)arg3;

@end

@interface SpringBoard: UIApplication

-(id)_accessibilityFrontMostApplication;

@end

@implementation AAConfigurationViewController

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

-(id)initWithActions:(NSArray<NSString *> *)actions title:(NSString *)title message:(NSString *)message textFieldValues:(NSArray<NSString *> *)textFieldValues customAppActions:(NSDictionary<NSString *, NSNumber *> *)customAppActions secure:(BOOL)secure {
    if (self = [super init]) {
        self.actions = actions;
        self.selectedActionIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        self.selectedLimitationIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
        self.titleString = title;
        self.message = message;
        self.textFieldValues = textFieldValues;
        self.customAppActions = customAppActions;

        self.fakeNavBar = [[[UIView alloc] init] autorelease];
        self.fakeNavBar.backgroundColor = [UIColor whiteColor];

        [self.view addSubview:self.fakeNavBar];

        self.titleLabel = [[[UILabel alloc] init] autorelease];
        self.titleLabel.text = @"Alert settings";
        self.titleLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold];

        [self.fakeNavBar addSubview:self.titleLabel];

        self.doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.doneButton.titleLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold];
        [self.doneButton addTarget:self action:@selector(doneTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];

        [self.fakeNavBar addSubview:self.doneButton];

        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightRegular];
        [self.cancelButton addTarget:self action:@selector(cancelTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];

        [self.fakeNavBar addSubview:self.cancelButton];

        self.isSpringBoard = [[NSBundle mainBundle].bundleIdentifier isEqual:@"com.apple.springboard"];
        self.secure = secure;
    }
    
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped] autorelease];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.preservesSuperviewLayoutMargins = YES;

    [self.view addSubview:self.tableView];

    [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ActionCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LimitationCell"];
    [self.tableView registerClass:[AAAppIconCell class] forCellReuseIdentifier:@"AppIconCell"];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat statusBarHeight;

    if (self.isSpringBoard) {
        statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    } else {
        if (@available(iOS 11.0, *)) {
        statusBarHeight = self.view.safeAreaInsets.top;
        } else {
            statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        }
    }

    CGFloat fakeNavBarHeight = statusBarHeight == 0.0 ? 32.0 : statusBarHeight + 44.0;

    self.fakeNavBar.frame = CGRectMake(
        0.0,
        0.0,
        self.view.bounds.size.width,
        fakeNavBarHeight
    );

    self.tableView.contentInset = UIEdgeInsetsMake(
        self.fakeNavBar.frame.size.height - (self.isSpringBoard ? 0.0 : statusBarHeight),
        self.tableView.contentInset.left,
        self.tableView.contentInset.bottom,
        self.tableView.contentInset.right
    );

    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(
        self.fakeNavBar.frame.size.height - (self.isSpringBoard ? 0.0 : statusBarHeight),
        self.tableView.contentInset.left,
        self.tableView.contentInset.bottom,
        self.tableView.contentInset.right
    );

    CGSize titleLabelSize = self.titleLabel.intrinsicContentSize;

    self.titleLabel.frame = CGRectMake(
        self.fakeNavBar.bounds.size.width / 2.0 - titleLabelSize.width / 2.0,
        statusBarHeight,
        titleLabelSize.width,
        fakeNavBarHeight - statusBarHeight
    );

    CGSize doneButtonSize = self.doneButton.intrinsicContentSize;

    self.doneButton.frame = CGRectMake(
        self.fakeNavBar.bounds.size.width - doneButtonSize.width - self.view.layoutMargins.left,
        statusBarHeight + (fakeNavBarHeight - statusBarHeight) / 2.0 - doneButtonSize.height / 2.0,
        doneButtonSize.width,
        doneButtonSize.height
    );

    CGSize cancelButtonSize = self.cancelButton.intrinsicContentSize;

    self.cancelButton.frame = CGRectMake(
        self.view.layoutMargins.left,
        statusBarHeight + (fakeNavBarHeight - statusBarHeight) / 2.0 - cancelButtonSize.height / 2.0,
        cancelButtonSize.width,
        cancelButtonSize.height
    );
}

-(void)postSaveNotification {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSString stringWithFormat:@"%@", self.titleString] forKey:@"title"];
    [dict setObject:[NSString stringWithFormat:@"%@", self.message] forKey:@"message"];
    [dict setObject:self.actions forKey:@"actions"];
    [dict setObject:self.textFieldValues forKey:@"textfieldvalues"];
    [dict setObject:[NSNumber numberWithInt:self.textFieldValues.count] forKey:@"textfieldcount"];
    [dict setObject:[NSNumber numberWithInt:self.selectedActionIndexPath.row] forKey:@"selectedaction"];

    NSMutableDictionary *appActions = [NSMutableDictionary dictionaryWithDictionary:self.customAppActions];

    if (self.isSpringBoard) {
        SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];

        id currentApp = [sb _accessibilityFrontMostApplication];

        if (currentApp && self.selectedLimitationIndexPath.row == 0) {
            NSString *currentAppBundleID = [currentApp valueForKey:@"bundleIdentifier"];

            appActions[currentAppBundleID] = [NSNumber numberWithInt:self.selectedActionIndexPath.row];
        } else {
            [appActions removeAllObjects];
        }
    }

    [dict setObject:appActions forKey:@"customappactions"];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];

    NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;

    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDistributedCenter(), 
        (CFStringRef)[NSString stringWithFormat:@"com.shiftcmdk.autoalerts.save.%@ %@", bundleID, jsonString], 
        NULL, 
        NULL, 
        YES
    );
}

-(void)doneTapped:(UIBarButtonItem *)sender {
    NSString *warningTitle = nil;
    NSString *warningMessage = nil;

    if (self.secure) {
        warningTitle = @"Warning";
        warningMessage = @"At least one text field is marked as secure. All input will be stored in plain text. Do you really want to save this alert?";
    }

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:warningTitle message:warningMessage preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self postSaveNotification];

        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];

    UIAlertAction *saveAndRunAction = [UIAlertAction actionWithTitle:@"Save and Run" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self postSaveNotification];

        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            if (self.delegate) {
                [self.delegate saveAndRunAction:self.selectedActionIndexPath.row];
            }
        }];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        
    }];

    [alert addAction:saveAction];
    [alert addAction:saveAndRunAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

-(void)cancelTapped:(UIBarButtonItem *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSpringBoard) {
        SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];

        if ([sb _accessibilityFrontMostApplication]) {
            return 3;
        }
    }

    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.actions.count + 2;
    }
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        AAAppIconCell *cell = (AAAppIconCell *)[tableView dequeueReusableCellWithIdentifier:@"AppIconCell" forIndexPath:indexPath];

        cell.appIconImageView.image = [UIImage _applicationIconImageForBundleIdentifier:[NSBundle mainBundle].bundleIdentifier format:2 scale:[UIScreen mainScreen].scale];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell" forIndexPath:indexPath];

        if (indexPath.row == 0) {
            cell.textLabel.text = @"No Action";

            cell.textLabel.font = [UIFont systemFontOfSize:cell.textLabel.font.pointSize weight:UIFontWeightMedium];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Dismiss";

            cell.textLabel.font = [UIFont systemFontOfSize:cell.textLabel.font.pointSize weight:UIFontWeightMedium];
        } else {
            cell.textLabel.text = [self.actions objectAtIndex:indexPath.row - 2];

            cell.textLabel.font = [UIFont systemFontOfSize:cell.textLabel.font.pointSize];
        }

        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor whiteColor];

        cell.accessoryType = indexPath == self.selectedActionIndexPath ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LimitationCell" forIndexPath:indexPath];

        SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];

        id app = [sb _accessibilityFrontMostApplication];

        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"Only in %@", [app valueForKey:@"displayName"]];
        } else {
            cell.textLabel.text = @"In Every App";
        }

        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor whiteColor];

        cell.accessoryType = indexPath == self.selectedLimitationIndexPath ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

        return cell;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Automated action";
    } else if (section == 2) {
        return @"App specific settings";
    }
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return @"Select the action that should be invoked automatically when this alert is shown.";
    } else if (section == 2) {
        return @"Alerts that are presented from SpringBoard can either be automated in a specific app or in every app.";
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 1) {
        self.selectedActionIndexPath = indexPath;

        for (int i = 0; i < [tableView numberOfRowsInSection:indexPath.section]; i++) {
            NSIndexPath *theIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];

            UITableViewCell *cell = [tableView cellForRowAtIndexPath:theIndexPath];

            if (cell) {
                cell.accessoryType = theIndexPath == self.selectedActionIndexPath ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            }
        }
    }

    if (indexPath.section == 2) {
        self.selectedLimitationIndexPath = indexPath;

        for (int i = 0; i < [tableView numberOfRowsInSection:indexPath.section]; i++) {
            NSIndexPath *theIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];

            UITableViewCell *cell = [tableView cellForRowAtIndexPath:theIndexPath];

            if (cell) {
                cell.accessoryType = theIndexPath == self.selectedLimitationIndexPath ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            }
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 16.0;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 8.0;
    }
    return UITableViewAutomaticDimension;
}

-(void)dealloc {
    [self.tableView removeFromSuperview];

    self.tableView = nil;

    self.actions = nil;

    self.selectedActionIndexPath = nil;
    self.selectedLimitationIndexPath = nil;

    [self.titleLabel removeFromSuperview];

    self.titleLabel = nil;

    [self.doneButton removeFromSuperview];

    self.doneButton = nil;

    [self.cancelButton removeFromSuperview];

    self.cancelButton = nil;

    [self.fakeNavBar removeFromSuperview];

    self.fakeNavBar = nil;

    self.titleString = nil;
    self.message = nil;
    self.textFieldValues = nil;

    self.customAppActions = nil;

    [super dealloc];
}

@end