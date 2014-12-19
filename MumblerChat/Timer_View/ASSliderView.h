//
//  ASSliderView.h
//  ASChatControl
//
//  Created by Adnan Siddiq on 4/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ASSliderView : UIView

- (int)currentValue;

- (void)setCurrentValue:(int)value;

-(void)showPopUp;
-(void)hidePopUp;


@end
