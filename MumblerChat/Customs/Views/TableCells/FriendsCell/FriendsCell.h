//
//  FriendsCell.h
//  MumblerChat
//
//  Created by Ransika De Silva on 2/21/14.
//  Copyright (c) 2014 AppDesignVault. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblContactName;
@property (strong, nonatomic) IBOutlet UIImageView *imgProfile;

@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong, nonatomic) IBOutlet UIImageView *imgStatus;
+ (NSString *)reuseIdentifier;
@end
