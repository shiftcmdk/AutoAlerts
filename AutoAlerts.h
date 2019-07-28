#import "Model/AAAlertInfo.h"
#import "AAConfigurationViewControllerDelegate.h"

@interface UIAlertController () <AAConfigurationViewControllerDelegate>

@property (readonly) NSMutableArray * _actions;
-(void)_dismissWithAction:(id)arg1 dismissCompletion:(/*^block*/id)arg2;
@property (readonly) UIView * _dimmingView;
-(void)setTextFieldsCanBecomeFirstResponder:(BOOL)arg1 ;
-(void)_dismissAnimated:(BOOL)arg1 triggeringAction:(id)arg2 ;
-(void)_dismissWithCancelAction;
-(void)_dismissAnimated:(BOOL)arg1 triggeringAction:(id)arg2 triggeredByPopoverDimmingView:(BOOL)arg3 dismissCompletion:(/*^block*/id)arg4;
-(void)autoPopulateTextFields;
-(void)aa_runSelectedAction:(int)selectedAction;
@property (readonly) UIView * _foregroundView;
@property (getter=_window,nonatomic,readonly) UIWindow * window; 
@property (setter=_setActions:,nonatomic,retain) NSArray * actions;
@property (nonatomic, retain) AAAlertInfo *alertInfo;
@property (nonatomic, retain) UIViewController *dummyViewController;
@property (nonatomic, assign) BOOL automated;

@end

@interface UITextField ()

-(void)paste:(id)arg1 ;
-(void)_pasteAttributedString:(id)arg1 pasteAsRichText:(BOOL)arg2 ;
-(void)_performPasteOfAttributedString:(id)arg1 toRange:(id)arg2 animator:(id)arg3 completion:(/*^block*/id)arg4 ;
-(void)insertText:(id)arg1 ;
-(void)clearText;

@end

@interface _UIAlertControllerView : UIView
@end

@interface SBAlertItem : NSObject

-(void)dismiss;

@end

@interface _SBAlertController : UIAlertController
@end

@interface SpringBoard: UIApplication

-(id)_accessibilityFrontMostApplication;

@end