#import "AAAlertOverviewController.h"

@interface AAAlertOverviewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSArray<NSString *> *visibleSections;
@property (nonatomic, retain) NSMutableArray<NSString *> *sortedBundleIDs;

@end

@interface UIImage ()

+(id)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2 scale:(double)arg3;

@end

@implementation AAAlertOverviewController

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

-(void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Alert Details";

    UIBarButtonItem *trashItem = [[[UIBarButtonItem alloc] 
        initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
        target:self 
        action:@selector(deleteAlert:)
    ] autorelease];

    self.navigationItem.rightBarButtonItem = trashItem;

    self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.view addSubview:self.tableView];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TitleCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MessageCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ActionCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SelectedActionCell"];

    NSMutableArray *sections = [NSMutableArray array];

    if (self.alertInfo.actions.count > 0) {
        [sections addObject:@"Actions"];
    }

    if (self.alertInfo.customAppActions.count == 0) {
        [sections addObject:@"SelectedAction"];
    }

    if (self.alertInfo.textFieldValues.count > 0) {
        [sections addObject:@"TextFields"];
    }

    if (self.alertInfo.customAppActions.count > 0) {
        [sections addObject:@"CustomAppActions"];

        self.sortedBundleIDs = [NSMutableArray arrayWithArray:[[self.alertInfo.customAppActions allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            NSString *firstName;

            if (self.appsDict[obj1]) {
                firstName = self.appsDict[obj1];
            } else {
                firstName = obj1;
            }

            NSString *secondName;

            if (self.appsDict[obj2]) {
                secondName = self.appsDict[obj2];
            } else {
                secondName = obj2;
            }

            return [firstName compare:secondName options:NSCaseInsensitiveSearch];
        }]];
    }

    self.visibleSections = sections;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.tableView.frame = self.view.bounds;
}

