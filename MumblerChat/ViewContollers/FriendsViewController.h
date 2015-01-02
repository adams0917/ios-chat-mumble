//
//  FriendsViewController.h
//  MumblerChat
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ASAppDelegate.h"
#import "ChatMessage.h"
#import "FriendTableViewCell.h"

@interface FriendsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate,UINavigationControllerDelegate,NSFetchedResultsControllerDelegate,UIAlertViewDelegate,FriendTableViewCellDelegate>
{
    ASAppDelegate *appDelegate;
    NSMutableArray *friendIdsArray;
    
}

@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (weak,nonatomic) NSMutableDictionary *friendsDictionary;


@property (weak, nonatomic) NSString *actionType;
@property (weak, nonatomic) NSString *messageNeedToBeSend;
@property (weak, nonatomic) ChatMessage *composedChatMsg;


@end
