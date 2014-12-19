//
//  SplashViewController.h
//  MumblerChat
//


#import <UIKit/UIKit.h>
#import "ASAppDelegate.h"

@interface SplashViewController : UIViewController<FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

@end
