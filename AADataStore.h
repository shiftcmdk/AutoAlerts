#import "Model/AAAlertInfo.h"

@protocol AADataStore <NSObject>

@required
-(void)saveAlert:(AAAlertInfo *)alert error:(NSError **)error;
-(void)updateAlert:(AAAlertInfo *)alert error:(NSError **)error;
-(void)deleteAlert:(AAAlertInfo *)alert error:(NSError **)error;
-(void)deleteAlertWithID:(NSString *)identifier error:(NSError **)error;
-(void)deleteAlertsWithBundleID:(NSString *)bundleID error:(NSError **)error;
-(AAAlertInfo *)alertWithID:(NSString *)alertID;
-(NSArray<AAAlertInfo *> *)allAlerts;

@optional
-(void)initialize;

@end