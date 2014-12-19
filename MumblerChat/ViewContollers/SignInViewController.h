//
//  SignInViewController.h
//  MumblerChat
//


#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end
