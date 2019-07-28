#import "AACoreDataStack.h"
#import <CoreData/CoreData.h>

@interface AACoreDataStack ()

@property (nonatomic, retain) NSPersistentContainer *container;
@property (nonatomic, assign) BOOL initialized;

-(NSManagedObject *)createAlertWithInfo:(AAAlertInfo *)alertInfo;
-(void)setValuesForAlert:(NSManagedObject *)alert info:(AAAlertInfo *)alertInfo;
-(void)save;

@end

@implementation AACoreDataStack

-(id)init {
    if (self = [super init]) {
        NSURL *url = [NSURL fileURLWithPath:@"/Library/PreferenceBundles/AutoAlertsPreferences.bundle/AutoAlerts.momd"];
		
		NSManagedObjectModel *model = [[[NSManagedObjectModel alloc] initWithContentsOfURL:url] autorelease];
		
        NSString *dir = @"/var/mobile/Library/Preferences/AutoAlerts/";

        BOOL isSpringBoard = [[NSBundle mainBundle].bundleIdentifier isEqual:@"com.apple.springboard"];

        if (![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:nil] && isSpringBoard) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:nil];
        }
		
		NSURL *storeURL = [NSURL fileURLWithPath:[dir stringByAppendingPathComponent:@"AutoAlerts.sqlite"]];
		
		NSPersistentStoreDescription *prop = [[[NSPersistentStoreDescription alloc] initWithURL:storeURL] autorelease];

        if (!isSpringBoard) {
            [prop setOption:@YES forKey:NSReadOnlyPersistentStoreOption];
        }

        if (model) {
            self.container = [[[NSPersistentContainer alloc] initWithName:@"AutoAlerts" managedObjectModel:model] autorelease];
		    self.container.persistentStoreDescriptions = @[prop];
        } else {
            self.container = nil;
        }

        self.initialized = NO;
    }

    return self;
}

-(void)setValuesForAlert:(NSManagedObject *)alert info:(AAAlertInfo *)alertInfo {
    [alert setValue:alertInfo.identifier forKeyPath:@"id"];
    [alert setValue:alertInfo.message forKeyPath:@"message"];
    [alert setValue:alertInfo.title forKeyPath:@"title"];
    [alert setValue:[NSKeyedArchiver archivedDataWithRootObject:alertInfo.actions] forKeyPath:@"actions"];
    [alert setValue:[NSKeyedArchiver archivedDataWithRootObject:alertInfo.textFieldValues] forKeyPath:@"textFields"];
    [alert setValue:[NSNumber numberWithInt:alertInfo.selectedAction] forKeyPath:@"selectedAction"];
    [alert setValue:alertInfo.bundleID forKeyPath:@"bundleID"];
    [alert setValue:[NSKeyedArchiver archivedDataWithRootObject:alertInfo.customAppActions] forKeyPath:@"customAppActions"];
}

-(NSManagedObject *)createAlertWithInfo:(AAAlertInfo *)alertInfo {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Alert" inManagedObjectContext:self.container.viewContext];
    
    NSManagedObject *alert = [[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.container.viewContext] autorelease];

    [self setValuesForAlert:alert info:alertInfo];
    
    return alert;
}

-(void)saveAlert:(AAAlertInfo *)alert error:(NSError **)error {
    if (self.initialized) {
        [self createAlertWithInfo:alert];

        [self save];
    }
}

-(void)updateAlert:(AAAlertInfo *)alert error:(NSError **)error {
    if (self.initialized) {
        NSFetchRequest *alertRequest = [[[NSFetchRequest alloc] initWithEntityName:@"Alert"] autorelease];
        [alertRequest setFetchLimit:1];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(id = %@)", alert.identifier];
        [alertRequest setPredicate:predicate];
            
        NSManagedObject *alertObj = [self.container.viewContext executeFetchRequest:alertRequest error:nil].firstObject;

        if (alertObj) {
            [self setValuesForAlert:alertObj info:alert];

            [self save];
        }
    }
}

-(void)deleteAlertsWithBundleID:(NSString *)bundleID error:(NSError **)error {
    if (self.initialized) {
        NSFetchRequest *alertRequest = [[[NSFetchRequest alloc] initWithEntityName:@"Alert"] autorelease];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(bundleID = %@)", bundleID];
        [alertRequest setPredicate:predicate];
            
        NSArray *alerts = [self.container.viewContext executeFetchRequest:alertRequest error:nil];

        for (NSManagedObject *alertObj in alerts) {
            [self.container.viewContext deleteObject:alertObj];
        }

        [self save];
    }
}

