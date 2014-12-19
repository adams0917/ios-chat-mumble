//
//  ASKeyboardHandlerView.m
//  ASChatControl
//
//  Created by Adnan Siddiq on 4/10/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import "ASKeyboardHandlerView.h"

@interface ASKeyboardHandlerView () {
    
    
}

@end

@implementation ASKeyboardHandlerView

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    for (UIView *v in self.subviews) {
        [v layoutSubviews];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.superview convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.size.height;
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    NSUInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    [UIView animateWithDuration:animationDuration delay:0.0
                        options:animationCurve
                     animations:^ {
                         self.bottomConstraint.constant = keyboardTop;
                         [self.superview layoutIfNeeded];
                     } completion:nil];
    
}


- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    NSUInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    [UIView animateWithDuration:animationDuration delay:0.0
                                 options:animationCurve
                              animations:^ {
                                  self.bottomConstraint.constant = 0.0;
                                  [self.superview layoutIfNeeded];

                              } completion:nil];

}


@end
