//
//  ASShrinkableView.m
//  ASChatControl
//
//  Created by Adnan Siddiq on 4/10/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import "ASShrinkableView.h"

@interface ASShrinkableView () {
    
    NSLayoutConstraint *_heigtConstraint;
    CGFloat _actualHeight;
}

@end

@implementation ASShrinkableView

- (void)initialSetting {
    
    for (NSLayoutConstraint *constrain in self.constraints) {
        
        if (constrain.firstAttribute == NSLayoutAttributeHeight) {
            _heigtConstraint = constrain;
            _actualHeight = _heigtConstraint.constant;
            break;
        }
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initialSetting];
    }
    return self;
}

- (void)setHidden:(BOOL)hidden {
    
    [super setHidden:hidden];
    
    if (hidden) {
        _heigtConstraint.constant = 0;
    } else {
        _heigtConstraint.constant = _actualHeight;
    }
}

@end
