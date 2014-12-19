////
////  OverLayViewController.m
////  screenSizes
////
////  Created by Ransika De Silva on 10/2/13.
////  Copyright (c) 2013 Ransika De Silva. All rights reserved.
////
//
#import "OverLayViewController.h"
#import "ASAppDelegate.h"
#import "SettingsViewController.h"

#import "DrawingView.h"
#import "DrawingViewController.h"
#import "NSData+Base64.h"


#define SCREEN_WIDTH  1130
#define SCREEN_HEIGTH 580
#define CAMERA_TRANSFORM_X 2.0
//#define CAMERA_TRANSFORM_Y 1.12412 //use this is for iOS 3.x1.24299
#define CAMERA_TRANSFORM_Y 2.0

static inline double radians (double degrees) {return degrees * M_PI/180;}
//
@interface OverLayViewController (){
//    
    int remainingNumberOfSeconds;
    NSTimer *timer;
    AVCaptureSession *session;
    NSString *videoPath2;
    AVCaptureMovieFileOutput *movieFileOutput;
    
    // free hand drawing
    DrawingView *drawingView;
    UIView *drawingBoardView;
    UILabel * drawingButtonBackgroundLabel;
    UIButton * undoButton;
    UIImageView * colorPalatte;
}
@end
//
@implementation OverLayViewController
//

@synthesize pickerReference;
@synthesize overlayView;
@synthesize buttonCapture;
@synthesize buttonTwo;
@synthesize butonThree;
@synthesize isFlipping;
@synthesize buttonFour;
@synthesize menuButton;
@synthesize labelCount;
@synthesize session;
@synthesize videoPath2;
@synthesize check;
@synthesize capturedPhoto;
@synthesize editmodeView;
@synthesize editModeCloseButton;
@synthesize uploadImageButton;
@synthesize isChatComposer;
@synthesize isRecordingOn;
@synthesize cropPhotoButton;
@synthesize isFromImageCropper;

- (BOOL)prefersStatusBarHidden {
    return YES;
}

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
    
    // hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    NSLog(@"Viewdidload2 overlay");
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    NSLog(@"viewWillAppear2");
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
    remainingNumberOfSeconds=10;
    
    
}
- (void)appDidBecomeActive:(NSNotification *)notification {
    NSLog(@"did become active notification");
}

