//
//  SplashViewController.m
//  MumblerChat
//
// NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];

#import "SplashViewController.h"
#import "Constants.h"
#import "Reachability.h"
#import "FacebookSDK/FacebookSDK.h"
#import "NetworkUtil.h"
#import "SignInViewController.h"

#import "AFHTTPRequestOperationManager.h"
#import "SVProgressHUD.h"
#import <AdSupport/AdSupport.h>

#import "XMPPvCardTemp.h"
#import "XMPPFramework.h"
#import "UserDao.h"
#import "ChatThreadViewController.h"

@interface SplashViewController (){
    BOOL showFindAddFriendsScreen;
}

@end

@implementation SplashViewController
@synthesize loginView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {

     DDLogVerbose(@"%@: %@: CURRENT FB USER ID =%@", THIS_FILE, THIS_METHOD,user.id);
   
    NSString *userFbId = [[NSUserDefaults standardUserDefaults]
                          valueForKey:FB_USER_ID];
    
    //Check_SIGN_IN_TYPE
    NSString *signInType = [[NSUserDefaults standardUserDefaults]
                            valueForKey:SIGN_IN_TYPE];
    
    if(![signInType isEqualToString:SIGN_IN_TYPE_NORMAL]){
        
        if([user.id isEqualToString:userFbId]){
            
            DDLogVerbose(@"%@: %@: CURRENT FB USER ID SAME AS MUMBLER FB USER =%@", THIS_FILE, THIS_METHOD,user.id);
            
            //Call auto login server call with FB_USER_ID
            [self loadAutoSignInWithFB];
            
            
        }else{
            
            //logout
            //directs to the description screen
//            [FBSession.activeSession closeAndClearTokenInformation];
//            [FBSession.activeSession close];
//            [FBSession setActiveSession:nil];
            [self dispalyHomeScreen];
            
            
        }

    }
    
    
}

// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    DDLogVerbose(@"%@: %@: ", THIS_FILE, THIS_METHOD);
    
}

// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    //DDLogVerbose(@"%@: %@: ", THIS_FILE, THIS_METHOD);
    NSLog(@"loginViewShowingLoggedOutUser");
}


// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    DDLogVerbose(@"%@: %@: START", THIS_FILE, THIS_METHOD);
    
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
       
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.loginView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"xmppStreamDidAuthenticate" object:nil];
    

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
   // DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    [self.navigationController setNavigationBarHidden:YES];
    
    
    loginView.hidden=true;
    self.loginView.delegate = self;
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    
    
    NSString *isUsedBeforeState = [[NSUserDefaults standardUserDefaults]
                                   valueForKey:IS_USED_BEFORE];
    //not the first time app running
    if([isUsedBeforeState isEqualToString:IS_USED_BEFORE_YES]){
       // DDLogVerbose(@"%@: %@: IS_USED_BEFORE_YES ", THIS_FILE, THIS_METHOD);
        
        //Check_SIGN_IN_TYPE
        NSString *signInType = [[NSUserDefaults standardUserDefaults]
                                valueForKey:SIGN_IN_TYPE];
        
        //Normal Sign_up
        if([signInType isEqualToString:SIGN_IN_TYPE_NORMAL]){
           // DDLogVerbose(@"%@: %@: SIGN_IN_TYPE_NORMAL ", THIS_FILE, THIS_METHOD);
            
            
            //Check_LOGOUT
            NSString *logOutState = [[NSUserDefaults standardUserDefaults]
                                     valueForKey:USER_LOG_OUT];
            
            //user is still logged in
            if(![logOutState isEqualToString:USER_LOG_OUT_YES]){
                
                DDLogVerbose(@"%@: %@: USER_LOG_OUT_NO ", THIS_FILE, THIS_METHOD);
                
                [self loadNormalSignInAutoSignIn];
            }
            
            //user log out
            else{
                
                DDLogVerbose(@"%@: %@: USER_LOG_OUT_YES DISPLAY HOME SCREEN", THIS_FILE, THIS_METHOD);
                [self dispalyHomeScreen];
                
            }
            
            //Facebook sign up is auto handling in up
        }else{
            DDLogVerbose(@"%@: %@: SIGN_IN_TYPE_FACEBOOK", THIS_FILE, THIS_METHOD);
            
        }
        
    }else{
        //Home Screen
        //DDLogVerbose(@"%@: %@: IS_USED_BEFORE_NO HOME SCREEN", THIS_FILE, THIS_METHOD);
        [FBSession.activeSession closeAndClearTokenInformation];
        [FBSession.activeSession close];
        [FBSession setActiveSession:nil];
        [self dispalyHomeScreen];
        
    }
    
   // DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


