#import "CustomTabController.h"
#import "ASAppDelegate.h"
#import "SVProgressHUD.h"
#import <UIKit/UIKit.h>
#import "MumblerFriendship.h"
#import "Constants.h"
#import "FriendDao.h"

#import "User.h"
#import "AFHTTPRequestOperationManager.h"
#import "SVProgressHUD.h"
#import "SBJson.h"

@interface CustomTabController (){
    
    ASAppDelegate *appDelegate;
    
}

@end

@implementation CustomTabController

@synthesize btn1, btn2, btn3;
@synthesize isFromSignUp;


- (ASAppDelegate *)appDelegate
{
	return (ASAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void) getFbFriendsMumblerUserIds{
 
    
    NSDictionary *fbIdsNSDic = [NSDictionary dictionaryWithObjectsAndKeys:
                        appDelegate.addedFriendsInFaceBook, @"fbIds",
                        nil];
    NSLog(@"fb friends to server -=== %@",[fbIdsNSDic JSONRepresentation]);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"json":[fbIdsNSDic JSONRepresentation]};
    NSString *url=[NSString stringWithFormat:@"%@%@",BASE_URL,@"mumblerUser/getMumblerUsersForFbIds.htm"];
    
 [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
 
 [SVProgressHUD dismiss];
 
 DDLogVerbose(@"%@: %@: getMumblerUsersForFbIds responseObject=%@ ", THIS_FILE, THIS_METHOD,responseObject);
     
     NSString *status = [responseObject valueForKey:@"status"];
     
     if([status isEqualToString:@"success"])
     {
         NSDictionary *data = [responseObject valueForKey:@"data"];
         NSMutableArray *mumblerUsersArray=[data valueForKey:@"mumbler_users"]
         ;
         
          DDLogVerbose(@"%@: %@: mumblerUsersArray =%@", THIS_FILE, THIS_METHOD,mumblerUsersArray);
         
         if(mumblerUsersArray.count > 0){
              [self  getMumblerUserObjectsForFBFriends:mumblerUsersArray];
         }else{
              DDLogVerbose(@"%@: %@: EmptyArray with FBID", THIS_FILE, THIS_METHOD);
             if([appDelegate.friendsToBeAddedDictionary count]>0){
                 
                 [NSUserDefaults.standardUserDefaults setBool:true forKey:IS_FRIENDS_ADDED];
                 
                 [NSUserDefaults.standardUserDefaults synchronize];
                 
                 /*[self performSelectorInBackground:@selector(updateAddedFriends:) withObject:self];*/
                 
                 
                 [NSUserDefaults.standardUserDefaults setBool:true forKey:IS_FRIENDS_ADDED];
                 
                 [NSUserDefaults.standardUserDefaults synchronize];
                 
                 double delayInSeconds = 0.25;
                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                     // code to be executed on the main queue after delay
                     [self updateAddedFriends];
                     
                 });
                 
                 // [self performSegueWithIdentifier:@"leftFriendsView" sender:self];
                 
             }
             
         }
         
        
         
         
     }
 
 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 DDLogVerbose(@"%@: %@: Error =%@", THIS_FILE, THIS_METHOD,error);
 [SVProgressHUD dismiss];
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:[error localizedDescription] delegate:self
 cancelButtonTitle:@"OK" otherButtonTitles: nil];
 
 [alert show];
 
 }];

 
 }

-(void) getMumblerUserObjectsForFBFriends:(NSMutableArray *) fbFriends {
    
    for (NSDictionary*friend in  fbFriends) {
        
        NSLog(@"getMumblerUserObjectsForFBFriends fbFriends");
        
        if ([friend objectForKey:@"mumblerUserId"] != nil && [friend objectForKey:@"alias"] != nil ) {
            
            NSString * userId=[friend objectForKey:@"mumblerUserId"];
            
            //added friends
            if([appDelegate.friendsToBeAddedDictionary objectForKey:userId] == nil){
                NSLog(@"ADDING FB FRIEND OBJECT%@",friend);
                [appDelegate.friendsToBeAddedDictionary setObject:friend forKey:userId];
            }
        }else{
            NSLog(@"FRIEND DATA IS NOT THERE");
            
        }

    }
    
    //Calling Friend Dao
    if([appDelegate.friendsToBeAddedDictionary count]>0){
        
        [NSUserDefaults.standardUserDefaults setBool:true forKey:IS_FRIENDS_ADDED];
        
        [NSUserDefaults.standardUserDefaults synchronize];
        
       // [self performSelectorInBackground:@selector(updateAddedFriends:) withObject:self];
        
        double delayInSeconds = 0.25;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // code to be executed on the main queue after delay
            [self updateAddedFriends];
            
        });
        
        //[self performSegueWithIdentifier:@"leftFriendsView" sender:self];
        
        
    }
    
}

