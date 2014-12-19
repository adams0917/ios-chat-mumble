//
//  ChatThreadTableViewCell.h
//  MumblerChat


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ChatThreadCellType) {
    
    //THREAD TYPE
    //From friend
    ChatThreadCellType_New_Opened_Question_For_Me = 0,
    ChatThreadCellType_New_Opened_Statement_For_Me = 1,
    ChatThreadCellType_New_Opened_Image_For_Me = 2,
    ChatThreadCellType_New_Opened_Video_For_Me = 3,
    
    
    ChatThreadCellType_New_Non_Opened_Question_For_Me = 4,
    ChatThreadCellType_New_Non_Opened_Statement_For_Me = 5,
    ChatThreadCellType_New_Non_Opened_Image_For_Me = 6,
    ChatThreadCellType_New_Non_Opened_Video_For_Me = 7,
    
    //sent by me
    ChatThreadCellType_Question_From_Me = 8,
    ChatThreadCellType_Statement_From_Me = 9,
    ChatThreadCellType_Image_From_Me = 10,
    ChatThreadCellType_Video_From_Me = 11,
    
};

@interface ChatThreadTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameUILabel;
@property (weak, nonatomic) IBOutlet UILabel *subUILabel;
@property (weak, nonatomic) IBOutlet UIImageView *messageStatusImageView;
@property (weak, nonatomic) IBOutlet UIImageView *subMessageStatusImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageStatusUILabel;
@property (nonatomic) ChatThreadCellType chatThreadCell;


@end
