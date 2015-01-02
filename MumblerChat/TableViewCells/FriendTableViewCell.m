//
//  FriendTableViewCell.m
//  MumblerChat


#import "FriendTableViewCell.h"
#import "Constants.h"
#import "ASAppDelegate.h"
#import "UIImage+Helpers.h"

@implementation FriendTableViewCell
@synthesize profileImageView=_profileImageView;
@synthesize displayNameOne=_displayNameOne;
@synthesize displayNameTwo=_displayNameTwo;
@synthesize rowButton=_rowButton;
@synthesize mumblerUser=_mumblerUser;
@synthesize roundedImageView=_roundedImageView;
@synthesize profileImageRoundedImageView=_profileImageRoundedImageView;
@synthesize friendUser = _friendUser;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}





///////////////////////////////////////FRIENDS SCREEEN CHAT COMPOSER
- (IBAction)composeBtnSelected:(id)sender
{
    NSLog(@"picked composeBtnSelected ");
    
    NSLog(@"_mumblerFRIEND %@", _friendUser);
    
    ASAppDelegate *appDelegate = (ASAppDelegate *) UIApplication.sharedApplication.delegate;
    
    if(appDelegate.friendsToBeAddedToComposeTheMessageDictionary[_friendUser.userId] == nil) {
        NSLog(@"picked selectedUserId is there %@",_friendUser.userId);
        UIImage *imageIcon = [UIImage imageNamed:@"check_tick"];
        [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
        [appDelegate.friendsToBeAddedToComposeTheMessageDictionary setObject:_friendUser forKey:_friendUser.userId];
        [self.delegate friendCellWithUser:_friendUser changedState:YES];
    } else {
        UIImage *imageIcon = [UIImage imageNamed:@"uncheck"];
        [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
        [appDelegate.friendsToBeAddedToComposeTheMessageDictionary removeObjectForKey:_friendUser.userId];
        [self.delegate friendCellWithUser:_friendUser changedState:NO];
    }
    NSLog(@"picked friendsToBeAddedToComposeTheMessage %@",appDelegate.friendsToBeAddedToComposeTheMessageDictionary);
}

///////////////////////////////////////FRIENDS SCREEEN CHAT COMPOSER




////////////////////////////////////////SEARCH............
//Search add friend icon
-(IBAction)addSearchBtnSelected:(id)sender{
    NSString *selectedUserId =[NSString stringWithFormat:@"%@",[_mumblerUser valueForKey:@"mumblerUserId"]];
    
    NSLog(@"picked selectedUserId %@",selectedUserId);
    
    
    ASAppDelegate *appDelegate = (ASAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSLog(@"_mumblerUser %@",_mumblerUser);
    
    if([appDelegate.friendsToBeAddedDictionary objectForKey:selectedUserId] != nil){
        
        NSLog(@"picked selectedUserId is there %@",selectedUserId);
        
        UIImage *imageIcon = [UIImage imageNamed:@"add_before"];
        [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
        
        [appDelegate.friendsToBeAddedDictionary removeObjectForKey:selectedUserId];
        
        
        
    }else{
        NSLog(@"picked selectedUserId is not there %@",selectedUserId);
        
        UIImage *imageIcon = [UIImage imageNamed:@"add"];
        [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
        [appDelegate.friendsToBeAddedDictionary setObject:_mumblerUser forKey:selectedUserId];
        
    }
    NSLog(@"friendsToBeAddedDictionary %@",appDelegate.friendsToBeAddedDictionary);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addedFriendsLabelUpdate" object:appDelegate.friendsToBeAddedDictionary];
    
    
}
////////////////////////////////////////SEARCH OVER............






////////////////////////////////////////FACEBOOK............

//Search add friend icon
-(IBAction)addBtnSelectedForFBFriendsWithMumbler:(id)sender{
    
    NSString *selectedFBUserId =[NSString stringWithFormat:@"%@",[_mumblerUser valueForKey:@"id"]];
    
    NSLog(@"selectedFBUserId %@",selectedFBUserId);
    
    ASAppDelegate *appDelegate = (ASAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if (![appDelegate.addedFriendsInFaceBook containsObject:selectedFBUserId]) {
        //add
        NSLog(@"appDelegate.addedFriendsInFaceBook doesnt have the fb id");
        UIImage *imageIcon = [UIImage imageNamed:@"friends_after"];
        [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
        
        [appDelegate.addedFriendsInFaceBook addObject:selectedFBUserId];
        
    }else{
        
        //remove
        NSLog(@"appDelegate.addedFriendsInFaceBook has the fb id");
        UIImage *imageIcon = [UIImage imageNamed:@"friends_before"];
        [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
        [appDelegate.addedFriendsInFaceBook removeObject:selectedFBUserId];
        
    }
    
    NSLog(@"appDelegate.addedFriendsInFaceBook %@",appDelegate.addedFriendsInFaceBook);
}


////////////////////////////////////////FACEBOOK OVER............




//////////////////////////////////////////////CONTACTS....................
//Contacts add friend icon
-(IBAction)addBtnSelectedContactsFriendsWithMumbler:(id)sender{
    
    NSString *count = [NSUserDefaults.standardUserDefaults
                       valueForKey:FRIENDS_USING_MUMBLER_IN_CONTACTS];
    
    NSInteger countIntValue = [count intValue];
    
    UIImage *imageIcon = [UIImage imageNamed:@"add"];
    [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal ];
    
    NSString *selectedUserId =[NSString stringWithFormat:@"%@",[_mumblerUser valueForKey:@"mumblerUserId"]];
    
    NSLog(@"picked selectedUserId %@",selectedUserId);
    ASAppDelegate *appDelegate = (ASAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    
    if([appDelegate.friendsToBeAddedDictionary objectForKey:selectedUserId] != nil){
        
        NSLog(@"picked selectedUserId is there CONTACTS%@",selectedUserId);
        
        UIImage *imageIcon = [UIImage imageNamed:@"add_before"];
        [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
        
        [appDelegate.friendsToBeAddedDictionary removeObjectForKey:selectedUserId];
        
        
    }else{
        NSLog(@"picked selectedUserId is not there CONTACTS %@",selectedUserId);
        
        UIImage *imageIcon = [UIImage imageNamed:@"add"];
        [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
        [appDelegate.friendsToBeAddedDictionary setObject:_mumblerUser forKey:selectedUserId];
        
        
    }
    
    NSLog(@"friendsToBeAddedDictionary  CONTACTS %@",appDelegate.friendsToBeAddedDictionary);
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addedFriendsLabelUpdate" object:appDelegate.friendsToBeAddedDictionary];
    
    
    
    
}

//Contacts messege icon
-(IBAction)textBtnSelectedContactsInviteFriends:(id)sender{
    
    UIImage *imageIcon = [UIImage imageNamed:@"message_text_after"];
    [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal ];
    
    NSString *selectedContactNum =[NSString stringWithFormat:@"%@",[_mumblerUser valueForKey:@"phoneNumber"]];
    
    ASAppDelegate *appDelegate = (ASAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    
    ////////////
    
    if([appDelegate.inviteFriendsInContactsDictionary objectForKey:selectedContactNum] == nil){
        [appDelegate.inviteFriendsInContactsDictionary setObject:_mumblerUser forKey:selectedContactNum];
        
    }else{
        UIImage *imageIcon = [UIImage imageNamed:@"message_before"];
        [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
        
        [appDelegate.inviteFriendsInContactsDictionary removeObjectForKey:selectedContactNum];
    }
    
}
//////////////////////////////////////////CONTACTS OVER....................



-(void)profileImage:(NSString*) imageUrl{
    
    if (![imageUrl isKindOfClass:[NSNull class]] && imageUrl != nil) {
        
        ASAppDelegate * appDelegate= (ASAppDelegate *)[UIApplication sharedApplication].delegate;
        if ([appDelegate.profileImagesDictionary valueForKey:MUMBLER_USER_IMAGE_URL] != nil) {
            
            UIImage *image = [appDelegate.profileImagesDictionary valueForKey:MUMBLER_USER_IMAGE_URL];
            
            _profileImageRoundedImageView.imageOffset = 2.5;
            _profileImageRoundedImageView.image = image;
            _profileImageRoundedImageView.backgroundImage = [UIImage imageNamed:@"mumbler_profile_picture"];
            
            
        } else {
            
            NSURL *profileImageUrl = [NSURL URLWithString:imageUrl];
            
            [UIImage loadFromURL:profileImageUrl callback:^(UIImage *image) {
                
                if (image != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _profileImageRoundedImageView.imageOffset = 2.5;
                        _profileImageRoundedImageView.image = image;
                        
                        
                        _profileImageRoundedImageView.backgroundImage = [UIImage imageNamed:@"mumbler_profile_picture"];
                        
                        //[cell.thumbnailImageView addSubview:profileImageView];
                        
                        [appDelegate.profileImagesDictionary setObject:image forKey:MUMBLER_USER_IMAGE_URL];
                        
                    });
                } else {
                    
                    _profileImageRoundedImageView.imageOffset = 2.5;
                    _profileImageRoundedImageView.image = [UIImage imageNamed:@"mumbler_profile_picture"];;
                    
                }
            }];
        }
        
    } else {
        
        _profileImageRoundedImageView.imageOffset = 2.5;
        _profileImageRoundedImageView.image = [UIImage imageNamed:@"mumbler_profile_picture"];
        
    }
    
}


////////////Contacts Over



- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    
    self.profileImageView.layer.cornerRadius = 20;
    self.profileImageView.layer.masksToBounds = YES;
    
    UIImage *imageIcon;
    
    switch (_friendCellType) {
            
            //FACEBOOK START
            //Face Book Add Button
            
        case FriendCellTypeFBFriendsWithMumbler:
            imageIcon = [UIImage imageNamed:@"friends_before"];
            [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
            
            [self.rowButton addTarget:self action:@selector(addBtnSelectedForFBFriendsWithMumbler:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
            
        case FriendCellTypeFBInviteFriendsToMumbler:
            imageIcon = [UIImage imageNamed:@"message_before_chat"];
            [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
            break;
            
            
        case FriendCellTypeFBAddedFriendsWithMumbler:
            imageIcon = [UIImage imageNamed:@"friends_after"];
            [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
            [self.rowButton addTarget:self action:@selector(addBtnSelectedForFBFriendsWithMumbler:) forControlEvents:UIControlEventTouchUpInside];
            break;
            
            
            //////////FACEBOOK OVER
            
            
            
            
            
            //CONTACTS
            //contacts friens with mumbler..Ash
        case FriendCellTypeContactsFriendsWithMumbler:
            _displayNameOne.text = [_mumblerUser valueForKey:@"alias"];
            
            imageIcon = [UIImage imageNamed:@"add_before"];
            [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
            
            [self.rowButton addTarget:self action:@selector(addBtnSelectedContactsFriendsWithMumbler:) forControlEvents:UIControlEventTouchUpInside];
            
            
            
            break;
            
        case FriendCellTypeContactsInviteFriendsToMumbler:
            
            _displayNameOne.text = [_mumblerUser valueForKey:@"alias"];
            
            imageIcon = [UIImage imageNamed:@"message_before"];
            [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
            
            [self.rowButton addTarget:self action:@selector(textBtnSelectedContactsInviteFriends:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
            
        case FriendCellTypeContactsAdddedFriend:
            _displayNameOne.text = [_mumblerUser valueForKey:@"alias"];
            imageIcon = [UIImage imageNamed:@"add"];
            [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
            
            break;
            
            
        case FriendCellTypeContactsSelectedForSendATextToFriend:
            _displayNameOne.text = [_mumblerUser valueForKey:@"alias"];
            
            imageIcon = [UIImage imageNamed:@"message_text_after"];
            [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
            
            break;
            
            ///////////////CONTACTS
            
            
            
            /////////////////SEARCH
        case FriendCellTypeSearch_Not_Added_Friends:
            
            imageIcon = [UIImage imageNamed:@"add_before"];
            [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
            [self.rowButton addTarget:self action:@selector(addSearchBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            
            _displayNameOne.text=[NSString stringWithFormat:@"%@",[_mumblerUser valueForKey:@"alias"]];
            
            
            [self profileImage:[_mumblerUser valueForKey:@"profileImageUrl"]];
            
            if(![[_mumblerUser valueForKey:@"myStatus"]isEqual:[NSNull null]]){
                _displayNameTwo.text=[NSString stringWithFormat:@"%@",[_mumblerUser valueForKey:@"myStatus"]];
            }
            
            
            break;
            
        case FriendCellTypeSearch_Added_Friends:
            
            imageIcon = [UIImage imageNamed:@"add"];
            [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
            
            _displayNameOne.text=[NSString stringWithFormat:@"%@",[_mumblerUser valueForKey:@"alias"]];
            [self profileImage:[_mumblerUser valueForKey:@"profileImageUrl"]];
            
            if(![[_mumblerUser valueForKey:@"myStatus"]isEqual:[NSNull null]]){
                _displayNameTwo.text=[NSString stringWithFormat:@"%@",[_mumblerUser valueForKey:@"myStatus"]];
            }
            
            break;
            
            
            
            
            ////////////////////FRIEND SCREEEN
            
        case FriendCellTypeFriendsOffline:
            
            imageIcon = [UIImage imageNamed:@"offline"];
            [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
            break;
            
            
        case FriendCellTypeFriendsOnline:
            imageIcon = [UIImage imageNamed:@"online"];
            [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
            break;
            
            ////////////////////////FRIEND SCREEEN WITH CHAT COMPOSER
            
        case FriendCellTypeFriendsToBeSelectedToSendMsgs:
            
            imageIcon = [UIImage imageNamed:@"uncheck"];
            [self.rowButton setBackgroundImage:imageIcon forState:UIControlStateNormal];
            [self.rowButton addTarget:self action:@selector(composeBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            break;
            
            
            
        default:
            break;
    }
}

@end
