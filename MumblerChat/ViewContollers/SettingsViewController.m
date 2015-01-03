//
//  SettingsViewController.m
//  MumblerChat
//


#import "SettingsViewController.h"
#import "Constants.h"
#import "TakePhotosViewController.h"
#import "RoundedImageView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "TakePhotosViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "Constants.h"
#import "FacebookSDK/FacebookSDK.h"
#import "AFHTTPRequestOperationManager.h"
#import "SVProgressHUD.h"
#import "XMPPFramework.h"
#import "ASAppDelegate.h"
#import "XMPPvCardTemp.h"
#import "NSData+Base64.h"
#import "UserDao.h"
#import "User.h"
#import "ASAppDelegate.h"
#import "SBJson.h"
#import "ChatMessageDao.h"

@interface SettingsViewController ()
{
    UIImage *profileImage;
    NSString *alerts;
    NSString *whoCanMsgMe;
    NSString *saveOutgoingMedia;
    User *userObject;
}

@end

@implementation SettingsViewController

@synthesize statusTextField;
@synthesize nameLabel;
@synthesize mobileLabel;
@synthesize usernameLabel;
@synthesize settingDictionary;
@synthesize profileDictionary;
@synthesize whoCanMsgMeButton;
@synthesize actionSheetType;
@synthesize slider;
@synthesize sliderView;
@synthesize changePhotoPopUpView;
@synthesize popOverController;
@synthesize profileButton;
@synthesize loginView;
@synthesize switchAlert;
@synthesize switchSaveMedia;

- (void)updateSliderPopoverText
{
    self.slider.popover.textLabel.text = [NSString stringWithFormat:@"%.0f", self.slider.value];
}

////////////////////Slide over

- (IBAction)didTapOnCameraOption:(id)sender {
    
    changePhotoPopUpView.hidden=true;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)didTapGalleryOption:(id)sender {
    changePhotoPopUpView.hidden=true;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        self.popOverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        self.popOverController.delegate = self;
        [self.popOverController  presentPopoverFromRect:((UIButton *)sender).bounds inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }else{
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
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

-(UIImage*)increaseQuality:(UIImage*)qualityImage
{
    UIGraphicsBeginImageContext(CGSizeMake(1024,768));
    [qualityImage drawInRect: CGRectMake(0, 0, 1024, 768)];
    UIImage  *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return smallImage;
    
}

-(void) imagePickerController: (UIImagePickerController *) picker
didFinishPickingMediaWithInfo: (NSDictionary *) info{
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        originalImage =[info objectForKey:UIImagePickerControllerOriginalImage];
        
        editedImage =[info objectForKey:UIImagePickerControllerEditedImage];
        
        if(editedImage != nil){
            imageToSave=[self unrotateImage:editedImage];
            imageToSave=[self increaseQuality:editedImage];
            
            profileImage=imageToSave;
            [profileButton setBackgroundImage:imageToSave forState:UIControlStateNormal];
            self.profileButton.layer.cornerRadius = 20.0;
            self.profileButton.layer.masksToBounds = YES;
        }
    }
    
    
    if (originalImage) {
        profileImage=originalImage;
        [picker dismissViewControllerAnimated:YES completion:nil];
        [profileButton setBackgroundImage:originalImage forState:UIControlStateNormal];
        self.profileButton.layer.cornerRadius = 20.0;
        self.profileButton.layer.masksToBounds = YES;
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)didTapOnRemoveProfileImageButton:(id)sender {
    NSLog(@"didTapOnRemoveProfileImageButton");
}


- (IBAction)didTapOnChangePhotoButton:(id)sender {
    NSLog(@"didTapOnChangePhotoButton");
    changePhotoPopUpView.hidden=false;
    
}
- (IBAction)didTapOnClearHistoryButton:(id)sender {
    actionSheetType=@"clear_history";
    
    NSLog(@"didTapOnClearHistoryButton---");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UIActionSheet* actionSheet=[[UIActionSheet alloc] init];
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        [actionSheet addButtonWithTitle:@"YES"];
        [actionSheet addButtonWithTitle:@"NO"];
        actionSheet.delegate=self;
        [actionSheet showFromRect:CGRectMake(100, 100, 320, 300) inView:self.view animated:YES];
        
    }else{
        UIActionSheet* actionSheet=[[UIActionSheet alloc] init];
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet addButtonWithTitle:@"YES"];
        [actionSheet addButtonWithTitle:@"NO"];
        actionSheet.delegate=self;
        [actionSheet showFromRect:CGRectMake(220, 250, 320, 300) inView:self.view animated:YES];
        
    }
    
}


