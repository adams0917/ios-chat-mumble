//
//  ASExpandableTexView.m
//  ASChatControl
//
//  Created by Adnan Siddiq on 4/10/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import "ASExpandableTexView.h"

@interface ASExpandableTexView () {
    
    NSLayoutConstraint *_heightConstraint;
    CGFloat _minHight;
}

@end

@implementation ASExpandableTexView

-(void) commonInit
{
    _minHight = 0.0f;
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            _heightConstraint = constraint;
            _minHight = _heightConstraint.constant;
            break;
        }
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGSize intrinsicSize = self.intrinsicContentSize;
    if (_minHight > 0.0f) {
        intrinsicSize.height = MAX(intrinsicSize.height, _minHight);
    }
    
    intrinsicSize.height = MIN(intrinsicSize.height, 150);
    [self setHeight:intrinsicSize.height];
}

- (CGSize)intrinsicContentSize
{
    CGSize intrinsicContentSize = self.contentSize;
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        intrinsicContentSize.width += (self.textContainerInset.left + self.textContainerInset.right ) / 2.0f;
//        intrinsicContentSize.height += (self.textContainerInset.top + self.textContainerInset.bottom) / 2.0f;
//    }
    
    return intrinsicContentSize;
}

- (void)setHeight:(CGFloat)height {
    
    _heightConstraint.constant = height;
}
@end
