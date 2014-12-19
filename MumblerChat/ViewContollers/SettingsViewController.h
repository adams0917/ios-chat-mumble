//
//  SettingsViewController.h
//  MumblerChat
//


#import <UIKit/UIKit.h>
#import "ASSliderView.h"
#import "NYSliderPopover.h"
#import "FacebookSDK/FacebookSDK.h"

@interface SettingsViewController : UIViewController<UIActionSheetDelegate,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,FBLoginViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *statusTextField;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) IBOutlet UILabel *mobileLabel;

@property (nonatomic, retain) NSMutableDictionary *settingDictionary;
@property (nonatomic, retain) NSMutableDictionary *profileDictionary;
@property (weak, nonatomic) IBOutlet UIButton *whoCanMsgMeButton;
@property (nonatomic, strong) IBOutlet NYSliderPopover *slider;
@property(nonatomic,strong)UIPopoverController *popOverController;


@property(nonatomic,assign)NSString *actionSheetType;

@property (weak, nonatomic) IBOutlet UIView *changePhotoPopUpView;

@property (weak, nonatomic) IBOutlet UIButton *profileButton;

@property (nonatomic, weak) IBOutlet ASSliderView *sliderView;

@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

@property (weak, nonatomic) IBOutlet UIButton *removeProfImageButton;

@property(nonatomic,strong) IBOutlet UISwitch* switchAlert;
@property(nonatomic,strong) IBOutlet UISwitch* switchSaveMedia;


@end