-(void)postDeleteNotificationAndPopViewController {
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDistributedCenter(), 
        (CFStringRef)[NSString stringWithFormat:@"com.shiftcmdk.autoalerts.delete.%@", self.alertInfo.identifier], 
        NULL, 
        NULL, 
        YES
    );

    if (self.deleteDelegate) {
        [self.deleteDelegate didDelete];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

-(void)deleteAlert:(UIBarButtonItem *)sender {
    UIAlertController *deleteAlert = [UIAlertController alertControllerWithTitle:@"Delete alert" message:@"Do you really want to delete this automated alert?" preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self postDeleteNotificationAndPopViewController];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [deleteAlert addAction:deleteAction];
    [deleteAlert addAction:cancelAction];

    deleteAlert.popoverPresentationController.barButtonItem = sender;

    [self presentViewController:deleteAlert animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2 + self.visibleSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section > 1) {
        NSString *identifier = self.visibleSections[section - 2];

        if ([identifier isEqual:@"Actions"]) {
            return self.alertInfo.actions.count;
        }

        if ([identifier isEqual:@"SelectedAction"]) {
            return 1;
        }

        if ([identifier isEqual:@"TextFields"]) {
            return self.alertInfo.textFieldValues.count;
        }

        if ([identifier isEqual:@"CustomAppActions"]) {
            return self.alertInfo.customAppActions.count;
        }

        return 0;
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TitleCell" forIndexPath:indexPath];

        cell.textLabel.text = self.alertInfo.title;
        cell.textLabel.numberOfLines = 0;
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];

        cell.textLabel.text = self.alertInfo.message;
        cell.textLabel.numberOfLines = 0;
    } else {
        NSString *identifier = self.visibleSections[indexPath.section - 2];

        if ([identifier isEqual:@"Actions"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell" forIndexPath:indexPath];

            cell.textLabel.text = self.alertInfo.actions[indexPath.row];
        } else if ([identifier isEqual:@"SelectedAction"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SelectedActionCell" forIndexPath:indexPath];

            int selectedAction = self.alertInfo.selectedAction;

            NSString *actionString;

            if (selectedAction == 0) {
                actionString = @"No Action";
            } else if (selectedAction == 1) {
                actionString = @"Dismiss";
            } else {
                actionString = self.alertInfo.actions[selectedAction - 2];
            }

            cell.textLabel.text = actionString;
        } else if ([identifier isEqual:@"TextFields"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];

            if (!cell) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TextFieldCell"] autorelease];
            }

            cell.textLabel.text = [NSString stringWithFormat:@"Text Field %i", (int)indexPath.row + 1];
            cell.detailTextLabel.text = self.alertInfo.textFieldValues[indexPath.row];
        } else if ([identifier isEqual:@"CustomAppActions"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"AppCell"];

            if (!cell) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"AppCell"] autorelease];
            }

            NSString *bundleID = self.sortedBundleIDs[indexPath.row];

            UIImage *icon = [UIImage _applicationIconImageForBundleIdentifier:bundleID format:0 scale:[UIScreen mainScreen].scale];

            cell.imageView.image = icon;
            cell.textLabel.text = self.appsDict[bundleID] ? self.appsDict[bundleID] : bundleID;

            int selectedAction = [self.alertInfo.customAppActions[bundleID] intValue];

            NSString *actionString;

            if (selectedAction == 0) {
                actionString = @"No Action";
            } else if (selectedAction == 1) {
                actionString = @"Dismiss";
            } else {
                actionString = self.alertInfo.actions[selectedAction - 2];
            }

            cell.detailTextLabel.text = actionString;
        } else {
            cell = [[[UITableViewCell alloc] init] autorelease];
        }
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Title";
        case 1:
            return @"Message";
        default: {
            NSString *identifier = self.visibleSections[section - 2];

            if ([identifier isEqual:@"Actions"]) {
                return @"Actions";
            }

            if ([identifier isEqual:@"SelectedAction"]) {
                return @"Selected action";
            }

            if ([identifier isEqual:@"TextFields"]) {
                return @"Text fields";
            }

            if ([identifier isEqual:@"CustomAppActions"]) {
                return @"App specific settings";
            }

            return nil;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section > 1 && [self.visibleSections[indexPath.section - 2] isEqual:@"CustomAppActions"];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *bundleID = self.sortedBundleIDs[indexPath.row];

        [self.sortedBundleIDs removeObjectAtIndex:indexPath.row];

        [self.alertInfo.customAppActions removeObjectForKey:bundleID];

        if (self.alertInfo.customAppActions.count > 0) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:[NSString stringWithFormat:@"%@", self.alertInfo.title] forKey:@"title"];
            [dict setObject:[NSString stringWithFormat:@"%@", self.alertInfo.message] forKey:@"message"];
            [dict setObject:self.alertInfo.actions forKey:@"actions"];
            [dict setObject:self.alertInfo.textFieldValues forKey:@"textfieldvalues"];
            [dict setObject:[NSNumber numberWithInt:self.alertInfo.textFieldValues.count] forKey:@"textfieldcount"];
            [dict setObject:[NSNumber numberWithInt:self.alertInfo.selectedAction] forKey:@"selectedaction"];
            [dict setObject:self.alertInfo.customAppActions forKey:@"customappactions"];

            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            NSString *jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];

            CFNotificationCenterPostNotification(
                CFNotificationCenterGetDistributedCenter(), 
                (CFStringRef)[NSString stringWithFormat:@"com.shiftcmdk.autoalerts.save.%@ %@", self.alertInfo.bundleID, jsonString], 
                NULL, 
                NULL, 
                YES
            );
        } else {
            [self postDeleteNotificationAndPopViewController];
        }

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)dealloc {
    [self.tableView removeFromSuperview];

    self.tableView = nil;

    self.alertInfo = nil;

    self.visibleSections = nil;

    self.appsDict = nil;

    self.sortedBundleIDs = nil;

    [super dealloc];
}

@end