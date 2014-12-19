//
//  ChatViewController.m
//  MumblerChat
//
//  Created by Ransika De Silva on 9/27/14.
//
//

#import "ChatViewController.h"

@interface ChatViewController ()
{
    NSInteger remainingSecondsTrack;
}

@end

@implementation ChatViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) notifyCountDownTimerComplete
{
    NSLog(@"notifyCountDownTimerComplete");
}

-(void) tick:(NSString *)remainingSeconds
{
    remainingSecondsTrack = [remainingSeconds intValue];
    NSLog(@"remainingSecondsTrack remainingSeconds %@", remainingSeconds);
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.controlView.hidden = YES;
    self.countDownView.hidden = YES;
    _countDownView.hidden = NO;
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