- (void)appDidEnterForeground:(NSNotification *)notification {
    NSLog(@"did enter foreground notification");
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear2");
    
    // hide status bar
    [UIApplication sharedApplication].statusBarHidden = YES;
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
    
   
    // screen dimensions
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    //float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
   
    
    self.pickerReference = [[UIImagePickerController alloc] init];
    self.pickerReference.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.pickerReference.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
    self.pickerReference.cameraFlashMode=UIImagePickerControllerCameraFlashModeAuto;
    self.pickerReference.allowsEditing=YES;
    self.pickerReference.wantsFullScreenLayout=YES;
    self.pickerReference.showsCameraControls=NO;
    
    // Device's screen size (ignoring rotation intentionally):
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    // iOS is going to calculate a size which constrains the 4:3 aspect ratio
    // to the screen size. We're basically mimicking that here to determine
    // what size the system will likely display the image at on screen.
    // NOTE: screenSize.width may seem odd in this calculation - but, remember,
    // the devices only take 4:3 images when they are oriented *sideways*.
    float cameraAspectRatio = 4.0 / 3.0;
    float imageWidth = floorf(screenSize.width * cameraAspectRatio);
    float scale = ceilf((screenSize.height / imageWidth) * 10.0) / 10.0;
    
    //self.ipc.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
    self.pickerReference.cameraViewTransform= CGAffineTransformScale( self.pickerReference.cameraViewTransform, scale,  scale);
    
    
        self.buttonCapture = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.buttonCapture setFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width/2 - 40), 470, 80, 80)];
        [self.buttonCapture addTarget:self action:@selector(capture:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonCapture setBackgroundImage:[UIImage imageNamed:@"capture_button.png"] forState:UIControlStateNormal];
        [self.buttonCapture setTintColor:[UIColor clearColor]];
        [self.view addSubview:self.buttonCapture];
        
        self.buttonTwo=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.buttonTwo setFrame:CGRectMake(250, 14, 60, 40)];
        [self.buttonTwo addTarget:self action:@selector(actionTwo:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonTwo setBackgroundImage:[UIImage imageNamed:@"camera_switch_mode.png"] forState:UIControlStateNormal];
        
        [self.view addSubview:self.buttonTwo];
        
        self.butonThree=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.butonThree setFrame:CGRectMake(10, 14, 33, 33)];
        [self.butonThree addTarget:self action:@selector(actionThree:) forControlEvents:UIControlEventTouchUpInside];
        [self.butonThree setBackgroundImage:[UIImage imageNamed:@"back_buttoncam.png"] forState:UIControlStateNormal];
        [self.butonThree setTintColor:[UIColor clearColor]];
        [self.view addSubview: self.butonThree];
        
        
        self.buttonFour=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.buttonFour setFrame:CGRectMake(10, 480, 33, 33)];
        [self.buttonFour addTarget:self action:@selector(actionFour:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonFour setBackgroundImage:[UIImage imageNamed:@"auto_flash.png"] forState:UIControlStateNormal];
        [self.buttonFour setTintColor:[UIColor clearColor]];
        [self.view addSubview: self.buttonFour];
        
        self.labelCount=[[UILabel alloc] init];
        [self.labelCount setFrame:CGRectMake(screenWidth/2 -5 , 484, 50, 50)];
        self.labelCount.textColor=[UIColor redColor];
        self.labelCount.backgroundColor=[UIColor clearColor];
        [self.view addSubview:self.labelCount];
        
        self.editmodeView=[[UIImageView alloc] initWithFrame:CGRectMake(0, -20, self.view.frame.size.width,self.view.frame.size.height+20)];
        [self.editmodeView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:self.editmodeView];
        
        self.editModeCloseButton=[[UIButton alloc] initWithFrame:CGRectMake(10, 10, 33, 33)];
        [self.editModeCloseButton setBackgroundImage:[UIImage imageNamed:@"editclose_icon.png"] forState:UIControlStateNormal];
        [self.editModeCloseButton addTarget:self action:@selector(editModeViewSetHidden:) forControlEvents:UIControlEventTouchUpInside];
        self.editModeCloseButton.tag=1;
        
        self.uploadImageButton =[[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 500, 40, 40)];
        [self.uploadImageButton setBackgroundImage:[UIImage imageNamed:@"EditModesend_icon.png"] forState:UIControlStateNormal];
        [self.uploadImageButton addTarget:self action:@selector(editModeViewSetHidden:) forControlEvents:UIControlEventTouchUpInside];
        self.uploadImageButton.tag=2;
        
        
        if(isFlipping)
        {
            self.isRecordingOn = NO;
            [self enableVideoMode];
        }
        
  
    
    ///////////////////////////////////////////////////EditModesend_icon.png
    [self presentViewController:self.pickerReference animated:YES completion:nil];
    [self timerFireMethod:nil];
    
    
}

- (void)timerFireMethod:(NSTimer*)theTimer {
    NSLog(@"timerFireMethod");
    //[theTimer invalidate];
    //key
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.view setHidden:NO];
        [self.pickerReference setCameraOverlayView:self.view];
    });
    
    
    
    
    
}

