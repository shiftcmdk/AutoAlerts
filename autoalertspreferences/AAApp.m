#import "AAApp.h"

@implementation AAApp

-(id)initWithBundleID:(NSString *)bundleID name:(NSString *)name infos:(NSMutableArray<AAAlertInfo *> *)infos {
    if (self = [super init]) {
        self.bundleID = bundleID;
        self.name = name;
        self.infos = infos;
    }

    return self;
}

-(void)dealloc {
    self.bundleID = nil;
    self.name = nil;

    self.infos = nil;

    [super dealloc];
}

@end