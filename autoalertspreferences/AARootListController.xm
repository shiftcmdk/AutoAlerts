#include "AARootListController.h"
#import "../AAAlertManager.h"
#import "AAApp.h"
#import "AAAppOverviewController.h"

@interface LSApplicationProxy: NSObject

@property (nonatomic,readonly) NSString * bundleIdentifier;
-(id)localizedName;
@property (nonatomic,readonly) NSString * primaryIconName;
@property (setter=_setInfoDictionary:,nonatomic,copy) id _infoDictionary;

@end

@interface LSApplicationWorkspace : NSObject

+(id)defaultWorkspace;
-(id)allInstalledApplications;
-(id)allApplications;

@end

@interface UIImage ()

+(id)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2 scale:(double)arg3;

@end

@interface AARootListController () <UITableViewDelegate, UITableViewDataSource, AADeleteDelegate>

@property (nonatomic, retain) NSMutableArray<AAApp *> *apps;
@property (nonatomic, retain) NSMutableDictionary<NSString *, NSString *> *appsDict;
@property (nonatomic, assign) BOOL shouldDelete;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;

@end

@implementation AARootListController

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

-(id)init {
    if (self = [super init]) {
        self.navigationItem.title = @"AutoAlerts";

		[[AAAlertManager sharedManager] initialize];
    }

    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.view addSubview:self.tableView];

	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AppCell"];
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"EnabledCell"];

	self.navigationItem.title = @"AutoAlerts";

	self.apps = [NSMutableArray array];

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray<LSApplicationProxy *> *apps = [[%c(LSApplicationWorkspace) defaultWorkspace] allApplications];

        NSMutableDictionary<NSString *, NSString *> *theAppsDict = [NSMutableDictionary dictionary];

        for (LSApplicationProxy *app in apps) {
            theAppsDict[app.bundleIdentifier] = [app localizedName];
        }

		NSArray<AAAlertInfo *> *allAlerts = [[AAAlertManager sharedManager] allAlerts];

		NSMutableDictionary<NSString *, NSMutableArray *> *alertsDict = [NSMutableDictionary dictionary];

		for (AAAlertInfo *info in allAlerts) {
			NSMutableArray *arr = alertsDict[info.bundleID];

			if (arr) {
				[arr addObject:info];
			} else {
				alertsDict[info.bundleID] = [NSMutableArray arrayWithObject:info];
			}
		}

		NSMutableArray<AAApp *> *appEntries = [NSMutableArray array];

		for (NSString *key in alertsDict) {
			NSString *name;

			if (theAppsDict[key] && theAppsDict[key].length > 0) {
				name = theAppsDict[key];
			} else if ([key isEqual:@"com.apple.springboard"]) {
				name = @"SpringBoard";
			} else {
				name = key;
			}

			NSSortDescriptor *titleSort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
			NSSortDescriptor *messageSort = [NSSortDescriptor sortDescriptorWithKey:@"message" ascending:YES];
			NSMutableArray *sortedInfos = [NSMutableArray arrayWithArray:[alertsDict[key] sortedArrayUsingDescriptors:@[titleSort, messageSort]]];

			AAApp *app = [[[AAApp alloc] initWithBundleID:key name:name infos:sortedInfos] autorelease];

			[appEntries addObject:app];
		}

		NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSMutableArray *tempApps = [NSMutableArray arrayWithArray:[appEntries sortedArrayUsingDescriptors:@[sort]]];

		NSMutableArray *indexPaths = [NSMutableArray array];

		for (int i = 0; i < tempApps.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
			self.apps = tempApps;

			self.appsDict = theAppsDict;

			[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        });
    });

	self.shouldDelete = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.shouldDelete && self.selectedIndexPath) {
		[self.apps removeObjectAtIndex:self.selectedIndexPath.row];

        [self.tableView deleteRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

		self.shouldDelete = NO;
		self.selectedIndexPath = nil;
    }
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.tableView.frame = self.view.bounds;
}

-(void)didDelete {
    self.shouldDelete = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;
	}
    return self.apps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EnabledCell" forIndexPath:indexPath];

		cell.textLabel.text = @"Enabled";

		UISwitch *switchView = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
		[switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

		NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithSuiteName:@"com.shiftcmdk.autoalertspreferences"] autorelease];

		switchView.on = [defaults objectForKey:@"enabled"] == nil || [defaults boolForKey:@"enabled"];

		cell.accessoryView = switchView;

		return cell;
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppCell" forIndexPath:indexPath];

		AAApp *app = [self.apps objectAtIndex:indexPath.row];

		UIImage *icon = [UIImage _applicationIconImageForBundleIdentifier:app.bundleID format:0 scale:[UIScreen mainScreen].scale];

		cell.imageView.image = icon;
		cell.textLabel.text = app.name;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.selectedIndexPath = indexPath;

    AAAppOverviewController *ctrl = [[[AAAppOverviewController alloc] init] autorelease];
    ctrl.app = [self.apps objectAtIndex:indexPath.row];
	ctrl.appsDict = self.appsDict;
	ctrl.deleteDelegate = self;

    [self pushController:ctrl animate:YES];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"General";
	}

    if (section == 1) {
		return @"Apps";
	}

	return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0) {
		return @"Apps may need to be restarted after enabling or disabling this option.";
	}

    if (section == 1) {
        return @"Apps with automated alerts will appear here.";
    }
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *deleteAlert = [UIAlertController alertControllerWithTitle:@"Delete alerts" message:[NSString stringWithFormat:@"Do you really want to delete all automated alerts for %@?", self.apps[indexPath.row].name] preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            CFNotificationCenterPostNotification(
                CFNotificationCenterGetDistributedCenter(), 
                (CFStringRef)[NSString stringWithFormat:@"com.shiftcmdk.autoalerts.deletewithbundleid.%@", self.apps[indexPath.row].bundleID], 
                NULL, 
                NULL, 
                YES
            );

            [self.apps removeObjectAtIndex:indexPath.row];

            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

        [deleteAlert addAction:deleteAction];
        [deleteAlert addAction:cancelAction];
		
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		
		deleteAlert.popoverPresentationController.sourceView = cell;
		deleteAlert.popoverPresentationController.sourceRect = cell.bounds;

        [self presentViewController:deleteAlert animated:YES completion:nil];
    }
}

-(void)switchChanged:(UISwitch *)sender {
	NSUserDefaults *defaults = [[[NSUserDefaults alloc] initWithSuiteName:@"com.shiftcmdk.autoalertspreferences"] autorelease];

	[defaults setBool:sender.isOn forKey:@"enabled"];

	CFNotificationCenterPostNotification(
		CFNotificationCenterGetDistributedCenter(), 
		(CFStringRef)@"com.shiftcmdk.autoalerts.toggle", 
		NULL, 
		NULL, 
		YES
	);
}

-(void)dealloc {
    [self.tableView removeFromSuperview];

    self.tableView = nil;

    self.apps = nil;

	self.appsDict = nil;

	self.selectedIndexPath = nil;

    [super dealloc];
}

@end
