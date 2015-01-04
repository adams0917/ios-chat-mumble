//
//  ChatThreadTableViewCell.m
//  MumblerChat


#import "ChatThreadTableViewCell.h"

@implementation ChatThreadTableViewCell
@synthesize messageStatusImageView=_messageStatusImageView;
@synthesize nameUILabel=_nameUILabel;
@synthesize messageStatusUILabel=_messageStatusUILabel;
@synthesize subMessageStatusImageView=_subMessageStatusImageView;
@synthesize subUILabel=_subUILabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    UIImage *imageIcon1;
    UIImage *imageIcon2;
    
    
    switch (_chatThreadCell) {
            
        case ChatThreadCellType_New_Opened_Question_For_Me:
            imageIcon1 = [UIImage imageNamed:@"question_orange"];
           // imageIcon2 = [UIImage imageNamed:@"message02_gray"];
            
            _messageStatusImageView.image =imageIcon1;
           // _subMessageStatusImageView.image =imageIcon2;
            
            break;
            
        case ChatThreadCellType_New_Opened_Statement_For_Me:
            imageIcon1 = [UIImage imageNamed:@"exclamation_orange"];
            //imageIcon2 = [UIImage imageNamed:@"message02_gray"];
            
            _messageStatusImageView.image =imageIcon1;
            //_subMessageStatusImageView.image =imageIcon2;
            
            break;
            
        case ChatThreadCellType_New_Opened_Image_For_Me:
            
            imageIcon1 = [UIImage imageNamed:@"picture_gray"];
            //imageIcon2 = [UIImage imageNamed:@"picture_gray"];
            
            _messageStatusImageView.image =imageIcon1;
            //_subMessageStatusImageView.image =imageIcon2;
            
            
            break;
            
        case ChatThreadCellType_New_Non_Opened_Video_For_Me:
            imageIcon1 = [UIImage imageNamed:@"movie_gray"];
            //imageIcon2 = [UIImage imageNamed:@"movie_gray"];
            
            _messageStatusImageView.image =imageIcon1;
           // _subMessageStatusImageView.image =imageIcon2;
            
            
            break;
            
            
            
            //////////////////
            
            
        case ChatThreadCellType_New_Non_Opened_Question_For_Me:
            
            imageIcon1 = [UIImage imageNamed:@"question_orange"];
            //imageIcon2 = [UIImage imageNamed:@"message01_orange"];
            
            _messageStatusImageView.image =imageIcon1;
            //_subMessageStatusImageView.image =imageIcon2;
            
            
            break;
            
        case ChatThreadCellType_New_Non_Opened_Statement_For_Me:
            imageIcon1 = [UIImage imageNamed:@"exclamation_orange"];
            //imageIcon2 = [UIImage imageNamed:@"message01_orange"];
            
            _messageStatusImageView.image = imageIcon1;
            //_subMessageStatusImageView.image =imageIcon2;
            
            break;
            
        case ChatThreadCellType_New_Non_Opened_Image_For_Me:
            
            imageIcon1 = [UIImage imageNamed:@"picture_orange"];
            //imageIcon2 = [UIImage imageNamed:@"picture_orange"];
            
            _messageStatusImageView.image =imageIcon1;
            //_subMessageStatusImageView.image =imageIcon2;
            
            
            break;
            
        case ChatThreadCellType_New_Opened_Video_For_Me:
           
            imageIcon1 = [UIImage imageNamed:@"movie_orange"];
            //imageIcon2 = [UIImage imageNamed:@"movie_orange"];
            
            _messageStatusImageView.image =imageIcon1;
           // _subMessageStatusImageView.image =imageIcon2;
            
            
            break;
            

         ///////////////////////////
            
            
        case ChatThreadCellType_Question_From_Me:
            
            imageIcon1 = [UIImage imageNamed:@"question"];
            //imageIcon2 = [UIImage imageNamed:@"message01_gray"];
            
            _messageStatusImageView.image =imageIcon1;
            //_subMessageStatusImageView.image =imageIcon2;
            
            
            break;
            
        case ChatThreadCellType_Statement_From_Me:
            imageIcon1 = [UIImage imageNamed:@"exclamation"];
            //imageIcon2 = [UIImage imageNamed:@"message01_gray"];
            
            _messageStatusImageView.image =imageIcon1;
           // _subMessageStatusImageView.image =imageIcon2;
            
            break;
            
        case ChatThreadCellType_Image_From_Me:
       
            imageIcon1 = [UIImage imageNamed:@"picture_gray"];
            //imageIcon2 = [UIImage imageNamed:@"picture_gray"];
            
            _messageStatusImageView.image =imageIcon1;
           // _subMessageStatusImageView.image =imageIcon2;
            
            break;
            
        case ChatThreadCellType_Video_From_Me:
            
            imageIcon1 = [UIImage imageNamed:@"movie_gray"];
           // imageIcon2 = [UIImage imageNamed:@"movie_gray"];
            
            _messageStatusImageView.image =imageIcon1;
            //_subMessageStatusImageView.image =imageIcon2;
            
            break;
            
        default:
            break;
    }
}



@end