-(void)deleteAlertWithID:(NSString *)identifier error:(NSError **)error {
    if (self.initialized) {
        NSFetchRequest *alertRequest = [[[NSFetchRequest alloc] initWithEntityName:@"Alert"] autorelease];
        [alertRequest setFetchLimit:1];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(id = %@)", identifier];
        [alertRequest setPredicate:predicate];
            
        NSManagedObject *alertObj = [self.container.viewContext executeFetchRequest:alertRequest error:nil].firstObject;

        if (alertObj) {
            [self.container.viewContext deleteObject:alertObj];

            [self save];
        }
    }
}

-(void)deleteAlert:(AAAlertInfo *)alert error:(NSError **)error {
    [self deleteAlertWithID:alert.identifier error:error];
}

-(AAAlertInfo *)alertWithID:(NSString *)alertID {
    if (self.initialized) {
        NSFetchRequest *alertRequest = [[[NSFetchRequest alloc] initWithEntityName:@"Alert"] autorelease];
        [alertRequest setFetchLimit:1];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(id = %@)", alertID];
        [alertRequest setPredicate:predicate];

        NSManagedObject *alertObj = [self.container.viewContext executeFetchRequest:alertRequest error:nil].firstObject;

        if (alertObj) {
            NSString *title = [alertObj valueForKeyPath:@"title"];
            NSString *message = [alertObj valueForKeyPath:@"message"];

            NSArray *actions = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:[alertObj valueForKeyPath:@"actions"]];

            NSArray *textFields = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:[alertObj valueForKeyPath:@"textFields"]];

            int selectedAction = [[alertObj valueForKeyPath:@"selectedAction"] intValue];
            NSString *bundleID = [alertObj valueForKeyPath:@"bundleID"];

            NSDictionary *customAppActions = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:[alertObj valueForKeyPath:@"customAppActions"]];

            AAAlertInfo *info = [[[AAAlertInfo alloc] initWithActions:actions title:title message:message textFieldValues:textFields selectedAction:selectedAction customAppActions:[NSMutableDictionary dictionaryWithDictionary:customAppActions] bundleID:bundleID] autorelease];

            return info;
        }
    }

    return nil;
}

-(NSArray<AAAlertInfo *> *)allAlerts {
    if (self.initialized) {
        NSFetchRequest *alertRequest = [[[NSFetchRequest alloc] initWithEntityName:@"Alert"] autorelease];

        NSArray *alerts = [self.container.viewContext executeFetchRequest:alertRequest error:nil];

        NSMutableArray *alertInfos = [NSMutableArray array];

        if (alerts) {
            for (NSManagedObject *alertObj in alerts) {
                NSString *title = [alertObj valueForKeyPath:@"title"];
                NSString *message = [alertObj valueForKeyPath:@"message"];

                NSArray *actions = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:[alertObj valueForKeyPath:@"actions"]];

                NSArray *textFields = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:[alertObj valueForKeyPath:@"textFields"]];

                int selectedAction = [[alertObj valueForKeyPath:@"selectedAction"] intValue];
                NSString *bundleID = [alertObj valueForKeyPath:@"bundleID"];

                NSDictionary *customAppActions = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:[alertObj valueForKeyPath:@"customAppActions"]];

                AAAlertInfo *info = [[[AAAlertInfo alloc] initWithActions:actions title:title message:message textFieldValues:textFields selectedAction:selectedAction customAppActions:[NSMutableDictionary dictionaryWithDictionary:customAppActions] bundleID:bundleID] autorelease];

                [alertInfos addObject:info];
            }
        }

        return alertInfos;
    }
    return [NSArray array];
}

-(void)initialize {
    if (self.container && !self.initialized) {
        [self.container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription * desc, NSError * error) {
            [self.container.viewContext setMergePolicy:NSOverwriteMergePolicy];

            if (!error) {
                self.initialized = YES;
            } else {
                NSLog(@"[AutoAlerts] initialize error: %@", error);
            }
        }];
    }
}

-(void)save {
    if (self.initialized && self.container.viewContext.hasChanges) {
        NSLog(@"[AutoAlerts] SAVING!!!");

        NSError *saveError = nil;
        
        [self.container.viewContext save:&saveError];

        if (saveError) {
            NSLog(@"[AutoAlerts] save error: %@", saveError);
        }
    }
}

-(void)dealloc {
    self.container = nil;

    [super dealloc];
}

@end