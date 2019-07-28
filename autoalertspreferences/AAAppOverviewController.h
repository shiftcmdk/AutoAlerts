#import <Preferences/PSViewController.h>
#import "AAApp.h"
#import "AADeleteDelegate.h"

@interface AAAppOverviewController : PSViewController

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) AAApp *app;
@property (nonatomic, retain) NSMutableDictionary<NSString *, NSString *> *appsDict;
@property (nonatomic, assign) id<AADeleteDelegate> deleteDelegate;

@end