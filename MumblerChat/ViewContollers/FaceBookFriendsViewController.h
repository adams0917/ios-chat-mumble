//
//  FaceBookFriendsViewController.h
//  MumblerChat


#import "FaceBookFriendsViewController.h"
#import <UIKit/UIKit.h>
#import "FacebookSDK/FacebookSDK.h"
#import "SVProgressHUD.h"

@interface FaceBookFriendsViewController : UIViewController <FBLoginViewDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate, UISearchDisplayDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@property (weak, nonatomic) IBOutlet UISearchBar *faceBookFriendsSearchBar;
@property(nonatomic,strong)NSMutableArray* allFriendsData;
@property (weak, nonatomic) IBOutlet UITableView *facebookFriendsTableView;
@property(nonatomic,strong)NSMutableArray*sections;
@property(nonatomic,strong)NSMutableDictionary*sectionWiseData;
@end
