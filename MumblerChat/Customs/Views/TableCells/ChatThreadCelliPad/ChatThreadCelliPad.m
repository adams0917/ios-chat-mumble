//
//  ChatThreadCelliPad.m
//  MumblerChat
//
//  Created by Tharaka Dushmantha on 4/8/14.
//  Copyright (c) 2014 AppDesignVault. All rights reserved.
//

#import "ChatThreadCelliPad.h"

@implementation ChatThreadCelliPad

@synthesize lblChatType;
@synthesize lblTime;
@synthesize lblName;
@synthesize imageView;
@synthesize imgChatIcon;
@synthesize imgSendType;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imgChatIcon.layer.cornerRadius = 7.0;
    self.imgChatIcon.layer.masksToBounds = YES;
    self.imgChatIcon.layer.borderColor = [UIColor colorWithRed:1/255.0 green:64/255.0 blue:81/255.0 alpha:0.5].CGColor;
    self.imgChatIcon.layer.borderWidth = 2.0;
    
    
}
@end
