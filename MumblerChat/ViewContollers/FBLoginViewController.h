//
//  FBLoginViewController.h
//  MumblerChat
//


#import <UIKit/UIKit.h>
#import "FacebookSDK/FacebookSDK.h"
@interface FBLoginViewController : UIViewController<FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;


@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@end
