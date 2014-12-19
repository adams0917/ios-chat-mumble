#import "ASProgressView.h"
#import "ChatComposerViewController.h"

@interface ASProgressView () {
    
    NSTimer *_timer;
}

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *progressConstraint;
@property (nonatomic, weak) IBOutlet UILabel *lblValue;

@end

@implementation ASProgressView

@synthesize chatViewController;

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.minProgressValue = 0.0f;
        self.maxProgressValue = 1.0f;
        self.progress = 0.0f;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self progressImageDraw];
}

- (void)progressImageDraw
{
    
    int minutes = _progress/60;
    int seconds = _progress - minutes*60;
    
    self.lblValue.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    
    CGFloat percentProgress = (_progress - self.minProgressValue) / (self.maxProgressValue - self.minProgressValue);

    CGFloat totalWidth = self.frame.size.width - 2;
    CGFloat progress = totalWidth - totalWidth*percentProgress;

    self.progressConstraint.constant = progress + 1;
    
    [self layoutIfNeeded];
    
}

- (void)setProgress:(CGFloat)theProgress
{
    if (self.progress == theProgress) {
        return;
    }
    
    // check range and pin to its limits if required
    if (theProgress < self.minProgressValue) {
        theProgress = self.minProgressValue;
    }
    if (theProgress > self.maxProgressValue) {
        theProgress = self.maxProgressValue;
    }
    
    _progress = theProgress;
    
    [self progressImageDraw];
}



- (void)startCountDownFromSeconds: (int) totalSecondsGiven :(int)seconds {
    
    
    self.minProgressValue = 0.0;
    self.maxProgressValue = totalSecondsGiven;
    self.progress = seconds;
    
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
        
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.0125 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
 //   [self performSelector:@selector(completeCountDown) withObject:nil afterDelay:seconds];

}

- (void)countDown {
   //self.progress --;
       
    [UIView animateWithDuration:0.0125 animations:^{
        self.progress = self.progress - 0.0125;
        
    }];
    ChatComposerViewController *chat = (ChatComposerViewController *) chatViewController;
    [chat tick:[NSString stringWithFormat:@"%i", (int)self.progress]];

    
    if (self.progress == 0) {
        [self completeCountDown];
    }
}

- (void) stopCountDown {
   
    NSLog(@"stopCountDown timer");
    
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void) resetCountDownTimer :(int) totalSecondsGiven :(int)seconds {
   
    NSLog(@"Resetting the timer");
    
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    
    [self startCountDownFromSeconds:totalSecondsGiven :seconds];

}

- (void)completeCountDown {
    
    NSLog(@"completeCountDown/------");
    
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    self.progress = 0.0;
    
    ChatComposerViewController *chat = (ChatComposerViewController *) chatViewController;
    [chat notifyCountDownTimerComplete];
    //[(ChatComposerViewController *)[[self superview] nextResponder] notifyCountDownTimerComplete];
}
@end
