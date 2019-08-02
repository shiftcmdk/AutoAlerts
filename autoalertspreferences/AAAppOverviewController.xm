#import "AAAppOverviewController.h"
#import "AAAlertOverviewController.h"
#import "AADeleteDelegate.h"

@interface AAAppOverviewController () <UITableViewDelegate, UITableViewDataSource, AADeleteDelegate>

@property (nonatomic, assign) BOOL shouldDelete;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;

@end

@implementation AAAppOverviewController

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

-(void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.app.name;

    self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.view addSubview:self.tableView];

    self.shouldDelete = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.shouldDelete && self.selectedIndexPath) {
        if (self.app.infos.count == 1) {
            [self.app.infos removeObjectAtIndex:self.selectedIndexPath.row];

            if (self.deleteDelegate) {
                [self.deleteDelegate didDelete];
            }

            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.app.infos removeObjectAtIndex:self.selectedIndexPath.row];

            [self.tableView deleteRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

            self.shouldDelete = NO;
            self.selectedIndexPath = nil;
        }
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.app.infos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlertOverviewCell"];

    AAAlertInfo *info = [self.app.infos objectAtIndex:indexPath.row];

    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AlertOverviewCell"] autorelease];
    }

    cell.textLabel.text = info.title;
    cell.detailTextLabel.text = info.message;

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Automated alerts";
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;

    AAAlertOverviewController *ctrl = [[[AAAlertOverviewController alloc] init] autorelease];
    ctrl.alertInfo = [self.app.infos objectAtIndex:indexPath.row];
    ctrl.appsDict = self.appsDict;
    ctrl.deleteDelegate = self;

    [self.navigationController pushViewController:ctrl animated:YES];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *deleteAlert = [UIAlertController alertControllerWithTitle:@"Delete alert" message:@"Do you really want to delete this automated alert?" preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            CFNotificationCenterPostNotification(
                CFNotificationCenterGetDistributedCenter(), 
                (CFStringRef)[NSString stringWithFormat:@"com.shiftcmdk.autoalerts.delete.%@", self.app.infos[indexPath.row].identifier], 
                NULL, 
                NULL, 
                YES
            );

            [self.app.infos removeObjectAtIndex:indexPath.row];

            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

            if (self.deleteDelegate && self.app.infos.count == 0) {
                [self.deleteDelegate didDelete];

                [self.navigationController popViewControllerAnimated:YES];
            }
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

-(void)dealloc {
    [self.tableView removeFromSuperview];

    self.tableView = nil;

    self.app = nil;

    self.appsDict = nil;

    self.selectedIndexPath = nil;

    [super dealloc];
}

@end