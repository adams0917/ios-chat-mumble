//
//  FaceBookSignUpViewController.m
//  MumblerChat
//


#import "FaceBookSignUpViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "SVProgressHUD.h"
#import <AdSupport/AdSupport.h>
#import "NetworkUtil.h"
#import "ChatThreadViewController.h"
//#import "AddFriendsViewController.h"
#import "Constants.h"
#import "FriendTableViewCell.h"

#import "ASAppDelegate.h"
#import "XMPPvCardTemp.h"

@interface FaceBookSignUpViewController ()

@end

@implementation FaceBookSignUpViewController
@synthesize usernameTextField;
@synthesize mobileNumberTextField;


-(BOOL)isMobileNumber:(NSString*)text{
    
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    BOOL phoneValidates = [phoneTest evaluateWithObject:text];
    
    return phoneValidates;
    
}

- (IBAction)didTapOnFacebookSignUPButton:(id)sender {
    
    if(usernameTextField.text.length > 0 && mobileNumberTextField.text.length > 0){
        
        if ([self isMobileNumber:mobileNumberTextField.text]) {
            
            //server call update
            [self loadUpdateProfile];
            
            
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Alert"
                                        message:@"Required Valid Mobile"
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



- (void)loadUpdateProfile{
    
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    NSMutableString *jsonString  = [[NSMutableString alloc] init];
    
    [jsonString appendFormat:@"{"];
    
    [jsonString appendFormat:@"\"phone_number\":\"%@\",", mobileNumberTextField.text];
    [jsonString appendFormat:@"\"alias\":\"%@\",",usernameTextField.text];
    
    [jsonString appendString:@"}"];

    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"json",nil];
    
    NSArray *values = [[NSArray alloc] initWithObjects:jsonString,nil];
    
    NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    NSString * serverCallRequest = [NSString stringWithFormat:@"%@%@", BASE_URL, @"mumblerUser/updateMyDetails.htm"];
    
    [manager GET:serverCallRequest parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        NSLog(@"MUMBLER CHAT loadUpdateProfile :%@",responseObject);
        NSString *status = [responseObject valueForKey:@"status"];
        
        if([status isEqualToString:@"success"])
        {
            NSLog(@"MUMBLER CHAT updateMyDetails SUCCESS");
            
            
            NSString *mumblerUserId = [[NSUserDefaults standardUserDefaults]
                                           valueForKey:MUMBLER_USER_ID];
            
            ///////////////CHAT
            
            NSError *error = nil;
            
            if( [[[self appDelegate] xmppStream] isConnected]){
                
                NSLog(@"isConnected to xmpp");
                
            }else{
                NSLog(@"Not Connected to xmpp");
                
                /*NSString *tjid = [NSString stringWithFormat:@"%@%@",[user valueForKey:@"userId"],MUMBLER_CHAT_EJJABBERD_SERVER_NAME];*/
                
                NSString *ejjabberedUsername = [NSString stringWithFormat:@"%@%@",mumblerUserId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
                NSLog(@"ejjabberedUsername %@",ejjabberedUsername);
                
                [[[self appDelegate] xmppStream]setMyJID:[XMPPJID jidWithString:ejjabberedUsername]];
                
                [[[self appDelegate] xmppStream] connectWithTimeout:XMPPStreamTimeoutNone error:&error];
                
            }
            
           
            
            ////////////////CHAT
            
            
            
            //Add Friends Screen..
            [[NSUserDefaults standardUserDefaults] setObject:ADD_FRIEND_FACEBOOK_TAB forKey:ADD_FRIEND_TAB_TO_SELECTED];
            [[NSUserDefaults standardUserDefaults] synchronize];
                        
            /*UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone_5s" bundle:nil];
            AddFriendsViewController *storyViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"AddFriendsViewController"];
            [self presentViewController:storyViewController animated:YES completion:nil];*/ //  present it
            
           /* NSString *signInState = [responseObject valueForKey:@"sign_in_state"];
            
            if ([signInState isEqualToString:@"complete"]) {
                NSDictionary *data = [responseObject valueForKey:@"data"];
                NSDictionary *mumblerUserDictionary= [data valueForKey:@"mumbler_user"];
                NSDictionary* mumblerUserSetting=[data valueForKey:@"mumbler_user_setting"];
                NSMutableArray *friendshipArray=[data valueForKey:@"friendships"];
                
                if ([friendshipArray count]>0) {
                    //Chat thread
                }else{
                    //Add Friends Screen
                }
                
            }else{
                NSLog(@"signInState not complete");
            }*/
            
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
    [self.navigationController setNavigationBarHidden:YES];
    
    
    [mobileNumberTextField setDelegate:self];
    [usernameTextField setDelegate:self];
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    mobileNumberTextField.inputAccessoryView = keyboardDoneButtonView;



    // Do any additional setup after loading the view.
}

- (IBAction)doneClicked:(id)sender
{
    NSLog(@"Done Clicked.");
    [self.view endEditing:YES];
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/////////////////////CHAT



- (ASAppDelegate *)appDelegate
{
	return (ASAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)myMethodStreamDidRegister{
    NSLog(@"my method fired====myMethodStreamDidRegister FAcebook sign in and register");
    
    //updating the v card after creating the user
    XMPPvCardCoreDataStorage *xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    XMPPvCardTempModule *xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^{
        
        
        ////////
        
        [xmppvCardTempModule  activate:[[self appDelegate] xmppStream]];
        
        
        XMPPvCardTemp *myvCardTemp = [xmppvCardTempModule myvCardTemp];
        if (!myvCardTemp) {
            NSLog(@"FACEBOOK SIGN UP-----updating vcard is not nil ,,,,,========");
            NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
            XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
            
            
            NSString *fbId = [[NSUserDefaults standardUserDefaults]
                              valueForKey:FB_USER_ID];
            
             NSString * imageUrlString = [NSString stringWithFormat:@"%@%@%@", @"http://graph.facebook.com/", fbId,@"/picture?type=large"];
            NSURL *bgImageURL = [NSURL URLWithString:imageUrlString];
            NSData *bgImageData = [NSData dataWithContentsOfURL:bgImageURL];
            
            [newvCardTemp setNickname:self.usernameTextField.text];
            [newvCardTemp setPhoto:bgImageData];
            [xmppvCardTempModule updateMyvCardTemp:newvCardTemp];
        }else{
            //Set Values as normal
            NSLog(@"FACEBOOK SIGN UP-----updating vcard nil========");
        }
        
    });
    
    if ([[self appDelegate] connect])
    {
        NSLog(@"Login logged in as FAcebook sign register== %@",[[[[self appDelegate] xmppStream] myJID] bare]);
        
        //if everything ok..add friends screen
        //Add Friends Screen..
        [[NSUserDefaults standardUserDefaults] setObject:ADD_FRIEND_FACEBOOK_TAB forKey:ADD_FRIEND_TAB_TO_SELECTED];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
       /* UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone_5s" bundle:nil];
        AddFriendsViewController *storyViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"AddFriendsViewController"];
        [self presentViewController:storyViewController animated:YES completion:nil]; //
        */
        
        
    } else
    {
        NSLog(@"Login logged in as FAcebook register== %@", @"No JID");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Unable to login to xmpp server as new user" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
    }
    
}
- (void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMethodDidNotRegister) name:@"didNotRegister" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMethodStreamDidRegister) name:@"xmppStreamDidRegister" object:nil];
    
    
}
-(void)myMethodDidNotRegister{
    NSLog(@"my method fired====myMethodDidNotRegister FAcebook sign in and register");
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
