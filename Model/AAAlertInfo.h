@interface AAAlertInfo: NSObject

@property (nonatomic, retain) NSArray<NSString *> *actions;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, retain) NSArray<NSString *> *textFieldValues;
@property (nonatomic, assign) NSInteger selectedAction;
@property (nonatomic, retain) NSMutableDictionary<NSString *, NSNumber *> *customAppActions;
@property (nonatomic, copy) NSString *bundleID;
@property (nonatomic, copy) NSString *identifier;

-(id)initWithActions:(NSArray<NSString *> *)actions title:(NSString *)title message:(NSString *)message textFieldValues:(NSArray<NSString *> *)textFieldValues selectedAction:(int)selectedAction customAppActions:(NSMutableDictionary<NSString *, NSNumber *> *)customAppActions bundleID:(NSString *)bundleID;

@end