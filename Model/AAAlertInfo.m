#import "AAAlertInfo.h"

@implementation AAAlertInfo

-(id)initWithActions:(NSArray<NSString *> *)actions title:(NSString *)title message:(NSString *)message textFieldValues:(NSArray<NSString *> *)textFieldValues selectedAction:(int)selectedAction customAppActions:(NSMutableDictionary<NSString *, NSNumber *> *)customAppActions bundleID:(NSString *)bundleID {
    if (self = [super init]) {
        self.actions = actions;
        self.title = title;
        self.message = message;
        self.textFieldValues = textFieldValues;
        self.selectedAction = selectedAction;
        self.customAppActions = customAppActions;
        self.bundleID = bundleID;

        NSMutableString *actionsString = [NSMutableString string];

        for (NSString *value in self.actions) {
            [actionsString appendString:value];
        }

        self.identifier = [NSString stringWithFormat:@"%@%@%@t_%ia_%i_%@", self.title, self.message, actionsString, (int)self.textFieldValues.count, (int)self.actions.count, self.bundleID];
    }
    
    return self;
}

-(void)dealloc {
    self.actions = nil;
    self.title = nil;
    self.message = nil;
    self.textFieldValues = nil;
    self.customAppActions = nil;
    self.bundleID = nil;
    self.identifier = nil;

    [super dealloc];
}

@end