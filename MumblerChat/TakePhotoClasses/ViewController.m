//
//  ViewController.m
//  screenSizes
//
//  Created by Ransika De Silva on 10/2/13.
//  Copyright (c) 2013 Ransika De Silva. All rights reserved.
//

#import "ViewController.h"
#import "OverLayViewController.h"
#import "ASAppDelegate.h"

#define SCREEN_WIDTH  1130
#define SCREEN_HEIGTH 580
#define CAMERA_TRANSFORM_X 1

#define CAMERA_TRANSFORM_Y 1.24299

@interface ViewController () {
    
}
@end

@implementation ViewController

@synthesize imageView;
@synthesize isChatComposer;
@synthesize isVideoModeOn;
//@synthesize chatComposerViewController;


- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
    // hide status bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }

    
    ASAppDelegate *appDelegate=(ASAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    //nimashi
    
   /* if([appDelegate.deviceType isEqualToString:@"iPhone"])
    {
        self.overlayViewController=[[OverLayViewController alloc] initWithNibName:@"OverLayViewController" bundle:nil];
        self.overlayViewController.chatComposerViewController = self.chatComposerViewController;
        [self.overlayViewController.buttonCapture setHidden:YES];
        
    }else{
        
        self.overlayViewController=[[OverLayViewController alloc] initWithNibName:@"OverLayViewController-iPAD" bundle:nil];
        self.overlayViewController.chatComposerViewController = self.chatComposerViewController;
        [self.overlayViewController.buttonCapture setHidden:YES];
        
    }*/
    
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    NSLog(@"did become active notification");
}

- (void)appDidEnterForeground:(NSNotification *)notification {
    NSLog(@"did enter foreground notification");
}


-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear viewcontroller");
    [super viewDidAppear:YES];
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
    imagePickerController.cameraDevice=UIImagePickerControllerCameraFlashModeAuto;
    imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, CAMERA_TRANSFORM_X, CAMERA_TRANSFORM_Y);
    
    self.overlayViewController.pickerReference=imagePickerController;
    self.overlayViewController.view=imagePickerController.cameraOverlayView;
    
    self.overlayViewController.isChatComposer=self.isChatComposer;
    
    if(isVideoModeOn){
        self.overlayViewController.isFlipping = YES;
    }
    
    [self presentViewController:self.overlayViewController animated:NO completion:nil];
    
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
-(IBAction)select:(id)sender
{
    
    NSLog(@"image picker");
    
}

-(UIImage*)unrotateImage:(UIImage*)image {
    CGSize size = image.size;
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width ,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage*)increaseQuality:(UIImage*)qualityImage{
    
    
    UIGraphicsBeginImageContext(CGSizeMake(1024,768));
    
    [qualityImage drawInRect: CGRectMake(0, 0, 1024, 768)];
    
    UIImage  *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return smallImage;
    
}

@end