- (IBAction)didTapOnFaceBookButton:(id)sender {
    
    //[FBSession.activeSession closeAndClearTokenInformation];
    //[FBSession.activeSession close];
    //[FBSession setActiveSession:nil];
}

- (IBAction)didTapOnMumblerChatLogoutButton:(id)sender {
    
    actionSheetType=@"mumbler_chat_logout";
    NSLog(@"didTapOnMumblerChatLogoutButton");
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Logout"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    
    //User logot from the app
    /*[NSUserDefaults.standardUserDefaults setObject:USER_LOG_OUT_YES forKey:USER_LOG_OUT];
     [NSUserDefaults.standardUserDefaults synchronize];*/
}


- (IBAction)settingsBackButtonPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)switchAlertValueChanged:(UISwitch *)theSwitch
{
    BOOL switchAlertOn = theSwitch.on;
    if(switchAlertOn){
        NSLog(@"switchAlertOn");
        alerts=@"1";
    }else{
        NSLog(@"switchAlertOff");
        alerts=@"0";
    }
}

- (void)switchSaveMediaValueChanged:(UISwitch *)theSwitch
{
    BOOL switchSaveMediaOn = theSwitch.on;
    if(switchSaveMediaOn){
        NSLog(@"switchSaveMediaOn");
        saveOutgoingMedia=@"1";
    }else{
        NSLog(@"switchSaveMediaOff");
        saveOutgoingMedia=@"0";
    }
}

- (IBAction)didTapOnWhoCanMsgMeButton:(id)sender {
    
    NSLog(@"didTapOnWhoCanMsgMeButton---");
    
    actionSheetType=@"who_can_msg_me";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UIActionSheet* actionSheet=[[UIActionSheet alloc] init];
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        [actionSheet addButtonWithTitle:@"EVERYONE"];
        [actionSheet addButtonWithTitle:@"FRIENDS"];
        actionSheet.delegate=self;
        [actionSheet showFromRect:CGRectMake(100, 100, 320, 300) inView:self.view animated:YES];
        
    }else{
        UIActionSheet* actionSheet=[[UIActionSheet alloc] init];
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet addButtonWithTitle:@"EVERYONE"];
        [actionSheet addButtonWithTitle:@"FRIENDS"];
        actionSheet.delegate=self;
        [actionSheet showFromRect:CGRectMake(220, 250, 320, 300) inView:self.view animated:YES];
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"clickedButtonAtIndex");
    
    if([actionSheetType isEqualToString:@"mumbler_chat_logout"]){
        
        ///////////////Log out
        
        if (buttonIndex==0){
            
            NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
            NSDictionary * keys = [userDefaults dictionaryRepresentation];
            
            for (id key in keys) {
                //NSLog(@"keys-%@",key);
                [userDefaults removeObjectForKey:key];
            }
            
            [userDefaults synchronize];
            [[[self appDelegate] xmppStream ]disconnect];
            [[[self appDelegate] xmppvCardTempModule] removeDelegate:self];
            [self.navigationController popToRootViewControllerAnimated:YES];
//            [self performSegueWithIdentifier:@"backToHome" sender:self];
        } else {
            NSLog(@"LOGOT CANCELED");
        }
        
        
        /////////////////LOG OUT
        
    }
    
    //////////////Clear History//28
    else if([actionSheetType isEqualToString:@"clear_history"]){
        //serverCall
        if (buttonIndex==0) {
            ChatMessageDao *cmd = [[ChatMessageDao alloc] init];
            [cmd clearHistory];
            NSLog(@"History cleared");
        } else {
            NSLog(@"History not cleared");
        }
    } else {
        
        // NSString *whoCanSendStr = @"";
        if(buttonIndex==0){
            [self.whoCanMsgMeButton setTitle:@"EVERYONE" forState:UIControlStateNormal];
            whoCanMsgMe=@"1";
            //[self btnUpdateMySettings:actionSheet];
            
        }
        else if (buttonIndex==1) {
            [self.whoCanMsgMeButton setTitle:@"FRIENDS" forState:UIControlStateNormal];
            // [self btnUpdateMySettings:actionSheet];
            whoCanMsgMe=@"2";
        }
    }
}


