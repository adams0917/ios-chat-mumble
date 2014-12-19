//
//  MyChatTableViewCell.h
//  MumblerChat
//
//  Created by Ransika De Silva on 9/9/14.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ChatCellType) {
    
    //MyChat
    ChatCellTypeMyChat_Statement = 0,
    ChatCellTypeMyChat_Question = 1,
   
    ChatCellTypeFriendChat_statement = 2,
    ChatCellTypeFriendChat_Question=3,
    
    ChatCellTypeMyChatOther = 4,
    ChatCellTypeFriendChatOther = 5,
    
};

@interface MyChatTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *deliveryStatusImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (nonatomic) ChatCellType chatCellType;

@property (nonatomic) UIImage *chatImage;
@property (nonatomic, strong) UIImage *maskImage;

@property (weak, nonatomic) IBOutlet UILabel *chatSeenLabel;




@end
