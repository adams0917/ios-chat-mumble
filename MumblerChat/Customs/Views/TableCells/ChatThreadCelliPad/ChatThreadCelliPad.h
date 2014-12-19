//
//  ChatThreadCelliPad.h
//  MumblerChat
//
//  Created by Tharaka Dushmantha on 4/8/14.
//  Copyright (c) 2014 AppDesignVault. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatThreadCelliPad : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UIImageView *imgChatIcon;
@property (strong, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) IBOutlet UIImageView *imgSendType;
@property (strong, nonatomic) IBOutlet UILabel *lblChatType;
@property (strong, nonatomic) IBOutlet UILabel *lblTimeCounter;
@end
