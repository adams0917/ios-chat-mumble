//
//  TakePhotosViewController.h
//  MumblerChat
//
//  Created by Tharaka Dushmantha on 3/7/14.
//  Copyright (c) 2014 AppDesignVault. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import "OverLayViewController.h"
//#import "MumblerUser.h"
@interface TakePhotosViewController : UIViewController
-(IBAction)select:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property(nonatomic,strong)OverLayViewController *overlayViewController;
@property(nonatomic,assign)BOOL isChatComposer;
@property(nonatomic) BOOL isVideoModeOn;

@property(nonatomic) BOOL isVideoModeDetect;
@end
