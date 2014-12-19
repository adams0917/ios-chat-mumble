//
//  FriendsCell.m
//  MumblerChat
//
//  Created by Ransika De Silva on 2/21/14.
//  Copyright (c) 2014 AppDesignVault. All rights reserved.
//

#import "FriendsCell.h"

@implementation FriendsCell
@synthesize lblContactName=_lblContactName;
@synthesize imgProfile=_imgProfile;
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

-(void) drawRect:(CGRect)rect {
    
    NSLog(@"draw rect ");
    
    
}

+ (NSString *)reuseIdentifier
{
    return @"cellIdentifier";
}
@end