-(void)updateAddedFriends{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    FriendDao *objFriendsDao=[[FriendDao alloc]init];
    [objFriendsDao addFriendships];
    [self addFriendsToEjabberedServer];
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
    
}

-(void)addFriendsToEjabberedServer{
    
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    for(id key in appDelegate.friendsToBeAddedDictionary) {
        id value = [appDelegate.friendsToBeAddedDictionary objectForKey:key];
        
        NSString *selectedUserId =[NSString stringWithFormat:@"%@",[value valueForKey:@"mumblerUserId"]];
        
        NSString *selectedUseName =[NSString stringWithFormat:@"%@",[value valueForKey:@"alias"]];

        selectedUserId=[NSString stringWithFormat:@"%@%@",selectedUserId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
        
        XMPPJID *newBuddy = [XMPPJID jidWithString:selectedUserId];
        [[[self appDelegate] xmppRoster] addUser:newBuddy withNickname:selectedUseName];
        
        DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
        
    }
    
}

///////////Send Text
- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init] ;
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = bodyOfMessage;
        controller.recipients = recipients;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)sendTextMessagesForSelectedContacts
{
    NSArray *selectedPhoneNumbers=[appDelegate.inviteFriendsInContactsDictionary allKeys];
    
    NSString *alias = [NSUserDefaults.standardUserDefaults
                          valueForKey:USERNAME];
    
    [self sendSMS:[NSString stringWithFormat:@"Add me on Mumbler Chat! Username %@ http://mumblerchat.com/", alias] recipientList:selectedPhoneNumbers];
    
}

///////////Send Text Over


-(IBAction)swipeLeft:(id)sender{
    
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    //Sending Text Messages
    if([appDelegate.inviteFriendsInContactsDictionary count]>0){
        [self sendTextMessagesForSelectedContacts];
    }
    
    
    //Add Friends Methods
    if(appDelegate.addedFriendsInFaceBook.count > 0){
        
        [self getFbFriendsMumblerUserIds];
    }else{
        if([appDelegate.friendsToBeAddedDictionary count]>0){
            
            DDLogVerbose(@"%@: %@: START appDelegate.friendsToBeAddedDictionary count]>0", THIS_FILE, THIS_METHOD);
            
            
            [NSUserDefaults.standardUserDefaults setBool:true forKey:IS_FRIENDS_ADDED];
            
            [NSUserDefaults.standardUserDefaults synchronize];
            
            double delayInSeconds = 0.25;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // code to be executed on the main queue after delay
                [self updateAddedFriends];
                
            });
            
            // [self performSegueWithIdentifier:@"leftFriendsView" sender:self];
            
            //[self performSelectorInBackground:@selector(updateAddedFriends:) withObject:self];
            
        }
    }
    
    [self performSegueWithIdentifier:@"leftFriendsView" sender:self];
    
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
    
}
-(IBAction)swipeRight:(id)sender{
    
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
}

