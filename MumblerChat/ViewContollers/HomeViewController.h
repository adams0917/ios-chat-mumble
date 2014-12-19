//
//  HomeViewController.h
//  MumblerChat
//


#import <UIKit/UIKit.h>
#import "FacebookSDK/FacebookSDK.h"

@interface HomeViewController : UIViewController<FBLoginViewDelegate>
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@property(nonatomic,assign)NSString *aliasMumblerChat;
@end

