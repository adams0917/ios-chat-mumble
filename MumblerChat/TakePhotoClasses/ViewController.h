//
//  ViewController.h
//  Mumbler
//
//  Created by Ransika De Silva on 10/25/13.
//  Copyright (c) 2013 Visni (Pvt) Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import "OverLayViewController.h"
//#import "MumblerUser.h"

@interface ViewController : UIViewController

-(IBAction)select:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property(nonatomic,strong)OverLayViewController *overlayViewController;
@property(nonatomic,assign)BOOL isChatComposer;

@property(nonatomic) BOOL isVideoModeOn;

@end
 