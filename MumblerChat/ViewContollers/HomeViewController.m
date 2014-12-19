//
//  HomeViewController.m
//  MumblerChat
//


#import "HomeViewController.h"
#import "Constants.h"
#import "FacebookSDK/FacebookSDK.h"

#import "AFHTTPRequestOperationManager.h"
#import "SVProgressHUD.h"
#import <AdSupport/AdSupport.h>
#import "ChatThreadViewController.h"
#import "FaceBookSignUpViewController.h"
#import "ASAppDelegate.h"
#import "XMPPvCardTemp.h"
#import "UserDao.h"
#import "NetworkUtil.h"

@interface HomeViewController (){
    BOOL haveAddedFriends;
}

@end

@implementation HomeViewController
@synthesize loginView;
@synthesize aliasMumblerChat;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    self.loginView.delegate = self;
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    // Do any additional setup after loading the view.

    [self.navigationController setNavigationBarHidden:YES];
    // Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
    
    self.loginView.frame = CGRectMake(0, 0, 320, 70);
    for (id obj in self.loginView.subviews)
    {
        if ([obj isKindOfClass:[UIButton class]])
        {
            UIButton * loginButton =  obj;
            UIImage *loginImage = [UIImage imageNamed:@"faceboook_back"];
            [loginButton setBackgroundImage:loginImage forState:UIControlStateNormal];
            [loginButton setBackgroundImage:nil forState:UIControlStateSelected];
            [loginButton setBackgroundImage:nil forState:UIControlStateHighlighted];
            [loginButton sizeToFit];
            loginButton.frame = CGRectMake(0, 0, 320, 70);

        }
        if ([obj isKindOfClass:[UILabel class]])
        {
            UILabel * loginLabel =  obj;
            loginLabel.text = @"Log in to facebook";
            loginLabel.textAlignment = UITextAlignmentCenter;
            loginLabel.frame = CGRectMake(0, 0, 320, 70);
        }
    }
    
    self.loginView.delegate = self;

}


// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    DDLogVerbose(@"%@: %@: FB PROFILE NAME= %@  PROFILE ID =%@", THIS_FILE, THIS_METHOD,user.name,user.id);
    
    [[NSUserDefaults standardUserDefaults] setObject:user.id forKey:FB_USER_ID];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    DDLogVerbose(@"%@: %@:END", THIS_FILE, THIS_METHOD);

    
    [self loadSignUpWithFB:user.id:user.name];
    
}

// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    DDLogVerbose(@"%@: %@: ", THIS_FILE, THIS_METHOD);

}

// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    DDLogVerbose(@"%@: %@: ", THIS_FILE, THIS_METHOD);

}


// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    DDLogVerbose(@"%@: %@: ", THIS_FILE, THIS_METHOD);

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


//signUpFB
-(void)loadSignUpWithFB:(NSString*)loggedInFacebookId :(NSString*)userName{
   
    DDLogVerbose(@"%@: %@: START", THIS_FILE, THIS_METHOD);

    
    NSUUID *UUID = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    NSString *udid = [UUID UUIDString];
    
    NSMutableString *userCredentials  = [[NSMutableString alloc] init];
    
    [userCredentials appendFormat:@"{"];
    
    [userCredentials appendFormat:@"\"user_name\":\"%@\",", userName];

    [userCredentials appendFormat:@"\"phone_number\":\"%@\",", @""];
    
    NSString * userEmail = [NSString stringWithFormat:@"%@%@", userName, @"@mumblerchat.com"];

    [userCredentials appendFormat:@"\"email\":\"%@\",", userEmail];
    
    [userCredentials appendFormat:@"\"device_type\":\"%@\",", @"iOS"];
    
    [userCredentials appendFormat:@"\"date_of_birth\":\"%@\",",@0];
    
    [userCredentials appendFormat:@"\"facebook_id\":\"%@\",",loggedInFacebookId];
    
    
    [userCredentials appendFormat:@"\"device_id\":\"%@\"", udid];
    
    [userCredentials appendString:@"}"];
    
    
    DDLogVerbose(@"%@: %@: USER CREDENTIALS %@", THIS_FILE, THIS_METHOD,userCredentials);

    
    //FB SIGN UP call auto signIn
    [self loadSignInWithFB :userCredentials: loggedInFacebookId];

    
}


