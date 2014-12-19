//
//  DrawingViewController.m
//  Mumbler
//
//  Created by Ransika De Silva on 12/24/13.
//  Copyright (c) 2013 Visni (Pvt) Ltd. All rights reserved.
//

#import "DrawingViewController.h"
#import "ViewController.h"
#import "DrawingView.h"
#import "ASAppDelegate.h"
#import "SettingsViewController.h"

@interface DrawingViewController ()


@end

@implementation DrawingViewController

@synthesize cameraImage;
@synthesize cropPhotoButton;
@synthesize isChatComposer;
@synthesize isFromImageCropper;

// free hand drawing
DrawingView *drawingView;
UIView *drawingBoardView;
UILabel * drawingButtonBackgroundLabel;
UIButton * undoButton;
UIImageView * colorPalatte;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewdidload----drawingview");
    // Do any additional setup after loading the view from its nib.
    [self loadAndDisplayImage:cameraImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadAndDisplayImage:(UIImage *)image
{
    
    if(drawingBoardView)
    {
        [drawingBoardView removeFromSuperview];
    }
    drawingBoardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+20)];
    // set background image
    drawingBoardView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"photo_cropper_bg.png"]];
    
    drawingView = [[DrawingView alloc] initWithFrame:CGRectMake(0, 0, drawingBoardView.frame.size.width, drawingBoardView.frame.size.height)];
    [drawingView setBackgroundColor:[UIColor clearColor]];
    [drawingView setDrawingViewController:self];
    
    [drawingBoardView addSubview:drawingView];
    
    // drawing board buttons
    // draw button
    // send button
    // cancel button
    
    
    UIButton * cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 23, 40, 35)];
    [cancelButton setImage:[UIImage imageNamed:@"editclose_icon.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelDrawing:) forControlEvents:UIControlEventTouchUpInside];
    [drawingBoardView addSubview:cancelButton];
    
    UIButton * sendDrawingButton = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] applicationFrame].size.width - 60, [[UIScreen mainScreen] applicationFrame].size.height - 50, 40, 40)];
    [sendDrawingButton setImage:[UIImage imageNamed:@"EditModesend_icon.png"] forState:UIControlStateNormal];
    [sendDrawingButton addTarget:self action:@selector(sendDrawing:) forControlEvents:UIControlEventTouchUpInside];
    [drawingBoardView addSubview:sendDrawingButton];
    
    
    UIButton * enableDrawingButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].applicationFrame.size.width -60, 20, 40, 40)];
    [enableDrawingButton setImage:[UIImage imageNamed:@"edit_icon.png"] forState:UIControlStateNormal];
    [enableDrawingButton addTarget:self action:@selector(enableDrawing:) forControlEvents:UIControlEventTouchUpInside];
    [drawingBoardView addSubview:enableDrawingButton];
    
    
    drawingButtonBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(enableDrawingButton.frame.origin.x+6, enableDrawingButton.frame.origin.y+7.0, 24, 23)];
    [drawingButtonBackgroundLabel setBackgroundColor:[UIColor clearColor] ];
    [drawingBoardView insertSubview:drawingButtonBackgroundLabel belowSubview:enableDrawingButton];
    
    // hidden
    // color palette image
    // undo button
    undoButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].applicationFrame.size.width -60, 74, 35, 35)];
    [undoButton setImage:[UIImage imageNamed:@"undo_button.png"] forState:UIControlStateNormal];
    [undoButton addTarget:self action:@selector(undoDrawing:) forControlEvents:UIControlEventTouchUpInside];
    [undoButton setHidden:YES];
    [drawingBoardView addSubview:undoButton];
    
    
    //cropPhotoButton
    self.cropPhotoButton =[[UIButton alloc] initWithFrame:CGRectMake(10, [[UIScreen mainScreen] applicationFrame].size.height - 45, 40, 40)];
    [self.cropPhotoButton setBackgroundImage:[UIImage imageNamed:@"crop_icon.png"] forState:UIControlStateNormal];
    [self.cropPhotoButton addTarget:self action:@selector(cropPhoto:) forControlEvents:UIControlEventTouchUpInside];
    //[drawingBoardView addSubview:self.cropPhotoButton];
    //self.cropPhotoButton.tag=3;
    
    // If the photo is a picture message
    // hide crop button
    if(self.isChatComposer)
    {
        self.cropPhotoButton.hidden = YES;
    }
    
    
    // color palatte, uiimageview
    colorPalatte = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].applicationFrame.size.width/2 - 150/2), 14, 150, 53)];
    [colorPalatte setImage:[UIImage imageNamed:@"color_scale.png"]];
    [colorPalatte setHidden:YES];
    // enable user interactions
    colorPalatte.userInteractionEnabled = YES;
    
    /*UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(ClickEventOnPalatte:)];*/
    
    // dragdetection
    UILongPressGestureRecognizer *detectDrag = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    detectDrag.numberOfTapsRequired=0;
    [detectDrag setDelegate:self];
    detectDrag.minimumPressDuration=0.001;
    [colorPalatte addGestureRecognizer:detectDrag];
    //[clickLeft requireGestureRecognizerToFail:mouseDrag];
    //[tapRecognizer setNumberOfTouchesRequired:1];
    //[tapRecognizer setDelegate:self];
    //[colorPalatte addGestureRecognizer:tapRecognizer];
    
    [drawingBoardView addSubview:colorPalatte];
    
    [self.view addSubview:drawingBoardView];
    
    [drawingView drawImage:image];
    
    
}


