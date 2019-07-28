#import <Preferences/PSViewController.h>
#import "../Model/AAAlertInfo.h"
#import "AADeleteDelegate.h"

@interface AAAlertOverviewController : PSViewController

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) AAAlertInfo *alertInfo;
@property (nonatomic, retain) NSMutableDictionary<NSString *, NSString *> *appsDict;
@property (nonatomic, assign) id<AADeleteDelegate> deleteDelegate;

@end