- (void)viewDidLoad
{
    NSLog(@"viewdidload custom----");
    
    [super viewDidLoad];
    self.tabBar.hidden = YES;
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipe.direction = (UISwipeGestureRecognizerDirectionLeft);
    [self.view addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipe.direction = (UISwipeGestureRecognizerDirectionRight);
    [self.view addGestureRecognizer:rightSwipe];
    
    appDelegate = (ASAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self addCustomElements];
    
   
    /*if (self.isFromSignUp) {
        
        NSLog(@"isfromsignup");
        [self.navigationItem setHidesBackButton:YES animated:NO];
        UIButton *btnForward = [UIButton buttonWithType:UIButtonTypeCustom];
        btnForward.frame = CGRectMake(0, 0, 18, 32);
        [btnForward setImage:[UIImage imageNamed:@"mumbler_forward.png"] forState:UIControlStateNormal];
        [btnForward addTarget:self action:@selector(actionForward:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnForward];
        
        UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
                                                         initWithTarget:self
                                                         action:@selector(oneFingerSwipeRight:)];
        [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [[self view] addGestureRecognizer:oneFingerSwipeRight];
        
        
    }else{
        
        UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBack.frame = CGRectMake(0, 0, 18, 32);
        [btnBack setImage:[UIImage imageNamed:@"mumbler_back_btn.png"] forState:UIControlStateNormal];
        [btnBack addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
        UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(oneFingerSwipeLeft:)];
        [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [[self view] addGestureRecognizer:oneFingerSwipeLeft];
        
        
    }*/
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addCustomElements
{
	// Initialise our two images
    
	[self.tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"white_back"]];
	self.btn1 = [UIButton buttonWithType:UIButtonTypeCustom]; //Setup the button
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        NSLog(@"SYSTEM_VERSION_LESS_THAN 7.0");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            btn1.frame = CGRectMake(0, SCREEN_HEIGHT-TAB_BAR_HEIGHT- placement-6, SCREEN_WIDTH/3, TAB_BAR_HEIGHT+6); // Set the frame (size and position) of the button)
            
        }else{
            
           /* btn1.frame = CGRectMake(0, SCREEN_HEIGHT-TAB_BAR_HEIGHT- placement, SCREEN_WIDTH/3, TAB_BAR_HEIGHT); // Set the frame (size and position) of the button)*/
            
             btn1.frame = CGRectMake(0, SCREEN_HEIGHT-TAB_BAR_HEIGHT, SCREEN_WIDTH/3, TAB_BAR_HEIGHT); // Set the frame (size and position) of the button)
        }
        
        
    }else{
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            btn1.frame = CGRectMake(0, SCREEN_HEIGHT-TAB_BAR_HEIGHT- placement-6, SCREEN_WIDTH/3, TAB_BAR_HEIGHT+6); // Set the frame (size and position) of the button)
            
        }else{
            
            /*btn1.frame = CGRectMake(0, SCREEN_HEIGHT-TAB_BAR_HEIGHT- placement, SCREEN_WIDTH/3, TAB_BAR_HEIGHT); // Set the frame (size and position) of the button)*/
             btn1.frame = CGRectMake(0, SCREEN_HEIGHT-TAB_BAR_HEIGHT, SCREEN_WIDTH/3, TAB_BAR_HEIGHT); // Set the frame (size and position) of the button)
        }
    }
    
    btn1View = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"facebook_.png"]];
    btn1View.frame = CGRectMake(0, 0, 50, 50);
    if (SCREEN_HEIGHT > 568) {
        
        btn1View.center = CGPointMake(btn1.frame.size.height*2.5, btn1.frame.size.height/2);
        
    }else{
        
        btn1View.center = CGPointMake(btn1.frame.size.height, btn1.frame.size.height/2);
    }
    // [btn1 setTitleEdgeInsets:UIEdgeInsetsMake(25, btn1View.frame.size.width, 0, 0)];
    //[btn1 setBackgroundColor:[UIColor whiteColor]];
    // [btn1 addSubview:btn1View];
    
  	[btn1 setTag:0]; // Assign the button a "tag" so when our "click" event is called we know which button was pressed.
    //	[btn1 setSelected:true]; // Set this button as selected (we will select the others to false as we only want Tab 1 to be selected initially
	
	// Now we repeat the process for the other buttons
    
	self.btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            btn2.frame = CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT-TAB_BAR_HEIGHT-placement-6, SCREEN_WIDTH/3, TAB_BAR_HEIGHT+6);
            
        }else{
            
           /* btn2.frame = CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT-TAB_BAR_HEIGHT-placement, SCREEN_WIDTH/3, TAB_BAR_HEIGHT);*/
            
            
            btn2.frame = CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT-TAB_BAR_HEIGHT, SCREEN_WIDTH/3, TAB_BAR_HEIGHT);
        }
    }else{
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            btn2.frame = CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT-TAB_BAR_HEIGHT-placement-6, SCREEN_WIDTH/3, TAB_BAR_HEIGHT+6);
            
        }else{
            
            btn2.frame = CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT-TAB_BAR_HEIGHT, SCREEN_WIDTH/3, TAB_BAR_HEIGHT);
            
        }
    }
    
    
    btn2View = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contacts_"]];
    btn2View.frame = CGRectMake(0, 0, 50, 50);
    if (SCREEN_HEIGHT > 568) {
        btn2View.center = CGPointMake(btn2.frame.size.height*2.5, btn2.frame.size.height/2);
    }else{
        btn2View.center = CGPointMake(btn2.frame.size.height, btn2.frame.size.height/2);
    }
    //    [btn2 setTitleEdgeInsets:UIEdgeInsetsMake(0, btn2View.frame.size.width, 0, 0)];
    // [btn2 setBackgroundColor:[UIColor whiteColor]];
    
    // [btn2 addSubview:btn2View];
    
	[btn2 setTag:1];
    
    
    self.btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            btn3.frame = CGRectMake(SCREEN_WIDTH/1.5, SCREEN_HEIGHT-TAB_BAR_HEIGHT-placement-6, SCREEN_WIDTH/3, TAB_BAR_HEIGHT+6);
        }else{
            
            /*btn3.frame = CGRectMake(SCREEN_WIDTH/1.5, SCREEN_HEIGHT-TAB_BAR_HEIGHT-placement, SCREEN_WIDTH/3, TAB_BAR_HEIGHT);*/
            
             btn3.frame = CGRectMake(SCREEN_WIDTH/1.5, SCREEN_HEIGHT-TAB_BAR_HEIGHT, SCREEN_WIDTH/3, TAB_BAR_HEIGHT);
            
        }
    }else{
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            btn3.frame = CGRectMake(SCREEN_WIDTH/1.5, SCREEN_HEIGHT-TAB_BAR_HEIGHT-placement-6, SCREEN_WIDTH/3, TAB_BAR_HEIGHT+6);
        }else{
            
            btn3.frame = CGRectMake(SCREEN_WIDTH/1.5, SCREEN_HEIGHT-TAB_BAR_HEIGHT, SCREEN_WIDTH/3, TAB_BAR_HEIGHT);
            
        }
        
    }
    //    [btn3 setTitle:@"Search" forState:UIControlStateNormal];
    //    [btn3.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    //    [btn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    //    [btn3 setTitleColor:[UIColor colorWithRed:(255/255.0) green:(197/255.0) blue:(100/255.0) alpha:1.0] forState:UIControlStateNormal];
    
    btn3View = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_"]];
    btn3View.frame = CGRectMake(0, 0, 50, 50);
    if (SCREEN_HEIGHT > 568) {
        btn3View.center = CGPointMake(btn3.frame.size.height*2.5, btn3.frame.size.height/2);
    }else{
        btn3View.center = CGPointMake(btn3.frame.size.height, btn3.frame.size.height/2);
    }
    //    [btn3 setTitleEdgeInsets:UIEdgeInsetsMake(0, btn3View.frame.size.width, 0, 0)];
    
    //[btn3 addSubview:btn3View];
	
	[btn3 setTag:2];
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        [self.btn1 setBackgroundImage:[UIImage imageNamed:@"facebook_.png"] forState:UIControlStateNormal];
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"contacts_.png"] forState:UIControlStateNormal];
        [self.btn3 setBackgroundImage:[UIImage imageNamed:@"search_.png"] forState:UIControlStateNormal];
        [self.btn1 setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateHighlighted];
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"contacts.png"] forState:UIControlStateHighlighted];
        [self.btn3 setBackgroundImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateHighlighted];
        
    }else{
        [self.btn1 setBackgroundImage:[UIImage imageNamed:@"facebook_.png"] forState:UIControlStateNormal];
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"contacts_.png"] forState:UIControlStateNormal];
        [self.btn3 setBackgroundImage:[UIImage imageNamed:@"search_.png"] forState:UIControlStateNormal];
        [self.btn1 setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateHighlighted];
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"contacts.png"] forState:UIControlStateHighlighted];
        [self.btn3 setBackgroundImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateHighlighted];

        
        /*[self.btn1 setBackgroundImage:[UIImage imageNamed:@"btn1_ipad@2x.png"] forState:UIControlStateNormal];
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"btn2_ipad@2x.png"] forState:UIControlStateNormal];
        [self.btn3 setBackgroundImage:[UIImage imageNamed:@"btn3_ipad@2x.png"] forState:UIControlStateNormal];
        [self.btn1 setBackgroundImage:[UIImage imageNamed:@"selbtn1_ipad@2x.png"] forState:UIControlStateHighlighted];
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"selbtn2_ipad@2x.png"] forState:UIControlStateHighlighted];
        [self.btn3 setBackgroundImage:[UIImage imageNamed:@"selbtn3_ipad@2x.png"] forState:UIControlStateHighlighted];*/
        
        
    }
    
    //auto layout///
    /*btn1.translatesAutoresizingMaskIntoConstraints=YES;
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:btn1
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view.superview
                                                                  attribute:NSLayoutAttributeLeading
                                                                 multiplier:20
                                                                   constant:100];
    
    [btn1 addConstraint:constraint];*/
    
    
	// Add my new buttons to the view
    [self.view addSubview:btn1];
    [self.view addSubview:btn2];
   	[self.view addSubview:btn3];
    
    // Setup event handlers so that the buttonClicked method will respond to the touch up inside event.
	[btn1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn2 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn3 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
}

