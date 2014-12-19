//
//  OverLayViewController.h
//  Mumbler
//
//  Created by Ransika De Silva on 10/25/13.
//  Copyright (c) 2013 Visni (Pvt) Ltd. All rights reserved.
//

#define IPAD_BUBBLE_HEIGHT 120

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SSPhotoCropperViewController.h"
//#import "MumblerUser.h"


@interface OverLayViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIGestureRecognizerDelegate,SSPhotoCropperDelegate>


@property(nonatomic,weak)IBOutlet UIView* overlayView;
@property(nonatomic,strong)UIImagePickerController*pickerReference;
@property(nonatomic,strong)UIButton*buttonCapture;
@property(nonatomic,strong)UIButton*buttonTwo;
@property(nonatomic,strong)UIButton*butonThree;
@property(nonatomic,assign)bool isFlipping;
@property(nonatomic,strong)UIButton* buttonFour;
@property(nonatomic,strong)UIButton*menuButton;
@property(nonatomic,strong)UILabel*labelCount;
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) NSString *videoPath2;
@property(nonatomic,strong)NSString* check;
@property(nonatomic,retain)UIImage*capturedPhoto;
@property(nonatomic,strong)UIImageView *editmodeView;
@property(nonatomic,strong)UIButton *editModeCloseButton;
@property(nonatomic,strong)UIButton *uploadImageButton;
@property(nonatomic,assign)BOOL isChatComposer;
@property(nonatomic,strong)UIButton *cropPhotoButton;
@property(nonatomic) BOOL isFromImageCropper;

// ruchira
@property(nonatomic) BOOL isRecordingOn;

-(void) upDateUndoButtonVisibility;
-(void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info;


@end
