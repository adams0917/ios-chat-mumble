//
//  ChatThreadCell.h
//  MumblerChat
//
//  Created by Tharaka Dushmantha on 3/20/14.
//  Copyright (c) 2014 AppDesignVault. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatThreadCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UIImageView *imgChatIcon;
@property (strong, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) IBOutlet UIImageView *imgSendType;
@property (strong, nonatomic) IBOutlet UILabel *lblChatType;
@property (strong, nonatomic) IBOutlet UILabel *lblTimeCounter;

@end