- (void)buttonClicked:(id)sender
{
    NSLog(@"buttonClicked");
	int tagNum = [(UIButton*)sender tag];
    
    NSLog(@"buttonClicked tagNum %i",tagNum);
    
    [self.tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"white_back"]];
    //[self.tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"selectedTabBar.png"]];
	[self selectTab:tagNum];
}
- (void)actionBack:(id)sender {
    NSLog(@"actionBack from custom tabbar");
    
    //    if (!self.isFromSignUp) {
    //
    //       // [self.navigationController popViewControllerAnimated:YES];
    //         [self performSegueWithIdentifier:@"loadFriendFromTabbar" sender:self];
    //    }else{
    //
    [self performSegueWithIdentifier:@"loadFriendFromTabbar" sender:self];
    
    //}
    
    
}
- (void)selectTab:(int)tabID
{
	switch(tabID)
	{
		case 0:
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self.btn1 setBackgroundImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
                [self.btn2 setBackgroundImage:[UIImage imageNamed:@"contacts_"] forState:UIControlStateNormal];
                [self.btn3 setBackgroundImage:[UIImage imageNamed:@"search_"] forState:UIControlStateNormal];
            }else{
                [self.btn1 setBackgroundImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
                [self.btn2 setBackgroundImage:[UIImage imageNamed:@"contacts_"] forState:UIControlStateNormal];
                [self.btn3 setBackgroundImage:[UIImage imageNamed:@"search_"] forState:UIControlStateNormal];
                
                
            }
            
            
            
			break;
            
		case 1:
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self.btn2 setBackgroundImage:[UIImage imageNamed:@"contacts"] forState:UIControlStateNormal];
                [self.btn1 setBackgroundImage:[UIImage imageNamed:@"facebook_"] forState:UIControlStateNormal];
                [self.btn3 setBackgroundImage:[UIImage imageNamed:@"search_"] forState:UIControlStateNormal];
            }else{
                [self.btn2 setBackgroundImage:[UIImage imageNamed:@"contacts"] forState:UIControlStateNormal];
                [self.btn1 setBackgroundImage:[UIImage imageNamed:@"facebook_"] forState:UIControlStateNormal];
                [self.btn3 setBackgroundImage:[UIImage imageNamed:@"search_"] forState:UIControlStateNormal];
            }
            
			break;
		case 2:
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self.btn3 setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
                [self.btn2 setBackgroundImage:[UIImage imageNamed:@"contacts_"] forState:UIControlStateNormal];
                [self.btn1 setBackgroundImage:[UIImage imageNamed:@"facebook_"] forState:UIControlStateNormal];
                
            }else{
                
                [self.btn3 setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
                [self.btn2 setBackgroundImage:[UIImage imageNamed:@"contacts_"] forState:UIControlStateNormal];
                [self.btn1 setBackgroundImage:[UIImage imageNamed:@"facebook_"] forState:UIControlStateNormal];
                
                
            }
			break;
    }
	
	self.selectedIndex = tabID;
    
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    /*if (result==MessageComposeResultSent) {
        
        NSLog(@"messageComposeViewController/didFinishWithResult");
        
        NSMutableString *jsonString=[[NSMutableString alloc] init];
        [jsonString appendFormat:@"{"];
        [jsonString appendFormat:@"\"inviteType\":\"%@\",", @"CONTACT"];
        if (appDelegate.isASignup) {
            
            appDelegate.isASignup=NO;
            [jsonString appendFormat:@"\"invitedStage\":\"%@\",", @"INITIAL"];
            
        }else{
            
            [jsonString appendFormat:@"\"invitedStage\":\"%@\",", @"OTHER"];
            
        }
        
        [jsonString appendFormat:@"\"inviteReferences\":\"%@\"", [self getCollectionOfInvites]];
        [jsonString appendFormat:@"}"];
        
        NSLog(@"createInvite Json---%@",jsonString);
        
        NSDictionary *dictionary=[NSDictionary dictionaryWithObjects:@[jsonString] forKeys:@[@"json"]];
        
        [[JSONHTTPClient sharedClient] getPath:@"mumblerUser/createInvite.htm?" parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"createInvite.htm--------%@",responseObject);
            [appDelegate.friendsToBeInvitedFromContactDictionary removeAllObjects];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [appDelegate.friendsToBeInvitedFromContactDictionary removeAllObjects];
        }];
        
        
        //////////
        
        if ([appDelegate.friendsToBeInvitedFromFacebookDictionary count] > 0) {
            
            NSArray *fIDs=[appDelegate.friendsToBeAddedFromSearchDictionary allKeys];
            NSMutableDictionary* params =   [[NSMutableDictionary alloc]init];
            for (NSString *fid in fIDs) {
                [params setObject:fid forKey:fid];
            }
            
            [FBWebDialogs presentRequestsDialogModallyWithSession:nil message:@"Invite message" title:nil parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                
                
                if (!error) {
                    NSLog(@"FB Invites sent successfully");
                    
                    [self performSegueWithIdentifier:@"loadFriendFromTabbar" sender:self];
                    
                    NSMutableString *jsonString=[[NSMutableString alloc] init];
                    [jsonString appendFormat:@"{"];
                    [jsonString appendFormat:@"\"inviteType\":\"%@\",", @"FACEBOOK"];
                    
                    if (appDelegate.isASignup) {
                        
                        appDelegate.isASignup=NO;
                        [jsonString appendFormat:@"\"invitedStage\":\"%@\",", @"INITIAL"];
                        
                    }else{
                        
                        [jsonString appendFormat:@"\"invitedStage\":\"%@\",", @"OTHER"];
                        
                    }
                    
                    [jsonString appendFormat:@"\"inviteReferences\":\"%@\"", [self getCollectionOfInvites]];
                    [jsonString appendFormat:@"}"];
                    
                    NSLog(@"createInvite Json---%@",jsonString);
                    
                    NSDictionary *dictionary=[NSDictionary dictionaryWithObjects:@[jsonString] forKeys:@[@"json"]];
                    
                    [[JSONHTTPClient sharedClient] getPath:@"mumblerUser/createInvite.htm?" parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        
                        NSLog(@"createInvite.htm--------%@",responseObject);
                        [appDelegate.friendsToBeInvitedFromFacebookDictionary removeAllObjects];
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        
                        [appDelegate.friendsToBeInvitedFromFacebookDictionary removeAllObjects];
                        
                    }];
                    
                    
                } else {
                    NSLog(@"FB Invites were not sent");
                }
                
                
                
            }];
            
            
            
        } else {
            
            [self performSegueWithIdentifier:@"loadFriendFromTabbar" sender:self];
            
        }
        
    }*/
}




