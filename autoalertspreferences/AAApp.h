#import "../Model/AAAlertInfo.h"

@interface AAApp: NSObject

-(id)initWithBundleID:(NSString *)bundleID name:(NSString *)name infos:(NSMutableArray<AAAlertInfo *> *)infos;

@property (nonatomic, copy) NSString *bundleID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSMutableArray<AAAlertInfo *> *infos;

@end