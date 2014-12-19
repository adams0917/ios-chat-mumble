#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define  TAB_BAR_HEIGHT 50
#define placement 64

@interface CustomTabController : UITabBarController<UIGestureRecognizerDelegate,MFMessageComposeViewControllerDelegate>{
    UIImageView *btn1View;
    UIImageView *btn2View;
    UIImageView *btn3View;
}


@property (nonatomic, retain) UIButton *btn1;
@property (nonatomic, retain) UIButton *btn2;
@property (nonatomic, retain) UIButton *btn3;
@property(nonatomic,assign)BOOL isFromSignUp;

- (void)selectTab:(int)tabID;

@end