- (void)loadUserProfileWithSettings{
    
    
    //    NSUserDefaults *userDefaults=NSUserDefaults.standardUserDefaults;
    //    NSData *userSettingData = [userDefaults valueForKey:MUMBLER_CHAT_SETTINGS];
    //    self.settingDictionary =  [NSKeyedUnarchiver unarchiveObjectWithData:userSettingData];
    //
    //    NSData *profileSettingData = [userDefaults valueForKey:MUMBLER_CHAT_USER_PROFILE];
    //    self.profileDictionary =  [NSKeyedUnarchiver unarchiveObjectWithData:profileSettingData];
    //
    //
    //    NSLog(@"settingDictionary %@ ", settingDictionary);
    //
    //    NSLog(@"profileDictionary %@ ", profileDictionary);
    
    
    [[UISwitch appearance] setOnTintColor:[UIColor orangeColor]];
    
    [[UISwitch appearance] setTintColor:[UIColor grayColor]];
    
    [[UISwitch appearance] setThumbTintColor:[UIColor whiteColor]];
    [switchAlert addTarget:self action:@selector(switchAlertValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [[UISwitch appearance] setOnTintColor:[UIColor orangeColor]];
    
    [[UISwitch appearance] setTintColor:[UIColor grayColor]];
    
    [[UISwitch appearance] setThumbTintColor:[UIColor whiteColor]];
    [switchSaveMedia addTarget:self action:@selector(switchSaveMediaValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    
    int currentValue = [[self.settingDictionary valueForKey:@"chatTimeLimit"] integerValue]/1000;
    
    
    NSLog(@"currentValue %@ ", [self.settingDictionary valueForKey:@"chatTimeLimit"]);
    
    NSLog(@"currentValue %i ", currentValue);
    
    if (currentValue == 0) {
        currentValue = 21;
    }
    //[self.sliderView setCurrentValue:currentValue];
    
    ////////////USER PROFILE
}

-(IBAction)swipeLeft:(id)sender{
    
    NSLog(@"swipeLeft----");
    
    
}
-(void)updateMyProfile{
    userObject.userProfileStatus=self.statusTextField.text;
    userObject.alertsStatus=alerts;
    userObject.saveOutgoingMediaStatus=saveOutgoingMedia;
    userObject.whoCanSendMeMessages=whoCanMsgMe;
    
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    NSError *error = nil;
    if([managedObjectContext save:&error] ) {
        NSLog(@"User updateUserOnlineStatus---------------- change");
    } else {
        
        NSLog(@"User updateUserOnlineStatus--------- not change");
    }
    
    
    
    //sending status update
    XMPPPresence *presence = [XMPPPresence presence];
    if(userObject.userProfileStatus!=nil){
        NSXMLElement *status = [NSXMLElement elementWithName:@"status" stringValue:userObject.userProfileStatus];
        [presence addChild:status];
        
    }else{
        NSXMLElement *status = [NSXMLElement elementWithName:@"status" stringValue:@"Available"];
        [presence addChild:status];
        
    }
    [[appDelegate xmppStream] sendElement:presence];
    
    
}
-(void)updateVcardDetails{
    
    
    
    XMPPvCardCoreDataStorage *xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    XMPPvCardTempModule *xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^{
        
        [xmppvCardTempModule  activate:[[self appDelegate] xmppStream]];
        
        
        XMPPvCardTemp *myvCardTemp = [xmppvCardTempModule myvCardTemp];
        
        NSString *username = [NSUserDefaults.standardUserDefaults
                              valueForKey:USERNAME];
        
        NSData *profileImageData = UIImageJPEGRepresentation(profileImage, 1.0);
        NSString *encodedString = [profileImageData base64Encoding];
        
        if (myvCardTemp==nil) {
            
            
            NSLog(@"Vcard id nill tsttstststts");
            NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
            XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
            [newvCardTemp setNickname:username];
            
            //[newvCardTemp setPhoto:profileImageData];
            
            //[newvCardTemp setPhoto:[NSData dataFromBase64String:[self encodeToBase64String:profileImage]]];
            [newvCardTemp setPhoto:[NSData dataFromBase64String:encodedString]];
            
            
            
            [xmppvCardTempModule updateMyvCardTemp:newvCardTemp];
            
            
        }else{
            NSLog(@"Vcard is not null middle name== %@",myvCardTemp.middleName);
            
            
            [myvCardTemp setNickname:usernameLabel.text];
            [myvCardTemp setFormattedName:usernameLabel.text];
            
            NSDictionary *o2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                alerts, @"alerts",
                                saveOutgoingMedia, @"save_out_going_media",
                                @"13", @"global_timer",
                                whoCanMsgMe, @"who_can_message",
                                nil];
            NSLog(@"phone numbers to server -=== %@",[o2 JSONRepresentation]);
            
            [myvCardTemp setMiddleName:[o2 JSONRepresentation]];
            [myvCardTemp setPhoto:profileImageData];
            
            //[myvCardTemp setPhoto:[NSData dataFromBase64String:encodedString]];
            
            [xmppvCardTempModule updateMyvCardTemp:myvCardTemp];
            
        }
        
    });
    
    
}


-(IBAction)swipeRight:(id)sender{
    
    NSLog(@"swipeRight----");
    [self.navigationController popViewControllerAnimated:YES];
    
    NSLog(@"swipeRight------time--%i",[self.sliderView currentValue]);
    if([self.whoCanMsgMeButton.titleLabel.text isEqualToString:@"EVERYONE"]){
        whoCanMsgMe=@"1";
    }else{
        whoCanMsgMe=@"2";
        
    }
    [self updateMyProfile];
    [self updateVcardDetails];
    
    
    
    if (([[self.settingDictionary valueForKey:@"chatTimeLimit"] intValue]/1000)!=[self.sliderView currentValue]) {
        NSLog(@"not equal------");
        
        /*[self performSelectorInBackground:@selector(btnUpdateMySettings:) withObject:self];*/
        
        
    }
    
}

- (ASAppDelegate *)appDelegate
{
    return (ASAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void) viewDidAppear:(BOOL)animated
{
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMethodStreamDidAthenticate) name:kXMPPStreamDidAuthenticate object:nil];
    
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMPPStreamDidAuthenticate object:nil];
    
    
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


-(IBAction) btnUpdateMySettings:(id)sender
{
    NSLog(@"btnUpdateMySettings-----------");
    
    self.settingDictionary=[[NSMutableDictionary alloc] init];
    
    if (!slider.exclusiveTouch) {
        [self updateSliderPopoverText];
        
    }
    
    NSLog(@"slider----------%i",[self.sliderView currentValue]);
    
    
    NSMutableString *jsonString  = [[NSMutableString alloc] init];
    [jsonString appendFormat:@"{"];
    NSInteger timerValue = [[NSNumber numberWithFloat:[self.sliderView currentValue] * 1000] integerValue];
    [jsonString appendFormat:@"\"chat_time_limit\":\"%@\",", [NSString stringWithFormat:@"%li", timerValue]];
    NSString *saveOutgoingMediaStr = @"";
    if (self.switchSaveMedia.on)
    {
        saveOutgoingMediaStr = @"TRUE";
    } else
    {
        saveOutgoingMediaStr = @"FALSE";
    }
    NSString *alertStr = @"";
    if (self.switchAlert.on) {
        alertStr = @"TRUE";
    } else
    {
        alertStr = @"FALSE";
    }
    
    NSLog(@"alert %@, %@ ", alertStr, saveOutgoingMediaStr);
    
    [jsonString appendFormat:@"\"save_outgoing_media\":\"%@\",", saveOutgoingMediaStr];
    
    [jsonString appendFormat:@"\"alert\":\"%@\",",alertStr];
    
    [jsonString appendFormat:@"\"who_can_send_me_message\":\"%@\"", self.whoCanMsgMeButton.titleLabel.text];
    
    [jsonString appendFormat:@"}"];
    
    NSLog(@"update my settings %@ ", jsonString);
    
    /////////////////
    
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"json",nil];
    
    
    NSArray *values = [[NSArray alloc] initWithObjects:jsonString,nil];
    NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    NSString * serverCallRequest = [NSString stringWithFormat:@"%@%@", BASE_URL, @"mumblerUser/updateMySetting.htm"];
    
    [manager GET:serverCallRequest parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        NSLog(@"Update Sucesss :%@",responseObject);
        NSString *status = [responseObject valueForKey:@"status"];
        
        if([status isEqualToString:@"success"])
        {
            NSLog(@"Update Sucesss %@",responseObject);
            
            NSLog(@"SETTINGS UPDATE SUCCESS");
            
            NSString *alertStr = @"";
            if (self.switchAlert.on) {
                alertStr = @"1";
            } else {
                
                alertStr = @"0";
                
            }
            
            NSString *saveOutgoingMediaStr = @"";
            if (self.switchSaveMedia.on) {
                saveOutgoingMediaStr = @"1";
            } else {
                
                saveOutgoingMediaStr = @"0";
                
            }
            
            NSLog(@"testing-----%@",settingDictionary);
            [self.settingDictionary setValue:whoCanMsgMeButton.titleLabel.text forKey:@"whoCanSendMeMessage"];
            [self.settingDictionary setValue:alertStr forKey:@"alert"];
            [self.settingDictionary setValue:saveOutgoingMediaStr forKey:@"saveOutGoingMedia"];
            [self.settingDictionary setValue:[NSString stringWithFormat:@"%ld", timerValue] forKey:@"chatTimeLimit"];
            
            NSData* mumblerUserSettingsData=[NSKeyedArchiver archivedDataWithRootObject:self.settingDictionary];
            NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
            [userDefaults setObject:mumblerUserSettingsData forKey:MUMBLER_CHAT_SETTINGS];
            [userDefaults synchronize];
            
            NSLog(@"mumbleruserJson------%@",self.settingDictionary);
            
            
            
            
        }else{
            
            [[[UIAlertView alloc] initWithTitle:@"Alert"
                                        message:status
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:[error localizedDescription] delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
        
    }];
    
}



-(void)mergeFbMumblerUser:(NSString *)fbId
{
    NSLog(@"mergeFbMumblerUser-----------");
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSMutableString *jsonString  = [[NSMutableString alloc] init];
    
    [jsonString appendFormat:@"{"];
    
    [jsonString appendFormat:@"\"facebook_id\":\"%@\"", fbId];
    
    [jsonString appendFormat:@"}"];
    
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"json",nil];
    
    NSArray *values = [[NSArray alloc] initWithObjects:jsonString,nil];
    
    NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    NSString * serverCallRequest = [NSString stringWithFormat:@"%@%@", BASE_URL, @"mumblerUser/updateMyAccountWithFacebook.htm"];
    
    [manager GET:serverCallRequest parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        DDLogVerbose(@"%@: %@:updateMyAccountWithFacebook responseObject=%@ ", THIS_FILE, THIS_METHOD,responseObject);
        
        NSString *status = [responseObject valueForKey:@"status"];
        
        if([status isEqualToString:@"success"])
            
        {
            //updated the db
            
        }else{
            
            [[[UIAlertView alloc] initWithTitle:@"Alert"
                                        message:status
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogVerbose(@"%@: %@: Error =%@", THIS_FILE, THIS_METHOD,error);
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:[error localizedDescription] delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
        
    }];
    
    
}



// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    NSLog(@"PROFILE NAME %@", user.name);
    NSLog(@"PROFILE ID %@", user.id);
    
    [self mergeFbMumblerUser:user.id];
    
    
    [NSUserDefaults.standardUserDefaults setObject:user.id forKey:FB_USER_ID];
    
    [NSUserDefaults.standardUserDefaults synchronize];
    
    //[self loadSignUpWithFB:user.id:user.name];
    
}

// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"loginViewShowingLoggedInUser----");
    //self.statusLabel.text = @"You're logged in as";
}

// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"loginViewShowingLoggedOutUser----");
    // self.profilePictureView.profileID = nil;
    // self.nameLabel.text = @"";
    // self.statusLabel.text= @"You're not logged in!";
}


// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user Tapped FBErrorUtility");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

/////////////FACEBOOK


- (void)viewDidLoad
{
    [super viewDidLoad];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    
    
    
    //    XMPPvCardCoreDataStorage *xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    //    XMPPvCardTempModule *xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    //
    //    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    //    dispatch_async(queue, ^{
    //        [xmppvCardTempModule  activate:[[self appDelegate] xmppStream]];
    //
    //        XMPPJID *usertst=[XMPPJID jidWithString:@"54@ejabberd.server.mumblerchat"];
    //        XMPPvCardTemp *vCard = [xmppvCardTempModule vCardTempForJID:usertst shouldFetch:YES];
    //        NSLog(@"Vcard === %@",vCard.middleName);
    //        if(vCard!=nil){
    //            NSLog(@"vcard requested from chats view=== %@",vCard.namespaces);
    //            NSLog(@"vcard requested from chats view=== %@",vCard.middleName);
    //            NSLog(@"vcard requested from chats view=== %@",vCard.nickname);
    //
    //
    //
    //        }
    //    });
    //
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
    
    self.loginView.delegate = self;
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    
    changePhotoPopUpView.hidden=true;
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipe.direction = (UISwipeGestureRecognizerDirectionLeft);
    [self.view addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipe.direction = (UISwipeGestureRecognizerDirectionRight);
    [self.view addGestureRecognizer:rightSwipe];
    
    NSString *myId=[NSUserDefaults.standardUserDefaults valueForKey:MUMBLER_USER_ID];
    UserDao *userDao=[[UserDao alloc]init];
    userObject=[userDao getUserForId:myId];
    
    NSLog(@"my user myId== == %@",myId);
    NSLog(@"my user == == %@",userObject.userProfileStatus);
    NSLog(@"my user ==alertsStatus == %@",userObject.alertsStatus);
    NSLog(@"my user ==saveOutgoingMediaStatus == %@",userObject.saveOutgoingMediaStatus);
    NSLog(@"my user ==whoCanSendMeMessages == %@",userObject.whoCanSendMeMessages);
    NSLog(@"my user ==whoCanSendMeMessages == %@",userObject.timeGivenToRenspond);
    
    
    [self loadUserProfileWithSettings];
    
    self.statusTextField.text=userObject.userProfileStatus;
    
    if ( [userObject.alertsStatus isEqualToString:@"1"]) {
        [switchAlert setOn:YES];
        alerts=@"1";
    } else {
        [switchAlert setOn:NO];
        alerts=@"0";
    }
    
    if ([userObject.saveOutgoingMediaStatus isEqualToString:@"1"]) {
        [switchSaveMedia setOn:YES];
        saveOutgoingMedia=@"1";
    } else {
        [switchSaveMedia setOn:NO];
        saveOutgoingMedia=@"0";
        
    }
    if([userObject.whoCanSendMeMessages isEqualToString:@"1"]){
        [self.whoCanMsgMeButton setTitle:@"EVERYONE" forState:UIControlStateNormal];
    }else{
        [self.whoCanMsgMeButton setTitle:@"FRIENDS" forState:UIControlStateNormal];
        
    }
    self.whoCanMsgMeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    mobileLabel.text = userObject.mobile;
    usernameLabel.text = userObject.name;
    nameLabel.text = userObject.name;
    statusTextField.text = userObject.userProfileStatus;
    [self.sliderView setCurrentValue:[userObject.timeGivenToRenspond intValue]];
    
    NSData *data = [NSData dataFromBase64String:userObject.profileImageBytes];
    UIImage *image= [UIImage imageWithData:data];
    if(image){
        [profileButton setBackgroundImage:image forState:UIControlStateNormal];
        profileButton.layer.cornerRadius = 20.0;
        profileButton.layer.masksToBounds = YES;
    }
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
