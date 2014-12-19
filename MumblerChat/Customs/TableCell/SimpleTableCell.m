//
//  SimpleTableCell.m
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import "SimpleTableCell.h"

@implementation SimpleTableCell
@synthesize nameLabel = _nameLabel;
@synthesize statusLabel = _statusLabel;
@synthesize thumbnailImageView = _thumbnailImageView;
@synthesize onlineStatusImageView = _onlineStatusImageView;

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
    
    self.thumbnailImageView.layer.cornerRadius = 7.0;
    self.thumbnailImageView.layer.masksToBounds = YES;
    self.thumbnailImageView.layer.borderColor = [UIColor colorWithRed:1/255.0 green:64/255.0 blue:81/255.0 alpha:0.5].CGColor;
    self.thumbnailImageView.layer.borderWidth = 2.0;
    
    
}

@end
