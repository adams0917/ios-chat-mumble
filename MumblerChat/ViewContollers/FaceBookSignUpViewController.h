//
//  FaceBookSignUpViewController.h
//  MumblerChat
//


#import <UIKit/UIKit.h>

@interface FaceBookSignUpViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileNumberTextField;

@end
