//
//  MessageListCell.h
//  InsurancePlatform
//
//  Created by kangle1208 on 13-12-10.
//  Copyright (c) 2013年 CENTRIN. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "MessageView.h"


#define MSG_CELL_MIN_HEIGHT 70

#define MSG_VIEW_MIN_HEIGHT 32


@interface MessageListCell : UITableViewCell


@property (nonatomic, retain) IBOutlet UIImageView *frdIconView;

@property (nonatomic, retain) IBOutlet UIImageView *ownIconView;

@property (nonatomic, retain) IBOutlet UILabel *frdNameLabel;

@property (nonatomic, retain) IBOutlet UIImageView *msgBgView;

@property (nonatomic, retain) IBOutlet MessageView *messageView;


- (void)refreshForFrdMsg:(NSMutableArray *)message withSize:(CGSize)size;

- (void)refreshForOwnMsg:(NSMutableArray *)message withSize:(CGSize)size;


@end
