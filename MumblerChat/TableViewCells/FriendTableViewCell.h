//
//  FriendTableViewCell.h
//  MumblerChat
//


#import <UIKit/UIKit.h>
#import "RoundedImageView.h"
#import "User.h"

typedef NS_ENUM(NSUInteger, FriendCellType) {
    
    //FaceBook
    FriendCellTypeFBFriendsWithMumbler = 0,
    FriendCellTypeFBInviteFriendsToMumbler = 1,
    FriendCellTypeFBAddedFriendsWithMumbler=10,
    
    //Contacts................
    FriendCellTypeContactsFriendsWithMumbler = 2,
    FriendCellTypeContactsInviteFriendsToMumbler = 3,
    
    
    //Added friends with mumbler
    FriendCellTypeContactsAdddedFriend = 4,
    //text wit mum
    FriendCellTypeContactsSelectedForSendATextToFriend = 5,
    
    
    
    //Add & Find Friends
    FriendCellTypeSearch_Not_Added_Friends = 6,
    FriendCellTypeSearch_Added_Friends = 7,
    
    //Friends View.............
    FriendCellTypeFriendsOffline = 8,
    FriendCellTypeFriendsOnline = 9,
    //Friends to be selected for sending new chat
    FriendCellTypeFriendsToBeSelectedToSendMsgs=11,
   
    
};

@protocol FriendTableViewCellDelegate <NSObject>

- (void)friendCellWithUser:(User *)user changedState:(BOOL)selected;

@end

@interface FriendTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *displayNameOne;
@property (weak, nonatomic) IBOutlet UILabel *displayNameTwo;
@property (weak, nonatomic) IBOutlet UIButton *rowButton;
@property (nonatomic) FriendCellType friendCellType;
@property (nonatomic) NSDictionary *mumblerUser;
@property (nonatomic) RoundedImageView *roundedImageView;
@property (weak, nonatomic) IBOutlet RoundedImageView *profileImageRoundedImageView;
@property (nonatomic) User *friendUser;

@property (strong, nonatomic) IBOutlet UIImageView *selectAllCheckboxImageView;

@property (weak, nonatomic) id<FriendTableViewCellDelegate> delegate;

@end
