//
//  ASMessageHandlerView.m
//  ASChatControl
//
//  Created by Adnan Siddiq on 4/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import "ASMessageHandlerView.h"

@implementation ASMessageHandlerView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIImage *image = self.messageBg.image;
    
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(14, 0, 14, 0) resizingMode:UIImageResizingModeStretch];
    
    self.messageBg.image = image;
    
}
@end
