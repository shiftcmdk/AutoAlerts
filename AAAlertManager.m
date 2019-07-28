#import "AAAlertManager.h"
#import "AADataStore.h"
#import "AACoreDataStack.h"

@interface AAAlertManager ()

@property (nonatomic, retain) id<AADataStore> store;
-(id)initWithDataStore:(id<AADataStore>)store;

@end

@implementation AAAlertManager

-(id)initWithDataStore:(id<AADataStore>)store {
    if (self = [super init]) {
        self.store = store;
    }

    return self;
}

+(instancetype)sharedManager
{
    static AAAlertManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id store = [[[AACoreDataStack alloc] init] autorelease];

        sharedManager = [[AAAlertManager alloc] initWithDataStore:store];
    });
    return sharedManager;
}

-(void)saveAlert:(AAAlertInfo *)alert error:(NSError **)error {
    [self.store saveAlert:alert error:error];
}

-(void)updateAlert:(AAAlertInfo *)alert error:(NSError **)error {
    [self.store updateAlert:alert error:error];
}

-(void)deleteAlert:(AAAlertInfo *)alert error:(NSError **)error {
    [self.store deleteAlert:alert error:error];
}

-(void)deleteAlertWithID:(NSString *)identifier error:(NSError **)error {
    [self.store deleteAlertWithID:identifier error:error];
}

-(void)deleteAlertsWithBundleID:(NSString *)bundleID error:(NSError **)error {
    [self.store deleteAlertsWithBundleID:bundleID error:error];
}

-(AAAlertInfo *)alertWithID:(NSString *)alertID {
    return [self.store alertWithID:alertID];
}

-(NSArray<AAAlertInfo *> *)allAlerts {
    return [self.store allAlerts];
}

-(void)initialize {
    if ([self.store respondsToSelector:@selector(initialize)]) {
        [self.store initialize];
    }
}

-(void)dealloc {
    self.store = nil;

    [super dealloc];
}

@end