-(void) enableVideoMode
{
    self.isFlipping = YES;
    self.isRecordingOn = NO;
    self.pickerReference.mediaTypes =
    [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    self.pickerReference.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;
    self.pickerReference.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    [self.pickerReference setVideoMaximumDuration:10];
}

-(IBAction)actionFive:(id)sender{
    NSLog(@"CaptureVideo,actionFive");
    
    
    NSLog(@"makeMovieNow ..");
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*-(IBAction)singleTapcapture:(id)sender{
 
 NSLog(@"capture for normal press");
 
}*/



-(IBAction)singleTapcapture:(id)sender{
     NSLog(@"capture for normal press");

}

-(IBAction)capture:(id)sender{
 
 NSLog(@"capture for normal press--------");
 
 }

/*-(IBAction)capture:(id)sender{
    
    NSLog(@"capture--------");
    
    NSLog(@"takepicture-----");
    [imagePicker takePicture];
    
    imagePicker.delegate=self;
    
}*/






/*-(IBAction)capture:(id)sender{
    
    NSLog(@"capture for normal press");
    if(self.isFlipping)
    {
        if(!self.isRecordingOn)
        {
            // start capturing video
            NSLog(@"starting recording");
            // ruchira
            self.pickerReference.mediaTypes =
            [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
            [self.pickerReference startVideoCapture];
            self.isRecordingOn = YES;
            
            // start timer
            timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkCountdown) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
        }
        else
        {
            self.isRecordingOn = NO;
            NSLog(@"Stopping Recording");
            [self.pickerReference stopVideoCapture];
            // stop timer
            if(timer) {
                [timer invalidate];
            }
        }
        
    }
    else
    {
        //[self.pickerReference.all]
        [self.pickerReference takePicture];
    }
    self.pickerReference.delegate=self;
    
    
}*/

//-(IBAction)actionTwo:(id)sender{
-(IBAction)actionTwo:(id)sender{
    NSLog(@"actionTwo");
    
    
    //if(self.isFlipping){
        
        NSLog(@"isFlipping,Capturing");
    
        [UIView transitionWithView:self.pickerReference.view duration:1.0 options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionFlipFromLeft animations:^{
            
            if ([UIImagePickerController isCameraDeviceAvailable:[self.pickerReference cameraDevice]]) {
                
               
                if([self.pickerReference cameraCaptureMode] == UIImagePickerControllerCameraCaptureModePhoto)
                {
                   /* self.isFlipping = YES;
                    self.isRecordingOn = NO;
                    self.pickerReference.mediaTypes =
                    [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
                    self.pickerReference.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;
                    self.pickerReference.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
                    [self.pickerReference setVideoMaximumDuration:10];*/
                    if([self.pickerReference cameraDevice] == UIImagePickerControllerCameraDeviceRear)
                    {
                        self.pickerReference.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                    }
                    else if( [self.pickerReference cameraDevice] == UIImagePickerControllerCameraDeviceFront)
                    {
                        self.pickerReference.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                    }
                }
                else if([self.pickerReference cameraCaptureMode] == UIImagePickerControllerCameraCaptureModeVideo)
                {
                   /* self.isFlipping = NO;
                    self.pickerReference.mediaTypes =
                    [NSArray arrayWithObject:(NSString *)kUTTypeImage];
                    self.pickerReference.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
                    self.pickerReference.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
                    self.pickerReference.allowsEditing=YES;
                    self.pickerReference.wantsFullScreenLayout=YES;
                    self.pickerReference.showsCameraControls=NO;*/
                    if([self.pickerReference cameraDevice] == UIImagePickerControllerCameraDeviceRear)
                    {
                        self.pickerReference.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                    }
                    else if( [self.pickerReference cameraDevice] == UIImagePickerControllerCameraDeviceFront)
                    {
                        self.pickerReference.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                    }

                }
                self.pickerReference.delegate=self;//
            }
            
            
            
           
        } completion:NULL];
        
        
        
        
   // }
    
    
    
    
    
}


-(void)checkCountdown{
    
    NSLog(@"checkCountdown");
    
    
    if((remainingNumberOfSeconds >= 1))
    {
        remainingNumberOfSeconds-=1;
        NSLog(@"%i",remainingNumberOfSeconds);
        self.labelCount.text=[NSString stringWithFormat:@"%i",remainingNumberOfSeconds];
        
        
        
    }
    
    if (remainingNumberOfSeconds < 1) {
        
        [timer invalidate];
        
        [self.pickerReference stopVideoCapture];
        
        
        
        NSLog(@"hello");
    }
    
    
}

-(IBAction)actionThree:(id)sender{
    
    // invalidate the timer
    if(timer)
    {
        [timer invalidate];
    }
    
    NSLog(@"back");
    ASAppDelegate *appDelegate=(ASAppDelegate*)[UIApplication sharedApplication].delegate;
    
    
        
        if(!self.isChatComposer){
            
            //nimas
           /* ProfileViewController *profileViewController=[[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
            
            UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:profileViewController];
            
            appDelegate.navigationType = navcontroller;
          //  [self.presentedViewController presentModalViewController:navcontroller animated:YES];
            [self.presentedViewController presentViewController:navcontroller animated:YES completion:nil];*/
            
        } else {
            
            NSLog(@"chatcomps");
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:@"returning_from"];
            [userDefaults synchronize];
            
         //   [self.navigationController pushViewController:self.chatComposerViewController animated:YES];//            ChatComposerViewController *chatComposerViewController=[[ChatComposerViewController alloc] initWithNibName:@"ChatComposerViewController" bundle:nil];
//
            ///loadCahtComposer

            //[self performSegueWithIdentifier:@"loadChatComposer" sender:self];
            //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
           
            //AppDelegate *appDelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
//            appDelegate.navigationController = navcontroller;
//            
//            [navcontroller.navigationBar setHidden:YES];
//            [chatComposerViewController reInitializeTheChatComposerForActionTwo];
//            [self.presentedViewController presentModalViewController:navcontroller animated:YES];
            
        }
  
    
    
}



-(IBAction)actionFour:(id)sender{
    
    NSLog(@"actionFour");
    // on off camera
    if(([self.pickerReference cameraFlashMode] == UIImagePickerControllerCameraFlashModeOff) || ([self.pickerReference cameraFlashMode] == UIImagePickerControllerCameraFlashModeAuto))
    {
        self.pickerReference.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        [self.buttonFour setBackgroundImage:[UIImage imageNamed:@"flash_on_2.png"] forState:UIControlStateNormal];
    }
    else
    {
        self.pickerReference.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [self.buttonFour setBackgroundImage:[UIImage imageNamed:@"flash_off.png"] forState:UIControlStateNormal];
    }
   
}

-(IBAction)editModeViewSetHidden:(id)sender{
    
    NSLog(@"editModeViewSetHidden");
    
    [self.buttonTwo setEnabled:YES];
    [self.buttonTwo setHidden:NO];
    [self.butonThree setEnabled:YES];
    [self.butonThree setHidden:NO];
    [self.buttonFour setEnabled:YES];
    [self.buttonFour setHidden:NO];
    [self.buttonCapture setEnabled:YES];
    [self.buttonCapture setHidden:NO];
    
    if ([(UIButton*)sender tag]==1) {
        
        [self.editmodeView setHidden:YES];
        [self.editModeCloseButton setEnabled:NO];
        [self.editModeCloseButton setHidden:YES];
        [self.uploadImageButton setEnabled:NO];
        [self.uploadImageButton setHidden:YES];
        
        
    }else{
        
        NSLog(@"tag2");
        [self.uploadImageButton setEnabled:NO];
        [self.uploadImageButton setHidden:YES];
        
    }
    
    
}


 
-(void) imagePickerController: (UIImagePickerController *) picker
didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    
    
    NSLog(@"didFinishPickingMediaWithInfo2");
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];//image lies inside ths dictionary
        
        
        NSLog(@"UIImagePickerControllerOriginalImage%@",[info objectForKey:UIImagePickerControllerOriginalImage]);
        if (originalImage!=nil) {
            
            // display drawing pane
            imageToSave=[self unrotateImage:originalImage];
            imageToSave=[self increaseQuality:originalImage];
            
            self.capturedPhoto=imageToSave;
            
            DrawingViewController *drawingViewController = nil;
            if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
                drawingViewController = [[DrawingViewController alloc] initWithNibName:@"DrawingViewController-iPAD" bundle:nil];
            }
            else
            {
                 drawingViewController = [[DrawingViewController alloc] initWithNibName:@"DrawingViewController" bundle:nil];
            }
            // set the image
            drawingViewController.cameraImage = imageToSave;
            // keep track of chatcompser or profileview
            drawingViewController.isChatComposer = self.isChatComposer;
            
            
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:drawingViewController];
            [nc setNavigationBarHidden:YES];
        
            [self.presentedViewController presentViewController:nc animated:YES completion:nil];
            
        }
        
        
    }
    
    //
    //    // Handle a movie capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        
        NSString *moviePath = [[info objectForKey:
                                UIImagePickerControllerMediaURL] path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
           




            NSData * videoData = [NSData dataWithContentsOfFile:moviePath];
            NSString * base64String = [videoData base64EncodedString];
            
            NSUserDefaults *userDefaults= [NSUserDefaults standardUserDefaults];
            [userDefaults setValue:base64String forKey:@"msg_message"];
            [userDefaults synchronize];
            
            NSLog(@"moviePath%@",moviePath);
            [self navigateToPreviousController];
            
            
            
        }
        
    }
    
    
    
    NSLog(@"end");
}


