#import "Model/AAAlertInfo.h"

@interface AAAlertManager: NSObject

+(instancetype)sharedManager;
-(void)saveAlert:(AAAlertInfo *)alert error:(NSError **)error;
-(void)updateAlert:(AAAlertInfo *)alert error:(NSError **)error;
-(void)deleteAlert:(AAAlertInfo *)alert error:(NSError **)error;
-(void)deleteAlertWithID:(NSString *)identifier error:(NSError **)error;
-(void)deleteAlertsWithBundleID:(NSString *)bundleID error:(NSError **)error;
-(AAAlertInfo *)alertWithID:(NSString *)alertID;
-(NSArray<AAAlertInfo *> *)allAlerts;
-(void)initialize;

@end