- (void)oneFingerSwipeLeft:(UITapGestureRecognizer *)recognizer {
    
    NSLog(@"oneFingerSwipeLeft  CustomTabBarViewController");
    
   /* if ([appDelegate.friendsToBeInvitedFromContactDictionary count]>0) {
        
        
        NSArray *phoneNumbers=[appDelegate.friendsToBeInvitedFromContactDictionary allKeys];
        NSString *alias = appDelegate.mumblerUser.alias;
        [self sendSMS:[NSString stringWithFormat:@"Add me on Mumbler Chat! Username %@ http://mumblerchat.com/", alias] recipientList:phoneNumbers];
        
    } else if ([appDelegate.friendsToBeInvitedFromFacebookDictionary count] > 0) {
        
        
        NSArray *fIDs=[appDelegate.friendsToBeInvitedFromFacebookDictionary allKeys];
        NSMutableDictionary* params =   [[NSMutableDictionary alloc]init];
        int f=0;
        for (NSString *fid in fIDs) {
            
            NSString *newKey = [NSString stringWithFormat:@"to[%i]",f];
            NSLog(@"new key ..........%@",newKey);
            [params setObject:fid forKey:newKey];
            f++;
        }
        
        
        [FBWebDialogs presentRequestsDialogModallyWithSession:nil message:@"Come Join Mumbler Chat" title:@"Mumbler Chat" parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
            
            
            if (!error) {
                NSLog(@"FB Invites sent successfully");
                
                [self performSegueWithIdentifier:@"loadFriendFromTabbar" sender:self];
                ///////
                NSMutableString *jsonString=[[NSMutableString alloc] init];
                [jsonString appendFormat:@"{"];
                [jsonString appendFormat:@"\"inviteType\":\"%@\",", @"FACEBOOK"];
                if (appDelegate.isASignup) {
                    appDelegate.isASignup=NO;
                    [jsonString appendFormat:@"\"invitedStage\":\"%@\",", @"INITIAL"];
                    
                }else{
                    
                    [jsonString appendFormat:@"\"invitedStage\":\"%@\",", @"OTHER"];
                    
                }
                
                [jsonString appendFormat:@"\"inviteReferences\":%@", [self getCollectionOfInvites]];
                [jsonString appendFormat:@"}"];
                
                NSLog(@"createInvite Json---%@",jsonString);
                
                NSDictionary *dictionary=[NSDictionary dictionaryWithObjects:@[jsonString] forKeys:@[@"json"]];
                
                [[JSONHTTPClient sharedClient] getPath:@"mumblerUser/createInvite.htm?" parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSLog(@"createInvite.htm--------%@",responseObject);
                    [appDelegate.friendsToBeInvitedFromFacebookDictionary removeAllObjects];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"createInvite.htm- failed-------%@",error);
                    [appDelegate.friendsToBeInvitedFromFacebookDictionary removeAllObjects];
                }];
                
                
            } else {
                NSLog(@"FB Invites were not sent");
            }
            
            
            
        }];
        
        
        
        
    } else {
        
        [self performSegueWithIdentifier:@"loadFriendFromTabbar" sender:self];
        
    }*/
    
    
    
    
}