-(void)showEditModeView:(UIImage*)capturedImage{
    NSLog(@"showEditModeView");
    
    [self.editmodeView setHidden:NO];
    [self.editmodeView setImage:self.capturedPhoto];
    [self.uploadImageButton setEnabled:YES];
    [self.uploadImageButton setHidden:NO];
    
    [self.buttonCapture setEnabled:NO];
    [self.buttonCapture setHidden:YES];
    [self.butonThree setEnabled:NO];
    [self.butonThree setHidden:YES];
    [self.buttonTwo setEnabled:NO];
    [self.buttonTwo setHidden:YES];
    [self.buttonFour setEnabled:NO];
    [self.buttonFour setHidden:YES];
    [self.editModeCloseButton setEnabled:YES];
    [self.editModeCloseButton setHidden:NO];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ChatAction1"])
    {

    }
    else if ([segue.identifier isEqualToString:@"showProfileView"])
    {

    }
    //loadTakePhoto
    else if ([segue.identifier isEqualToString:@"loadChatComposer"])
    {
        
    }
}


-(void)navigateToPreviousController{
    
    

        
    if (!self.isChatComposer) {
        
        //loadCahtComposer
         [self performSegueWithIdentifier:@"loadChatComposer" sender:self];

    }else{
        
        
        if (self.capturedPhoto !=nil) {
            
            self.capturedPhoto = [self generateThumbnailFromImage:self.capturedPhoto];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            NSData *imageData = UIImageJPEGRepresentation(self.capturedPhoto, 1.0);
            
            NSString *encodedString = [imageData base64Encoding];
            
            [userDefaults setObject:encodedString forKey:@"msg_message"];
            [userDefaults synchronize];
            
            
        }
     
    }
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

#pragma mark === drawing ===
-(IBAction)cancelDrawing:(id)sender
{
    [drawingBoardView removeFromSuperview];
}


-(IBAction)sendDrawing:(id)sender
{
    // get the image from drawingview
    
    UIImage * drawing = drawingView.getDrawing;
    self.capturedPhoto = drawing;
    [self navigateToPreviousController];
}

-(IBAction)enableDrawing:(id)sender
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
    NSLog(@"Palatte clicked overlay");
    
    if (recognizer.state==UIGestureRecognizerStateEnded)
    {
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
    }
    drawingView.touchOnPalette = NO;
}