#pragma mark === drawing ===
-(IBAction)cancelDrawing:(id)sender
{
    NSLog(@"cancel drawing");
    [self dismissViewControllerAnimated:YES completion:nil];
    /**
     
     if([appDelegate.deviceType isEqualToString:@"iPhone"])
     {
     self.overlayViewController=[[OverLayViewController alloc] initWithNibName:@"OverLayViewController" bundle:nil];
     [self.overlayViewController.buttonCapture setHidden:YES];
     
     }else{
     
     self.overlayViewController=[[OverLayViewController alloc] initWithNibName:@"OverLayViewController-iPAD" bundle:nil];
     [self.overlayViewController.buttonCapture setHidden:YES];
     
     }
     **/
    //
    //    ViewController * viewController;
    //    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
    //        viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    //    }
    //    else
    //    {
    //        viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    //    }
    //
    //    viewController.isVideoModeOn = NO;
    //    viewController.isChatComposer = self.isChatComposer;
    //
    //    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewController];
    //    [nc setNavigationBarHidden:YES];
    //
    
    //  [self presentModalViewController:nc animated:YES];
    //[self.parentViewController dismissModalViewControllerAnimated:YES];
    
}


-(IBAction)sendDrawing:(id)sender
{
    NSLog(@"Sending Drawing");
    // get the image from drawingview
    UIImage * drawing = drawingView.getDrawing;
    self.capturedPhoto = drawing;
    
    if (self.capturedPhoto != nil) {
        NSLog(@"captured photo not nil");
    } else {
        
        NSLog(@"captured photo nil");
    }
    
    self.capturedPhoto = [self generateThumbnailFromImage:self.capturedPhoto];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSData *imageData = UIImageJPEGRepresentation(self.capturedPhoto, 1.0);
    
    NSString *encodedString = [imageData base64Encoding];
    
    [userDefaults setObject:encodedString forKey:@"msg_message"];
    
    [userDefaults setObject:@"shareImage" forKey:@"returning_from"];
    
    [userDefaults synchronize];
    
    [self navigateToPreviousController];
}

-(IBAction) enableDrawing:(id)sender
{
    if(!drawingView.isDrawingEnabled)
    {
        //UIButton *enableDrawingButton = (UIButton *)sender;
        [drawingButtonBackgroundLabel setBackgroundColor:[UIColor redColor]];
        [drawingView enableDrawing];
        [drawingView setDrawingColor:[UIColor redColor]];
        [colorPalatte setHidden:NO];
        
        // display undo only if something visible on the screen
        if([drawingView.drawingPointsArray count] > 0)
        {
            [undoButton setHidden:NO];
        }
    }
    else
    {
        [drawingButtonBackgroundLabel setBackgroundColor:[UIColor clearColor]];
        [drawingView disableDrawing];
        [undoButton setHidden:YES];
        [colorPalatte setHidden:YES];
    }
}

-(IBAction)undoDrawing:(id)sender
{
    [drawingView undo];
}