//Auto signInFB
-(void)loadAutoSignInWithFB{
    
   DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    
    NSString *userDetails = [[NSUserDefaults standardUserDefaults]
                             valueForKey:FB_USER_DETAILS];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"jsonForFacebookLogin",nil];
    
    NSArray *values = [[NSArray alloc] initWithObjects:userDetails,nil];
    
    NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    NSString * serverCallRequest = [NSString stringWithFormat:@"%@%@", BASE_URL, @"signIn.htm"];
    
    [manager POST:serverCallRequest parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        
        
        NSString *status = [responseObject valueForKey:@"status"];
        
        if([status isEqualToString:@"success"])
        {
          
            NSString *signInState = [responseObject valueForKey:@"sign_in_state"];
            
            if ([signInState isEqualToString:@"complete"]) {
                NSDictionary *data = [responseObject valueForKey:@"data"];
                NSDictionary *mumblerUserDictionary= [data valueForKey:@"mumbler_user"];
                NSDictionary* mumblerUserSetting=[data valueForKey:@"mumbler_user_setting"];
                NSMutableArray *friendshipArray=[data valueForKey:@"friendships"];
                
                NSString * mumblerUserId =[mumblerUserDictionary valueForKey:@"mumblerUserId"];
                
                DDLogVerbose(@"%@: %@: MUMBLER USERID =%@", THIS_FILE, THIS_METHOD,mumblerUserId);
                
                
                
                UserDao *userDao = [[UserDao alloc] init];
                [userDao createUpdateUser:mumblerUserDictionary];
                
                [[NSUserDefaults standardUserDefaults] setObject:mumblerUserId forKey:MUMBLER_USER_ID];
                
                mumblerUserId=[NSString stringWithFormat:@"%@%@",mumblerUserId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
                ////////CHAT
                
                [[NSUserDefaults standardUserDefaults] setObject:mumblerUserId forKey:@"kXMPPmyJID"];
                [[NSUserDefaults standardUserDefaults] setObject:@"1qaz2wsx" forKey:@"kXMPPmyPassword"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if ([[self appDelegate] connect])
                {
                    
                    DDLogVerbose(@"%@: %@: xmppStream =%@", THIS_FILE, THIS_METHOD,[[[[self appDelegate] xmppStream] myJID] bare]);
                    
                }
                
                //Chat............
                
                BOOL isFriendAdded = [[NSUserDefaults standardUserDefaults]
                                      valueForKey:IS_FRIENDS_ADDED];
                //friends added
                if(isFriendAdded){
                    [self dispalyChatThreadScreen];
                    
                }
                else{
                    //if friends added no, check Internet
                    
                    NSString *internetConnectionStatus = [NetworkUtil checkInternetConnectivity];
                    
                    //Internet connection is there
                    if([internetConnectionStatus isEqualToString:INTERNET_CONNECTION_AVAILABLE]){
                        
                        //Add Friends Screen..CONTACTS HIGHLIGHTED
                        [[NSUserDefaults standardUserDefaults] setObject:ADD_FRIEND_FACEBOOK_TAB forKey:ADD_FRIEND_TAB_TO_SELECTED];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                   
                        [self dispalyFindAndAddFriendsScreen];
                        
                    }
                    //Internet connection is not there
                    else{
                        //there is no internet....Chat Thread Screen
                        [self dispalyChatThreadScreen];
                    }
                    
                }
                
            }else{
               
                 DDLogVerbose(@"%@: %@: SIGN IN STATE NOT COMPLETE ", THIS_FILE, THIS_METHOD);
            }
            
        }else{
            
            [[[UIAlertView alloc] initWithTitle:@"Alert"
                                        message:status
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:[error localizedDescription] delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
        
    }];
    
    
}


- (void)dispalyHomeScreen{
    NSLog(@"dispalyHomeScreen dispalyHomeScreen");
    [self performSegueWithIdentifier:@"description_screen" sender:self];
    
}

- (void)dispalyChatThreadScreen{
     DDLogVerbose(@"%@: %@: START", THIS_FILE, THIS_METHOD);
    
    //[self performSegueWithIdentifier:@"addAndFindFriends_screen" sender:self];
    
    [self performSegueWithIdentifier:@"chatThread_screen" sender:self];
    
  //  DDLogVerbose(@"%@: %@: END", THIS_FILE, THIS_METHOD);
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"chatThread_screen"]) {
        
        ChatThreadViewController *chatThreadViewController = (ChatThreadViewController *) [segue destinationViewController];
        chatThreadViewController.isFromSplash = true;
       // DDLogVerbose(@"%@: %@: IS FROM SPLASH TRUE", THIS_FILE, THIS_METHOD);
        
    }

}

- (void)dispalyFindAndAddFriendsScreen{
     DDLogVerbose(@"%@: %@: START", THIS_FILE, THIS_METHOD);
    
    [self performSegueWithIdentifier:@"addAndFindFriends_screen" sender:self];
    
     DDLogVerbose(@"%@: %@: END", THIS_FILE, THIS_METHOD);
}

- (ASAppDelegate *)appDelegate
{
	return (ASAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)loadNormalSignInAutoSignIn{
    DDLogVerbose(@"%@: %@: START", THIS_FILE, THIS_METHOD);
    
    NSString *username = [[NSUserDefaults standardUserDefaults]
                          valueForKey:USERNAME];
    NSString *password = [[NSUserDefaults standardUserDefaults]
                          valueForKey:PASSWORD];
    
    DDLogVerbose(@"%@: %@: USER NAME =%@, PASSWORD= %@", THIS_FILE, THIS_METHOD,username,password);
    
    
    
    if(username.length > 0 && password.length > 0){
        
        [SVProgressHUD show];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        
        NSString * userEmail = [NSString stringWithFormat:@"%@%@", username, @"@mumblerchat.com"];
        
        NSMutableString *jsonString  = [[NSMutableString alloc] init];
        [jsonString appendFormat:@"{"];
        [jsonString appendFormat:@"\"email\":\"%@\",",userEmail];
        [jsonString appendFormat:@"\"password\":\"%@\"",password];
        [jsonString appendFormat:@"}"];
        
        NSArray *keys = [[NSArray alloc] initWithObjects:@"jsonForNormalLogin",nil];
        
        NSArray *values = [[NSArray alloc] initWithObjects:jsonString,nil];
        
        NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
        
        NSString * serverCallRequest = [NSString stringWithFormat:@"%@%@", BASE_URL, @"signIn.htm"];
        
        [manager POST:serverCallRequest parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            DDLogVerbose(@"%@: %@: RESPONSE OBJECT = %@", THIS_FILE, THIS_METHOD,responseObject);
            
            
            NSString *status = [responseObject valueForKey:@"status"];
            [SVProgressHUD dismiss];
            if([status isEqualToString:@"success"])
            {
                DDLogVerbose(@"%@: %@: SUCCESS jsonForNormalLogin = %@", THIS_FILE, THIS_METHOD,responseObject);
                
                
                NSString *signInState = [responseObject valueForKey:@"sign_in_state"];
                
                if ([signInState isEqualToString:@"complete"]) {
                    
                    NSDictionary *data = [responseObject valueForKey:@"data"];
                    NSDictionary *mumblerUserDictionary= [data valueForKey:@"mumbler_user"];
                    
                    UserDao *userDao = [[UserDao alloc] init];
                    [userDao createUpdateUser:mumblerUserDictionary];
                    
                    NSDictionary* mumblerUserSettingDictionary=[data valueForKey:@"mumbler_user_setting"];
                    NSLog(@"mumblerUserSettingDictionary mumblerUserSettingDictionary= %@",mumblerUserSettingDictionary);


                    
                    
                    NSMutableArray *friendshipArray=[data valueForKey:@"friendships"];
                    
                    NSData* mumblerUserSettingsData=[NSKeyedArchiver archivedDataWithRootObject:mumblerUserSettingDictionary];
                    [[NSUserDefaults standardUserDefaults] setObject:mumblerUserSettingsData forKey:MUMBLER_CHAT_SETTINGS];
                    
                    NSData* mumblerUserData=[NSKeyedArchiver archivedDataWithRootObject:mumblerUserDictionary];
                    [[NSUserDefaults standardUserDefaults] setObject:mumblerUserData forKey:MUMBLER_CHAT_USER_PROFILE];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    
                    NSString * mumblerUserId =[mumblerUserDictionary valueForKey:@"mumblerUserId"];
                    
                    DDLogVerbose(@"%@: %@: SUCCESS jsonForNormalLogin mumblerUserId= %@", THIS_FILE, THIS_METHOD,mumblerUserId);
                    
                    
                    [[NSUserDefaults standardUserDefaults] setObject:mumblerUserId forKey:MUMBLER_USER_ID];
                    
                    mumblerUserId=[NSString stringWithFormat:@"%@%@",mumblerUserId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
                    ////////CHAT
                    
                    [[NSUserDefaults standardUserDefaults] setObject:mumblerUserId forKey:@"kXMPPmyJID"];
                    [[NSUserDefaults standardUserDefaults] setObject:@"1qaz2wsx" forKey:@"kXMPPmyPassword"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    if ([[self appDelegate] connect])
                    {
                        DDLogVerbose(@"%@: %@: appDelegate connect= %@", THIS_FILE, THIS_METHOD,[[[[self appDelegate] xmppStream] myJID] bare]);
                        
                    } else
                    {
                        DDLogVerbose(@"%@: %@: NO JID = %@", THIS_FILE, THIS_METHOD,responseObject);
                        
                    }
                    
                    BOOL isFriendAdded = [[NSUserDefaults standardUserDefaults]
                                                   valueForKey:IS_FRIENDS_ADDED];
                    //friends added
                    if(isFriendAdded){
                        [self dispalyChatThreadScreen];
                        
                    }
                    
                    else{
                        
                        //if friends added no, check Internet
                        NSString *internetConnectionStatus = [NetworkUtil checkInternetConnectivity];
                        
                        //Internet connection is there
                        if([internetConnectionStatus isEqualToString:INTERNET_CONNECTION_AVAILABLE]){
                            
                            //Add Friends Screen..CONTACTS HIGHLIGHTED
                            [[NSUserDefaults standardUserDefaults] setObject:ADD_FRIEND_CONTACT_TAB forKey:ADD_FRIEND_TAB_TO_SELECTED];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                           
                            showFindAddFriendsScreen=true;
                            
                        }
                        //Internet connection is not there
                        else{

                            //there is no internet....Chat Thread Screen
                            [self dispalyChatThreadScreen];
                        }
                        
                    }
                    
                }else{
                    DDLogVerbose(@"%@: %@: SUCCESS jsonForNormalLogin signInState not complete", THIS_FILE, THIS_METHOD);
                    
                }
                
            }else{
                
                [[[UIAlertView alloc] initWithTitle:@"Alert"
                                            message:status
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:[error localizedDescription] delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alert show];
            
        }];
        
        
        
    }else{
        
        [[[UIAlertView alloc] initWithTitle:@"Alert"
                                    message:@"Username, Password not available"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
        
    }
    
    // DDLogVerbose(@"%@: %@: END", THIS_FILE, THIS_METHOD);
}


- (void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMethodStreamDidAthenticate) name:@"xmppStreamDidAuthenticate" object:nil];
    
    
}

-(void)myMethodStreamDidAthenticate{
    DDLogVerbose(@"%@: %@: START", THIS_FILE, THIS_METHOD);
    
   if(showFindAddFriendsScreen){
        [self dispalyFindAndAddFriendsScreen];
    }
    
    DDLogVerbose(@"%@: %@: END", THIS_FILE, THIS_METHOD);
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
