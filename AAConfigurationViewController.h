#import "AAConfigurationViewControllerDelegate.h"

@interface AAConfigurationViewController: UIViewController

-(id)initWithActions:(NSArray<NSString *> *)actions title:(NSString *)title message:(NSString *)message textFieldValues:(NSArray<NSString *> *)textFieldValues customAppActions:(NSDictionary<NSString *, NSNumber *> *)customAppActions secure:(BOOL)secure;
@property (nonatomic, assign) id<AAConfigurationViewControllerDelegate> delegate;

@end