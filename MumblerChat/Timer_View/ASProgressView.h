#import <UIKit/UIKit.h>


@interface ASProgressView : UIView

@property (nonatomic, readwrite, assign) CGFloat progress;

@property (nonatomic, readwrite, assign) CGFloat minProgressValue;

@property (nonatomic, readwrite, assign) CGFloat maxProgressValue;

@property (nonatomic, retain) UIViewController *chatViewController;

- (void)startCountDownFromSeconds: (int) totalSecondsGiven :(int)seconds;

- (void)completeCountDown;


- (void) stopCountDown;


-(void) resetCountDownTimer :(int) totalSecondsGiven :(int)seconds;


@end
