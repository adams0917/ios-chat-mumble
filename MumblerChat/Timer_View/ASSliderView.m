//
//  ASSliderView.m
//  ASChatControl
//
//  Created by Adnan Siddiq on 4/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import "ASSliderView.h"

@interface ASSliderView ()

@property (nonatomic, weak) IBOutlet UISlider *timeSlider;

@property (nonatomic, weak) IBOutlet UIView *sliderValueView;
@property (nonatomic, weak) IBOutlet UILabel *sliderValueLabel;

@end

@implementation ASSliderView

- (void)commitInitial {
    UIImage *track = [UIImage imageNamed:@"transparentImg.png"];
    [_timeSlider setMinimumTrackImage:track forState:UIControlStateNormal];
    [_timeSlider setMaximumTrackImage:track forState:UIControlStateNormal];
   // [_timeSlider setMinimumTrackTintColor:<#(UIColor *)#>]
   // [_timeSlider setMaximumTrackTintColor:<#(UIColor *)#>];
    
    [_timeSlider setThumbImage:[UIImage imageNamed:@"slider_bob"] forState:UIControlStateNormal];
    [self.superview.superview addSubview:_sliderValueView];
}


- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self commitInitial];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updatePopoverFrame];
}

- (IBAction)sliderValueChange:(UISlider *)sender {
    
    
    [self updatePopoverFrame];
}

- (IBAction)popOverShown:(id)sender {
//    [self showPopoverAnimated: YES];
}

- (IBAction)popoverViewSetting:(id)sender {
    
//    [self hidePopoverAnimated:YES];
}

- (int)currentValue {
    
    return (int)self.timeSlider.value;
}

- (void)setCurrentValue:(int)value {
    
    NSLog(@"setCurrentValue %i ", value);
    self.timeSlider.value = value;
    [self updatePopoverFrame];
}
- (void)showPopoverAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.sliderValueView.alpha = 1.0;
        }];
    } else {
        self.sliderValueView.alpha = 1.0;
    }
}

- (void)hidePopover
{
    [self hidePopoverAnimated:NO];
}

- (void)hidePopoverAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.sliderValueView.alpha = 0;
        }];
    } else {
        self.sliderValueView.alpha = 0;
    }
}

- (void)updatePopoverFrame
{
    CGFloat minimum =  self.timeSlider.minimumValue;
	CGFloat maximum = self.timeSlider.maximumValue;
	CGFloat value = self.timeSlider.value;
	
	if (minimum < 0.0) {
        
		value = self.timeSlider.value - minimum;
		maximum = maximum - minimum;
		minimum = 0.0;
	}
	
	CGFloat x = self.timeSlider.frame.origin.x;
    CGFloat maxMin = (maximum + minimum) / 2.0;
    
    x += (((value - minimum) / (maximum - minimum)) * self.timeSlider.frame.size.width) - (self.sliderValueView.frame.size.width / 2.0);
	
	if (value > maxMin) {
		
		value = (value - maxMin) + (minimum * 1.0);
		value = value / maxMin;
		value = value * 11.0;
		
		x = x - value;
        
	} else {
		
		value = (maxMin - value) + (minimum * 1.0);
		value = value / maxMin;
		value = value * 11.0;
		
		x = x + value;
	}
    
    CGRect popoverRect = self.sliderValueView.frame;
    popoverRect.origin.x = x;
    popoverRect.origin.y = self.superview.frame.origin.y - 37 + 5 + self.timeSlider.frame.origin.y;
    
    self.sliderValueView.frame = popoverRect;
    self.sliderValueLabel.text = [NSString stringWithFormat:@"%d", (int)self.timeSlider.value];
}
-(void)showPopUp{
    
    [self.sliderValueView setHidden:NO];

    
}

-(void)hidePopUp{
    
    [self.sliderValueView setHidden:YES];
    
}


@end
