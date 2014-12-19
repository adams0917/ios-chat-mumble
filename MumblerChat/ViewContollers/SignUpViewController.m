//
//  SignUpViewController.m
//  MumblerChat
//


#import "SignUpViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "SVProgressHUD.h"
#import <AdSupport/AdSupport.h>
#import "Constants.h"
#import "NetworkUtil.h"
#import "XMPPFramework.h"
#import "ASAppDelegate.h"
#import "XMPPvCardTemp.h"
#import "UserDao.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController
@synthesize userNameTextField;
@synthesize passwordTextField;
@synthesize mobileNumberTextField;

- (IBAction)didTapBackButton:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];

}

-(BOOL)isMobileNumber:(NSString*)text{
    
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    BOOL phoneValidates = [phoneTest evaluateWithObject:text];
    
    return phoneValidates;
    
}



-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}


- (void)loadSignUp{
     DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    [SVProgressHUD show];
    
    NSUUID *UUID = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    NSString *udid = [UUID UUIDString];
    
    //testing purpose//DOB
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
   

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSMutableString *jsonString  = [[NSMutableString alloc] init];
    
    [jsonString appendFormat:@"{"];
    
    [jsonString appendFormat:@"\"user_name\":\"%@\",", self.userNameTextField.text];
    
    [jsonString appendFormat:@"\"password\":\"%@\",", self.passwordTextField.text];
    
    [jsonString appendFormat:@"\"phone_number\":\"%@\",", mobileNumberTextField.text];
    
    NSString * userEmail = [NSString stringWithFormat:@"%@%@", userNameTextField.text, @"@mumblerchat.com"];
    
    [jsonString appendFormat:@"\"email\":\"%@\",", userEmail];
    
    [jsonString appendFormat:@"\"device_type\":\"%@\",", @"iOS"];
    
    [jsonString appendFormat:@"\"date_of_birth\":\"%lld\",", milliseconds];
    
    [jsonString appendFormat:@"\"device_id\":\"%@\"", udid];
    
    [jsonString appendString:@"}"];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"json",nil] ;
    
    NSArray *values = [[NSArray alloc] initWithObjects:jsonString,nil];
    
    NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    NSString * serverCallRequest = [NSString stringWithFormat:@"%@%@", BASE_URL, @"registerMumblerUser.htm"];
    
    [manager POST:serverCallRequest parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        DDLogVerbose(@"%@: %@: registerMumblerUser response %@ =", THIS_FILE, THIS_METHOD,responseObject);
        
          [SVProgressHUD dismiss];
        
        NSString *status = [responseObject valueForKey:@"status"];
        if([status isEqualToString:@"success"])
        {
            //call auto signIn
            [self loadNormalAutoSignIn:userEmail :self.passwordTextField.text];
            
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







- (IBAction)didTapOnNormalSignUpButton:(id)sender {
    
   if(userNameTextField.text.length > 0 && passwordTextField.text.length > 0 && mobileNumberTextField.text.length > 0){
       
    if(passwordTextField.text.length > 0 && passwordTextField.text.length > 5){
       
          if ([self isMobileNumber:mobileNumberTextField.text]) {
              
              //all the validations are ok
              [self loadSignUp];
              
              
              
              
              
            
          }else{
              [[[UIAlertView alloc] initWithTitle:@"Alert"
                                          message:@"Required Valid Mobile Number"
                                         delegate:nil
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil] show];
              
          }
       }else{
            [[[UIAlertView alloc] initWithTitle:@"Alert"
                                        message:@"Password length is minimum 6"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            

          }
        
    }else{
        [[[UIAlertView alloc] initWithTitle:@"Alert"
                                    message:@"Missing Required Fields"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        

    
    
    }
   
}

-(void)loadNormalAutoSignIn:(NSString*)username :(NSString*)password{
   
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSMutableString *jsonString  = [[NSMutableString alloc] init];
    [jsonString appendFormat:@"{"];
    [jsonString appendFormat:@"\"email\":\"%@\",",username];
    [jsonString appendFormat:@"\"password\":\"%@\"",password];
    [jsonString appendFormat:@"}"];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"jsonForNormalLogin",nil];
    
    NSArray *values = [[NSArray alloc] initWithObjects:jsonString,nil];
    
    NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    NSString * serverCallRequest = [NSString stringWithFormat:@"%@%@", BASE_URL, @"signIn.htm"];
    
    [manager POST:serverCallRequest parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        DDLogVerbose(@"%@: %@: jsonForNormalLogin responseObject %@= ", THIS_FILE, THIS_METHOD,responseObject);
        
        NSString *status = [responseObject valueForKey:@"status"];
        
        if([status isEqualToString:@"success"])
        {
            
            [[NSUserDefaults standardUserDefaults] setObject:SIGN_IN_TYPE_NORMAL forKey:SIGN_IN_TYPE];
            [[NSUserDefaults standardUserDefaults] setObject:userNameTextField.text forKey:USERNAME];
            [[NSUserDefaults standardUserDefaults] setObject:passwordTextField.text forKey:PASSWORD];
            [[NSUserDefaults standardUserDefaults] setObject:IS_USED_BEFORE_YES forKey:IS_USED_BEFORE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString *signInState = [responseObject valueForKey:@"sign_in_state"];
            
            if ([signInState isEqualToString:@"complete"]) {
                
              NSDictionary *data = [responseObject valueForKey:@"data"];
              NSDictionary *mumblerUserDictionary= [data valueForKey:@"mumbler_user"];
                
                NSString * mumblerUserId =[mumblerUserDictionary valueForKey:@"mumblerUserId"];
                
                DDLogVerbose(@"%@: %@: jsonForNormalLogin mumblerUserId %@= ", THIS_FILE, THIS_METHOD,mumblerUserId);
                
                
                UserDao *userDao = [[UserDao alloc] init];
                [userDao createUpdateUser:mumblerUserDictionary];
                
                [[NSUserDefaults standardUserDefaults] setObject:mumblerUserId forKey:MUMBLER_USER_ID];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
               // NSError *error = nil;
                
              
               /* if( [[[self appDelegate] xmppStream] isConnected]){
                    
                    DDLogVerbose(@"%@: %@: is connected to xmpp ", THIS_FILE, THIS_METHOD);
                    
                    
                }else{
                    DDLogVerbose(@"%@: %@: not connected to xmpp ", THIS_FILE, THIS_METHOD);
                    
                   
                     NSString *ejjabberedUsername = [NSString stringWithFormat:@"%@%@",mumblerUserId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
                    DDLogVerbose(@"%@: %@: ejjabberedUsername =%@ ", THIS_FILE, THIS_METHOD,ejjabberedUsername);
                    
                    [[[self appDelegate] xmppStream]setMyJID:[XMPPJID jidWithString:ejjabberedUsername]];
                    
                    
                    [[[self appDelegate] xmppStream] connectWithTimeout:XMPPStreamTimeoutNone error:&error];
                    
                                    
                    
                }*/
                
                
                
                NSError *error = nil;
                
                if( [[[self appDelegate] xmppStream] isConnected]){
                    
                    NSLog(@"isConnected to xmpp");
                    
                }else{
                    NSLog(@"Not isConnected to xmpp");
                    
                    NSString *ejjabberedUsername = [NSString stringWithFormat:@"%@%@",mumblerUserId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
                    DDLogVerbose(@"%@: %@: ejjabberedUsername =%@ ", THIS_FILE, THIS_METHOD,ejjabberedUsername);
                    
                    
                    [[[self appDelegate] xmppStream]setMyJID:[XMPPJID jidWithString:ejjabberedUsername]];
                    [[[self appDelegate] xmppStream] registerWithPassword:@"1qaz2wsx" error:&error];
                    
                    [[[self appDelegate] xmppStream] connectWithTimeout:XMPPStreamTimeoutNone error:&error];
                    
                }
                
                
                
            
                //if friends added no, check Internet
                NSString *internetConnectionStatus = [NetworkUtil checkInternetConnectivity];
                
                //Internet connection is there
                if([internetConnectionStatus isEqualToString:INTERNET_CONNECTION_AVAILABLE]){
                    
                    //Add Friends Screen..CONTACTS HIGHLIGHTED
                    [[NSUserDefaults standardUserDefaults] setObject:ADD_FRIEND_CONTACT_TAB forKey:ADD_FRIEND_TAB_TO_SELECTED];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    
                }
                //Internet connection is not there
                else{
                    //there is no internet....Chat Thread Screen
                    /*[self performSegueWithIdentifier:@"chatThread_signUp" sender:self];*/
                }
               
            }else{
                DDLogVerbose(@"%@: %@: signInState not complete ", THIS_FILE, THIS_METHOD);
                
            }
            
        }else{
            
            [[[UIAlertView alloc] initWithTitle:@"Alert"
                                        message:status
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogVerbose(@"%@: %@: Error=%@ ", THIS_FILE, THIS_METHOD,error);
        
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:[error localizedDescription] delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
        
    }];
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (IBAction)doneClicked:(id)sender
{

    [self.view endEditing:YES];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    [userNameTextField setDelegate:self];
    [passwordTextField setDelegate:self];
    [mobileNumberTextField setDelegate:self];
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    mobileNumberTextField.inputAccessoryView = keyboardDoneButtonView;
    passwordTextField.inputAccessoryView = keyboardDoneButtonView;
    
    
    [self.navigationController setNavigationBarHidden:YES];


    // Do any additional setup after loading the view.
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (ASAppDelegate *)appDelegate
{
	return (ASAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)myMethodStreamDidRegister{
   
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    
    //updating the v card after creating the user
    
    if ([[self appDelegate] connect])
    {
        DDLogVerbose(@"%@: %@: user =%@", THIS_FILE, THIS_METHOD,[[[[self appDelegate] xmppStream] myJID] bare]);
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
                [newvCardTemp setNickname:self.userNameTextField.text];
                [xmppvCardTempModule updateMyvCardTemp:newvCardTemp];
            }else{
                //Set Values as normal
                DDLogVerbose(@"%@: %@: myvCardTemp ", THIS_FILE, THIS_METHOD);
                

            }
            
        });

        [self performSegueWithIdentifier:@"addFindFriends_signUp" sender:nil];
        
    } else
    {
        DDLogVerbose(@"%@: %@: NO JID ", THIS_FILE, THIS_METHOD);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Unable to login to xmpp server as new user" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
    }
    
}
- (void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMethodDidNotRegister) name:@"didNotRegister" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMethodStreamDidRegisterAndAuthenticate) name:@"xmppStreamDidAuthenticate" object:nil];

    
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didNotRegister" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"xmppStreamDidAuthenticate" object:nil];
    
}


-(void)myMethodStreamDidRegisterAndAuthenticate{
    NSLog(@"my method fired====myMethodStreamDidRegisterAndAuthenticate");
    
    XMPPvCardCoreDataStorage *xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    XMPPvCardTempModule *xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^{
        
        
        [xmppvCardTempModule  activate:[[self appDelegate] xmppStream]];
        
        XMPPvCardTemp *myVcardTemp = [xmppvCardTempModule myvCardTemp];
        
        if (myVcardTemp == nil) {
            // I am stuck here, unable to create empty VCard for new User
            NSLog(@"Register-----updating vcard is nil ,,,,,========");
            
            NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
            XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
            [newvCardTemp setNickname:self.userNameTextField.text];
            [xmppvCardTempModule updateMyvCardTemp:newvCardTemp];
            
            NSLog(@"Register-----newvCardTemp========%@",newvCardTemp);
            
            
        }
        else {
            NSLog(@"Register-----updating vcard========");
            [myVcardTemp setNickname:self.userNameTextField.text];
            [xmppvCardTempModule updateMyvCardTemp:myVcardTemp];
            /*[myVcardTemp setPhoto:[NSData dataFromBase64String:[self encodeUIImage:self.imgProfile.image]]];
            [xmppvCardTempModule updateMyvCardTemp:myVcardTemp];
            NSLog(@"about to upload image == %@",[self encodeUIImage:self.imgProfile.image]);*/
            
            NSLog(@"Register-----newvCardTemp========%@",myVcardTemp);
            
        }
        
    });
    [SVProgressHUD dismissWithSuccess:@"Successfully updated"];
    
    if ([[self appDelegate] connect])
    {
        NSLog(@"Login logged in as == %@",[[[[self appDelegate] xmppStream] myJID] bare]);
        [self performSegueWithIdentifier:@"registerToHome" sender:nil];
        
    } else
    {
        NSLog(@"Login logged in as == %@", @"No JID");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil) message:NSLocalizedString(@"unable_to_login_xmpp", nil) delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];
        
        [alert show];
    }
    
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
