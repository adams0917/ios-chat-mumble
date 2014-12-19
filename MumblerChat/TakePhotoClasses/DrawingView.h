//
//  DrawingView.h
//  Mumbler
//
//  Created by Ransika De Silva on 12/10/13.
//  Copyright (c) 2013 Visni (Pvt) Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingViewController.h"

@interface DrawingView : UIView

@property(nonatomic,strong) NSMutableArray * drawingPointsArray;
@property(nonatomic,strong) NSMutableArray * drawingColorsArray;
@property(nonatomic,strong) UIImage *image;
@property(nonatomic) BOOL isDrawingEnabled;

// stop drawing when user doing color selection
@property(nonatomic) BOOL touchOnPalette;

@property(nonatomic,strong) DrawingViewController * drawingViewController;
@property(nonatomic,strong) UIColor * drawingColor;
@property(nonatomic) BOOL undoFlagTurnedOn;
@property(nonatomic,strong)UIButton *getButton;

// crop the image taken from uiview to required size
@property(nonatomic) CGRect  cropRect;


-(void)drawImage:(UIImage *)image;
-(UIImage *)getDrawing;
-(void) enableDrawing;
-(void) disableDrawing;
-(void) undo;

@end