#pragma mark ==== SSPhotoCropperDelegate Methods ====
- (void) photoCropper:(SSPhotoCropperViewController *)photoCropper
         didCropPhoto:(UIImage *)photo
{
    //self.croppedPhoto = photo;
    [self view];
    [self dismissViewControllerAnimated:YES completion:nil];
    self.capturedPhoto = photo;
    [self loadAndDisplayImage:photo];
    
    
    //self.capturedPhoto = photo;
    //[self navigateToPreviousController];
}

- (void) photoCropperDidCancel:(SSPhotoCropperViewController *)photoCropper
{
  
    [photoCropper dismissViewControllerAnimated:YES completion:nil];

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

    [self.presentedViewController presentViewController:nc animated:YES completion:nil];
    
    
}


-(IBAction)cropPhoto:(id)sender
{
    self.isFromImageCropper = YES;
    [self showPhotoCropper];
}


-(void)loadAndDisplayImage:(UIImage *)image
{
    NSLog(@"loading and displaying image overlay view");
    NSLog(@"self.view %f",self.view.frame.size.width);
    if(drawingBoardView)
    {
        [drawingBoardView removeFromSuperview];
    }
    drawingBoardView = [[UIView alloc] initWithFrame:CGRectMake(0, - 20, self.view.frame.size.width, self.view.frame.size.height+20)];
    drawingView = [[DrawingView alloc] initWithFrame:CGRectMake(0, 0, drawingBoardView.frame.size.width, drawingBoardView.frame.size.height)];
    [drawingView setBackgroundColor:[UIColor clearColor]];
    //[drawingView setOverLayViewController:self];
    
    [drawingBoardView addSubview:drawingView];
    
    
    UIButton * cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 39, 40, 35)];
    [cancelButton setImage:[UIImage imageNamed:@"editclose_icon.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelDrawing:) forControlEvents:UIControlEventTouchUpInside];
    [drawingBoardView addSubview:cancelButton];
    
    UIButton * sendDrawingButton = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] applicationFrame].size.width - 60, [[UIScreen mainScreen] applicationFrame].size.height - 50, 40, 40)];
    [sendDrawingButton setImage:[UIImage imageNamed:@"EditModesend_icon.png"] forState:UIControlStateNormal];
    [sendDrawingButton addTarget:self action:@selector(sendDrawing:) forControlEvents:UIControlEventTouchUpInside];
    [drawingBoardView addSubview:sendDrawingButton];
    
    
    UIButton * enableDrawingButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].applicationFrame.size.width -60, 36, 40, 40)];
    [enableDrawingButton setImage:[UIImage imageNamed:@"edit_icon.png"] forState:UIControlStateNormal];
    [enableDrawingButton addTarget:self action:@selector(enableDrawing:) forControlEvents:UIControlEventTouchUpInside];
    [drawingBoardView addSubview:enableDrawingButton];
    
    
    drawingButtonBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(enableDrawingButton.frame.origin.x+6, enableDrawingButton.frame.origin.y+7.0, 24, 23)];
    [drawingButtonBackgroundLabel setBackgroundColor:[UIColor clearColor] ];
    [drawingBoardView insertSubview:drawingButtonBackgroundLabel belowSubview:enableDrawingButton];
    
    // hidden
    // color palette image
    // undo button
    undoButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].applicationFrame.size.width -60, 90, 35, 35)];
    [undoButton setImage:[UIImage imageNamed:@"undo_button.png"] forState:UIControlStateNormal];
    [undoButton addTarget:self action:@selector(undoDrawing:) forControlEvents:UIControlEventTouchUpInside];
    [undoButton setHidden:YES];
    [drawingBoardView addSubview:undoButton];
    
    
    //cropPhotoButton
    self.cropPhotoButton =[[UIButton alloc] initWithFrame:CGRectMake(10, [[UIScreen mainScreen] applicationFrame].size.height - 45, 40, 40)];
    [self.cropPhotoButton setBackgroundImage:[UIImage imageNamed:@"crop_icon.png"] forState:UIControlStateNormal];
    [self.cropPhotoButton addTarget:self action:@selector(cropPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [drawingBoardView addSubview:self.cropPhotoButton];
    self.cropPhotoButton.tag=3;
    
    
    // color palatte, uiimageview
    colorPalatte = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].applicationFrame.size.width/2 - 150/2), 30, 150, 53)];
    [colorPalatte setImage:[UIImage imageNamed:@"color_scale.png"]];
    [colorPalatte setHidden:YES];
    // enable user interactions
    colorPalatte.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(ClickEventOnPalatte:)];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setDelegate:self];
    [colorPalatte addGestureRecognizer:tapRecognizer];
    
    [drawingBoardView addSubview:colorPalatte];
    
    [self.view addSubview:drawingBoardView];
    
    [drawingView drawImage:image];
    

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
