//
//  SignInViewController.m
//  MumblerChat
//


#import "SignInViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "SVProgressHUD.h"
#import <AdSupport/AdSupport.h>
#import "Constants.h"
#import "ASAppDelegate.h"
#import "User.h"
#import "UserDao.h"
#import "ChatThreadViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController
@synthesize userNameTextField;
@synthesize passwordTextField;

- (IBAction)didTapBackButton:(id)sender {
    
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

- (IBAction)doneClicked:(id)sender
{
    [self.view endEditing:YES];
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
     [passwordTextField setDelegate:self];
     [userNameTextField setDelegate:self];
     [self.navigationController setNavigationBarHidden:YES];
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    passwordTextField.inputAccessoryView = keyboardDoneButtonView;
    

    // Do any additional setup after loading the view.
}
- (IBAction)didTapSignInButton:(id)sender {
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    if(userNameTextField.text.length > 0 && passwordTextField.text.length > 0){
        
        if(passwordTextField.text.length > 5){
            
            [self loadNormalSignIn];
            
            
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
    
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
    
}

- (ASAppDelegate *)appDelegate
{
	return (ASAppDelegate *)[[UIApplication sharedApplication] delegate];
}




- (void)loadNormalSignIn{
    
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString * userEmail = [NSString stringWithFormat:@"%@%@", userNameTextField.text, @"@mumblerchat.com"];
    
    NSMutableString *jsonString  = [[NSMutableString alloc] init];
    [jsonString appendFormat:@"{"];
    [jsonString appendFormat:@"\"email\":\"%@\",",userEmail];
    [jsonString appendFormat:@"\"password\":\"%@\"",passwordTextField.text];
    [jsonString appendFormat:@"}"];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"jsonForNormalLogin",nil];
    
    NSArray *values = [[NSArray alloc] initWithObjects:jsonString,nil];
    
    NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    NSString * serverCallRequest = [NSString stringWithFormat:@"%@%@", BASE_URL, @"signIn.htm"];
    
    [manager POST:serverCallRequest parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
         [SVProgressHUD dismiss];
        
        DDLogVerbose(@"%@: %@: jsonForNormalLogin responseObject=%@ ", THIS_FILE, THIS_METHOD,responseObject);
        
        NSString *status = [responseObject valueForKey:@"status"];
        
        if([status isEqualToString:@"success"])
            
        {
            [NSUserDefaults.standardUserDefaults setObject:SIGN_IN_TYPE_NORMAL forKey:SIGN_IN_TYPE];
            [NSUserDefaults.standardUserDefaults setObject:userNameTextField.text forKey:USERNAME];
            [NSUserDefaults.standardUserDefaults setObject:passwordTextField.text forKey:PASSWORD];
            [NSUserDefaults.standardUserDefaults setObject:IS_USED_BEFORE_YES forKey:IS_USED_BEFORE];
            [NSUserDefaults.standardUserDefaults synchronize];
            
            NSString *signInState = [responseObject valueForKey:@"sign_in_state"];
            
              if ([signInState isEqualToString:@"complete"]) {
                  NSDictionary *data = [responseObject valueForKey:@"data"];
                  NSDictionary *mumblerUserDictionary= [data valueForKey:@"mumbler_user"];
                   NSDictionary* mumblerUserSettingDictionary=[data valueForKey:@"mumbler_user_setting"];
                  NSMutableArray *friendshipArray=[data valueForKey:@"friendships"];
                  
                  NSString * mumblerUserId =[mumblerUserDictionary valueForKey:@"mumblerUserId"];
                  
                  NSData* mumblerUserSettingsData=[NSKeyedArchiver archivedDataWithRootObject:mumblerUserSettingDictionary];
                  [NSUserDefaults.standardUserDefaults setObject:mumblerUserSettingsData forKey:MUMBLER_CHAT_SETTINGS];
                  
                  NSData* mumblerUserData=[NSKeyedArchiver archivedDataWithRootObject:mumblerUserDictionary];
                  [NSUserDefaults.standardUserDefaults setObject:mumblerUserData forKey:MUMBLER_CHAT_USER_PROFILE];
                  
                  [NSUserDefaults.standardUserDefaults synchronize];
                  
                  
                  DDLogVerbose(@"%@: %@: mumblerUserId=%@ ", THIS_FILE, THIS_METHOD,mumblerUserId);
                  
                  
                [NSUserDefaults.standardUserDefaults setObject:mumblerUserId forKey:MUMBLER_USER_ID];
                  
                  mumblerUserId=[NSString stringWithFormat:@"%@%@",mumblerUserId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
                  ////////CHAT
                  
                  [NSUserDefaults.standardUserDefaults setObject:mumblerUserId forKey:@"kXMPPmyJID"];
                  [NSUserDefaults.standardUserDefaults setObject:@"1qaz2wsx" forKey:kXMPPmyPassword];
                   [NSUserDefaults.standardUserDefaults synchronize];
                  
                  UserDao *userDao = [[UserDao alloc] init];
                  [userDao createUpdateUser:mumblerUserDictionary];
                  
                  if ([[self appDelegate] connect])
                  {
                      DDLogVerbose(@"%@: %@: connect=%@ ", THIS_FILE, THIS_METHOD,[[[[self appDelegate] xmppStream] myJID] bare]);
                      
                      
                 } else
                  {
                      DDLogVerbose(@"%@: %@: NO JID", THIS_FILE, THIS_METHOD);
                      
                 }
                  
                  
                  BOOL isFriendAdded = [NSUserDefaults.standardUserDefaults
                                        valueForKey:IS_FRIENDS_ADDED];
                  //friends added
                  if(isFriendAdded){
                      [self performSegueWithIdentifier:@"chat_thread_signIn" sender:self];
                      
                  }else{
                      //Add Friends Screen
                      [self performSegueWithIdentifier:@"add_friend_signIn" sender:self];
                  }
                  
              }else{
                   DDLogVerbose(@"%@: %@: signInState not complete", THIS_FILE, THIS_METHOD);
              }
                    
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
    
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
    
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"chat_thread_signIn"]) {
        
        ChatThreadViewController *chatThreadViewController = (ChatThreadViewController *) [segue destinationViewController];
        chatThreadViewController.isFromSplash = true;
    }
    
}


-(void)viewDidDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
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