/*-(NSString *)getCollectionOfInvites{
    
    NSLog(@"getCollectionOfInvites------%i",[appDelegate.friendsToBeInvitedFromFacebookDictionary count]);
    
    NSMutableArray *invites=[[NSMutableArray alloc] init];
    
    if ([appDelegate.friendsToBeInvitedFromFacebookDictionary count]>0) {
        
        NSEnumerator *enumerator=[appDelegate.friendsToBeInvitedFromFacebookDictionary objectEnumerator];
        id value;
        while (value=[enumerator nextObject]) {
            
            NSLog(@"enumaertd Value---%@",value);
            NSDictionary *dictionary=(NSDictionary*)value;
            [invites addObject:[dictionary objectForKey:@"id"]];
            
        }
        
        NSError *error;
        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:invites options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
        return jsonString;
        
    }
    
    if([appDelegate.friendsToBeInvitedFromContactDictionary count]>0){
        
        NSEnumerator *enumerator=[appDelegate.friendsToBeInvitedFromContactDictionary objectEnumerator];
        id value;
        while (value=[enumerator nextObject]) {
            
            NSLog(@"enumaertd Value---%@",value);
            NSDictionary *dictionary=(NSDictionary*)value;
            [invites addObject:[dictionary objectForKey:@"phoneNumber"]];
            
            
        }
        
        NSError *error;
        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:invites options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    
    
    return nil;
}*/



@end
