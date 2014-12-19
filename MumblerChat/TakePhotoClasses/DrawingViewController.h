//
//  DrawingViewController.h
//  Mumbler
//
//  Created by Ransika De Silva on 12/24/13.
//  Copyright (c) 2013 Visni (Pvt) Ltd. All rights reserved.
//

#define IPAD_BUBBLE_HEIGHT 120

#import <UIKit/UIKit.h>
#import "SSPhotoCropperViewController.h"
//#import "MumblerUser.h"

@interface DrawingViewController : UIViewController<SSPhotoCropperDelegate,UIGestureRecognizerDelegate>

@property UIImage * cameraImage;
@property UIImage * capturedPhoto;
@property(nonatomic,strong)UIButton *cropPhotoButton;
@property(nonatomic) BOOL *isChatComposer;
@property(nonatomic) BOOL *isFromImageCropper;
//@property(nonatomic, retain) MumblerUser *friendMumblerUser;




-(void) upDateUndoButtonVisibility;

@end
