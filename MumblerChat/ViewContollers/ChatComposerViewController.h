//
//  ChatComposerViewController.h
//  MumblerChat
//
//  Created by Ransika De Silva on 9/9/14.
//
//

#import <UIKit/UIKit.h>
#import "ASAppDelegate.h"
#import "ChatMessageDao.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "User.h"
#import "ChatThread.h"
#import "ASSliderView.h"
#import "ASProgressView.h"
#import "ASKeyboardHandlerView.h"
#import "ASExpandableTexView.h"
#import "ASShrinkableView.h"

@interface ChatComposerViewController : UIViewController<UIGestureRecognizerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate, UITextViewDelegate>
{
}

@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) NSString *actionType;
@property (nonatomic) User *mumblerFriend;

@property (nonatomic) ChatThread *chatThread;


@property (weak, nonatomic) IBOutlet UITableView *chatComposerTableView;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UILabel *chatHeaderLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (nonatomic, weak) IBOutlet ASKeyboardHandlerView *mainOptionView;
@property (nonatomic, weak) IBOutlet ASExpandableTexView *messageTextView;

@property (nonatomic, weak) IBOutlet ASSliderView *sliderView;

@property (nonatomic, weak) IBOutlet UIView *controlView;
@property (nonatomic, weak) IBOutlet UIView *countDownView;

@property (nonatomic, weak) IBOutlet UIView *popupView;


@property (nonatomic, weak) IBOutlet ASProgressView *cdp;

@property(nonatomic,weak)IBOutlet UIButton *plusButton;
@property(nonatomic,weak)IBOutlet UIButton *sendButton;

-(void) tick :(NSString *) remainingSeconds;
-(void) notifyCountDownTimerComplete;

@end