-(void) upDateUndoButtonVisibility
{
    if([drawingView.drawingPointsArray count] > 0 && (drawingView.isDrawingEnabled == YES))
    {
        [undoButton setHidden:NO];
        
    }
    else
    {
        [undoButton setHidden:YES];
    }
}

-(IBAction)ClickEventOnPalatte:(UITapGestureRecognizer *) recognizer
{
    drawingView.touchOnPalette = YES;
    NSLog(@"Palatte clicked drawing viewcontroller");
    
    //if (recognizer.state==UIGestureRecognizerStateEnded)
    //{
    CGPoint point = [recognizer locationInView:drawingBoardView];
    
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(context, -point.x, -point.y);
    [drawingBoardView.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    [drawingButtonBackgroundLabel setBackgroundColor:color];
    drawingView.drawingColor = color;
    //}
    drawingView.touchOnPalette = NO;
}

-(IBAction)handleDrag:(UILongPressGestureRecognizer*) recognizer
{
    drawingView.touchOnPalette = YES;
    NSLog(@"handle drag Palatte clicked----drawingviewcontroller");
    
    //if (recognizer.state==UIGestureRecognizerStateEnded)
    //{
    CGPoint point = [recognizer locationInView:drawingBoardView];
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextTranslateCTM(context, -point.x, -point.y);
    [drawingBoardView.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    [drawingButtonBackgroundLabel setBackgroundColor:color];
    drawingView.drawingColor = color;
    //}
    drawingView.touchOnPalette = NO;
    NSLog(@"color-----%@",color);
    
    
    
}

#pragma mark ==== SSPhotoCropperDelegate Methods ====
- (void) photoCropper:(SSPhotoCropperViewController *)photoCropper
         didCropPhoto:(UIImage *)photo
{
    //self.croppedPhoto = photo;
    self.capturedPhoto = photo;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self loadAndDisplayImage:photo];
    
    
    //self.capturedPhoto = photo;
    //[self navigateToPreviousController];
}

- (void) photoCropperDidCancel:(SSPhotoCropperViewController *)photoCropper
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void) showPhotoCropper
{
    SSPhotoCropperViewController *photoCropper =
    [[SSPhotoCropperViewController alloc] initWithPhoto:[drawingView getDrawing]
                                               delegate:self
                                                 uiMode:SSPCUIModePresentedAsModalViewController
                                        showsInfoButton:YES];
    [photoCropper setMinZoomScale:0.25f];
    [photoCropper setMaxZoomScale:2.50f];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:photoCropper];
    
    [self presentViewController:nc animated:YES completion:nil];
}


-(IBAction)cropPhoto:(id)sender
{
    NSLog(@"crop Photo");
    self.isFromImageCropper = YES;
    [self showPhotoCropper];
}



#pragma mark === image uploading ===
-(void)navigateToPreviousController{
    NSLog(@"navigateToPreviousController drawingviewcontroller");
    
    ASAppDelegate *appDelegate=(ASAppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (!self.isChatComposer) {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        SettingsViewController *profileViewController = [sb instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        
        if (self.capturedPhoto!=nil) {
            
            self.capturedPhoto = [self generateThumbnailFromImage:self.capturedPhoto];
            //nimas
            /*profileViewController.imgCaptured=self.capturedPhoto;*/
            
        }
        
        
        //nimashi
       /* UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:profileViewController];
        
        appDelegate.navigationType = navcontroller;
        
        [self presentViewController:navcontroller animated:YES completion:nil];*/
        
        
        
    }else{
        
        
        
        NSLog(@"navi back");
        //kanishka
       // UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        
        
        self.capturedPhoto = [self generateThumbnailFromImage:self.capturedPhoto];
        
//        UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:chatComposerViewController];
//        appDelegate.navigationType = navcontroller;
        
        
        
        
    }
    
    
}


-(UIImage *)generateThumbnailFromImage:(UIImage *)image
{
    NSLog(@"Starting generating thumbnail from image");
    
    float y = (image.size.height/2) - IPAD_BUBBLE_HEIGHT/2;
    CGRect cropRect = CGRectMake(0,  y, image.size.width, IPAD_BUBBLE_HEIGHT);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *newImage   = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    // get image size
    NSData * calculateSize = UIImagePNGRepresentation(newImage);
    NSLog(@"Cropped Image size k %f",[calculateSize length]/1024.0f);
    NSLog(@"Ending generating thumbnail from image");
    return newImage;
}
@end
