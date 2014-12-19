//
//  MyChatTableViewCell.m
//  MumblerChat
//
//  Created by Ransika De Silva on 9/9/14.
//
//

#import "MyChatTableViewCell.h"

@implementation MyChatTableViewCell
@synthesize bubbleImageView=_bubbleImageView;
@synthesize chatImage=_chatImage;
@synthesize maskImage=_maskImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    UIImage *imageIcon;
    
    switch (_chatCellType) {
            
            
        case ChatCellTypeMyChat_Statement:
            imageIcon = [UIImage imageNamed:@"statement_mine"];
            self.bubbleImageView.image=imageIcon;
            
            break;
            
        case ChatCellTypeMyChat_Question:
            imageIcon = [UIImage imageNamed:@"bubble_c"];
            self.bubbleImageView.image=imageIcon;
            break;
            
        case ChatCellTypeFriendChat_statement:
            imageIcon = [UIImage imageNamed:@"incomming"];
            self.bubbleImageView.image=imageIcon;
            break;
            
        case ChatCellTypeFriendChat_Question:
            imageIcon = [UIImage imageNamed:@"question_incomming"];
            self.bubbleImageView.image=imageIcon;
            break;
            
        case ChatCellTypeMyChatOther:
            
           /* _profileImageView.layer.cornerRadius = 20.0;
            _profileImageView.layer.masksToBounds = YES;
            _profileImageView.layer.borderColor = [UIColor colorWithRed:42/255.0 green:194/255.0 blue:217/255.0 alpha:1].CGColor;
            _profileImageView.layer.borderWidth = 2.0;
*/
            
            _bubbleImageView.image = [self maskImage:_chatImage withMask:_maskImage];
            [self layoutIfNeeded];
            
            break;
            

            
        default:
            break;
    }
    
    UIImage *img = self.bubbleImageView.image;
    self.bubbleImageView.image = [img stretchableImageWithLeftCapWidth:21 topCapHeight:14];
    

    
}



- (UIImage*) maskImage:(UIImage *) image withMask:(UIImage *) mask
{
    CGImageRef imageReference = image.CGImage;
    CGImageRef maskReference = mask.CGImage;
    
    CGImageRef imageMask = CGImageMaskCreate(CGImageGetWidth(maskReference),
                                             CGImageGetHeight(maskReference),
                                             CGImageGetBitsPerComponent(maskReference),
                                             CGImageGetBitsPerPixel(maskReference),
                                             CGImageGetBytesPerRow(maskReference),
                                             CGImageGetDataProvider(maskReference),
                                             NULL, // Decode is null
                                             YES // Should interpolate
                                             );
    
    CGImageRef maskedReference = CGImageCreateWithMask(imageReference, imageMask);
    CGImageRelease(imageMask);
    
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedReference];
    CGImageRelease(maskedReference);
    
    return maskedImage;
    
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

@end
