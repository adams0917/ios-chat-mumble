//
//  LeftToRightNavigationSegue.m
//  Flattened
//
//  Created by Ransika De Silva on 2/9/14.
//  Copyright (c) 2014 AppDesignVault. All rights reserved.
//

#import "LeftToRightNavigationSegue.h"
#import "QuartzCore/QuartzCore.h"

@implementation LeftToRightNavigationSegue


-(void)perform {
/*

    UIViewController *srcViewController = (UIViewController *) self.sourceViewController;
    UIViewController *destViewController = (UIViewController *) self.destinationViewController;
    CATransition *transition = [CATransition animation];
    transition.startProgress = 0;
    transition.endProgress = 1.0;
    transition.duration = 0.1;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;

    [srcViewController.view.window.layer addAnimation:transition forKey:nil];
    
   //[srcViewController presentViewController:destViewController animated:NO completion:nil];
    
    [UIView setAnimationDuration:0.1];
    [srcViewController.navigationController.view.layer addAnimation:transition
                                                                forKey:kCATransition];
     [srcViewController.view.superview insertSubview:destViewController.view atIndex:0];
     [destViewController.view removeFromSuperview]; 
    [srcViewController.navigationController pushViewController:destViewController animated:NO];
    */

    
    
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    
    CATransition* transition = [CATransition animation];
    transition.duration = .30;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromLeft; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    
    
    
    [sourceViewController.navigationController.view.layer addAnimation:transition
                                                                forKey:kCATransition];
    
    [sourceViewController.navigationController pushViewController:destinationController animated:NO];
    
    
}
@end