//signInFB

-(void)loadSignInWithFB:(NSString*)userDetails :(NSString*)FaceBookId{
    
    
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);


    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"jsonForFacebookLogin",nil];
    
    NSArray *values = [[NSArray alloc] initWithObjects:userDetails,nil];
    
    NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    NSString * serverCallRequest = [NSString stringWithFormat:@"%@%@", BASE_URL, @"signIn.htm"];
    
    [manager POST:serverCallRequest parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        
        DDLogVerbose(@"%@: %@: RESPONSE jsonForFacebookLogin %@", THIS_FILE, THIS_METHOD,responseObject);
        
        NSString *status = [responseObject valueForKey:@"status"];
        
        if([status isEqualToString:@"success"])
        {
             DDLogVerbose(@"%@: %@: RESPONSE jsonForFacebookLogin success", THIS_FILE, THIS_METHOD);
            
            [[NSUserDefaults standardUserDefaults] setObject:SIGN_IN_TYPE_FB forKey:SIGN_IN_TYPE];
            [[NSUserDefaults standardUserDefaults] setObject:IS_USED_BEFORE_YES forKey:IS_USED_BEFORE];
            
            [[NSUserDefaults standardUserDefaults] setObject:userDetails forKey:FB_USER_DETAILS];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            NSString *signInState = [responseObject valueForKey:@"sign_in_state"];
                        
            NSDictionary *data = [responseObject valueForKey:@"data"];
            NSDictionary* mumblerUserSetting=[data valueForKey:@"mumbler_user_setting"];

            NSDictionary *mumblerUserDictionary= [data valueForKey:@"mumbler_user"];
            
            NSString * mumblerUserId =[mumblerUserDictionary valueForKey:@"mumblerUserId"];
            NSString * alias =[mumblerUserDictionary valueForKey:@"alias"];
            aliasMumblerChat=alias;
            
            DDLogVerbose(@"%@: %@: RESPONSE MUMBLER USER ID %@", THIS_FILE, THIS_METHOD,mumblerUserId);
            
            UserDao *userDao = [[UserDao alloc] init];
            [userDao createUpdateUser:mumblerUserDictionary];

            [[NSUserDefaults standardUserDefaults] setObject:mumblerUserId forKey:MUMBLER_USER_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
                if ([signInState isEqualToString:@"complete"]) {
                
                NSMutableArray *friendshipArray=[data valueForKey:@"friendships"];
                if ([friendshipArray count]>0) {
                    
                    haveAddedFriends =true;
                    
                }
                
                ///////////////CHAT
                
                NSError *error = nil;
                
                if( [[[self appDelegate] xmppStream] isConnected]){
                    
                   DDLogVerbose(@"%@: %@: connected with xmpp", THIS_FILE, THIS_METHOD);
                }else{
                   DDLogVerbose(@"%@: %@: not connected with xmpp", THIS_FILE, THIS_METHOD);
                    
                    
                    NSString *ejjabberedUsername = [NSString stringWithFormat:@"%@%@",mumblerUserId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
                    
                     DDLogVerbose(@"%@: %@: EJABBERED USERNAME %@", THIS_FILE, THIS_METHOD,ejjabberedUsername);
                    
                    [[[self appDelegate] xmppStream]setMyJID:[XMPPJID jidWithString:ejjabberedUsername]];
                    
                    [[[self appDelegate] xmppStream] connectWithTimeout:XMPPStreamTimeoutNone error:&error];
                    
                }
                
                ////////////////CHAT
                
                
            }else{
                 DDLogVerbose(@"%@: %@: SIGNIN STATE NOT COMPLETE ", THIS_FILE, THIS_METHOD);
               
                //go to fb sign up
                //xammpp register is there
                UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone_5s" bundle:nil];
                FaceBookSignUpViewController *storyViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"FaceBookSignUpViewController"];
                [self presentViewController:storyViewController animated:YES completion:nil]; //  present it
                
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
    
    
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);

    
}


- (void)viewWillDisappear:(BOOL)animated
{
    self.loginView.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}



/////////////////////CHAT

- (ASAppDelegate *)appDelegate
{
	return (ASAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)myMethodStreamDidRegister{
    
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    //updating the v card after creating the user
    XMPPvCardCoreDataStorage *xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    XMPPvCardTempModule *xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^{
        
        [xmppvCardTempModule  activate:[[self appDelegate] xmppStream]];
        
        XMPPvCardTemp *myvCardTemp = [xmppvCardTempModule myvCardTemp];
        if (!myvCardTemp) {
            DDLogVerbose(@"%@: %@: !myvCardTemp ", THIS_FILE, THIS_METHOD);
            
            NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
            XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
            
            
            NSString *fbId = [[NSUserDefaults standardUserDefaults]
                              valueForKey:FB_USER_ID];
            
            NSString * imageUrlString = [NSString stringWithFormat:@"%@%@%@", @"http://graph.facebook.com/", fbId,@"/picture?type=large"];
            NSURL *bgImageURL = [NSURL URLWithString:imageUrlString];
            NSData *bgImageData = [NSData dataWithContentsOfURL:bgImageURL];
            
            [newvCardTemp setNickname:aliasMumblerChat];
            [newvCardTemp setPhoto:bgImageData];
            [xmppvCardTempModule updateMyvCardTemp:newvCardTemp];
        }else{
            //Set Values as normal
            DDLogVerbose(@"%@: %@: myvCardTemp ", THIS_FILE, THIS_METHOD);
            
        }
        
    });

    
    if ([[self appDelegate] connect])
    {
        DDLogVerbose(@"%@: %@: APP DELEGATE CONNECT=%@", THIS_FILE, THIS_METHOD,[[[[self appDelegate] xmppStream] myJID] bare]);
        
        //if complete
        if(haveAddedFriends){
            
            UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone_5s" bundle:nil];
            ChatThreadViewController *storyViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ChatThreadViewController"];
            [self presentViewController:storyViewController animated:YES completion:nil]; //  present it
            
        }else{
            //if friends added no, check Internet
            //interent is there....Frnds screen
            //no interent..chat
            NSString *internetConnectionStatus = [NetworkUtil checkInternetConnectivity];
            
            //Internet connection is there
            if([internetConnectionStatus isEqualToString:INTERNET_CONNECTION_AVAILABLE]){
                
                //Add Friends Screen..CONTACTS HIGHLIGHTED
                [[NSUserDefaults standardUserDefaults] setObject:ADD_FRIEND_FACEBOOK_TAB forKey:ADD_FRIEND_TAB_TO_SELECTED];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self performSegueWithIdentifier:@"Add_friends_Home" sender:self];

                
            }
            //Internet connection is not there
            else{
                //there is no internet....Chat Thread Screen
                UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone_5s" bundle:nil];
                ChatThreadViewController *storyViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ChatThreadViewController"];
                [self presentViewController:storyViewController animated:YES completion:nil]; //  present it
            }

        }
        
    
        
    } else
    {
        DDLogVerbose(@"%@: %@: APP DELEGATE DID NOT CONNECT NO JID", THIS_FILE, THIS_METHOD);

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Unable to login to xmpp server as new user" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
    }
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
}
- (void) viewDidAppear:(BOOL)animated
{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMethodDidNotRegister) name:@"didNotRegister" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMethodStreamDidRegister) name:@"xmppStreamDidRegister" object:nil];
    
    
}
-(void)myMethodDidNotRegister{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Unable to register user in xmpp" delegate:self
                                          cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alert show];
    
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
