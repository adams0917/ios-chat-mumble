//
//  ChatViewController.h
//  MumblerChat
//
//  Created by Ransika De Silva on 9/27/14.
//
//

#import <UIKit/UIKit.h>
#import "ASKeyboardHandlerView.h"
#import "ASExpandableTexView.h"
#import "ASProgressView.h"
#import "ASSliderView.h"
#import "ASMessageHandlerView.h"


@interface ChatViewController : UIViewController{
    
}


-(void) notifyCountDownTimerComplete;
-(void) tick :(NSString *) remainingSeconds;


@property (nonatomic, weak) IBOutlet ASKeyboardHandlerView *mainOptionView;
@property (nonatomic, weak) IBOutlet ASExpandableTexView *messageTextView;
@property (nonatomic, weak) IBOutlet ASProgressView *countDownProgress;
@property (nonatomic, weak) IBOutlet ASSliderView *sliderView;

@property (nonatomic, weak) IBOutlet UIView *controlView;
@property (nonatomic, weak) IBOutlet UIView *countDownView;


@end
