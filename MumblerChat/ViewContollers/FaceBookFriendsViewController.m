//
//  FaceBookFriendsViewController.m
//  MumblerChat


#import "FaceBookFriendsViewController.h"
#import "FacebookSDK/FacebookSDK.h"
#import "FriendDao.h"
#import "MumblerFriendship.h"
#import "FriendTableViewCell.h"
#import "SVProgressHUD.h"
#import "AFHTTPRequestOperationManager.h"
#import "ASAppDelegate.h"
#import "User.h"

#define colorTheme [UIColor colorWithRed:233.0/255.0 green:153.0/255.0 blue:6.0/255.0 alpha:1]

@interface FaceBookFriendsViewController ()
{
    BOOL wasAutoLoggedOut;
    BOOL selectAllOptionFriendsUsingMumbler;
    BOOL selectAllOptionInviteFriends;
    ASAppDelegate *appDelegate;
    UIImageView *selectAllImageViewInviteFriends;
    UIImageView *selectAllImageViewFriendsWithMumbler;
    NSArray *searchResult;
    NSString *searchText;
    

}
@end

@implementation FaceBookFriendsViewController
@synthesize allFriendsData;
@synthesize sections;
@synthesize sectionWiseData;
@synthesize faceBookFriendsSearchBar;
@synthesize facebookFriendsTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/////////////Sarch Bar

- (void)filterContentForSearchText:(NSString*)search scope:(NSString*)scope
{
    
    NSLog(@"filterContentForSearchText");
    if (search != nil && search.length > 0) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", search];
        searchResult = [allFriendsData filteredArrayUsingPredicate:resultPredicate];
        [self showFBFriends:(NSMutableArray*)searchResult];
        [self.facebookFriendsTableView reloadData];
    }else{
        [self showFBFriends:allFriendsData];
        [self.facebookFriendsTableView reloadData];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)search {
    NSLog(@"textDidChange searchBar");
    [self filterContentForSearchText:search
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([facebookFriendsTableView isFirstResponder] && [touch view] != facebookFriendsTableView)
    {
        [facebookFriendsTableView resignFirstResponder];
    }
    if ([faceBookFriendsSearchBar isFirstResponder] && [touch view] != faceBookFriendsSearchBar)
    {
        [faceBookFriendsSearchBar resignFirstResponder];
    }
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    [faceBookFriendsSearchBar resignFirstResponder];
    
}


/////////////Search Bar Over

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad FaceBookFriendsViewController");
    
    [super viewDidLoad];
    searchResult=[[NSMutableArray alloc ]init];
    self.allFriendsData = [[NSMutableArray alloc] init];
    self.sectionWiseData = [[NSMutableDictionary alloc] init];
    self.sections = [[NSMutableArray alloc] init];
    
    appDelegate = (ASAppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.loginView.delegate = self;
    
    self.facebookFriendsTableView.dataSource=self;
    self.facebookFriendsTableView.delegate=self;
    self.facebookFriendsTableView.hidden=true;
    
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.loginView.delegate = nil;
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


- (void)loadFBFriends
{
    
    
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %lu friends", friends.count);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
            
        }
       
    }];
    
    
    
    FBRequest *request1 =  [FBRequest  requestWithGraphPath:@"user/friends"
                                                parameters:@{@"fields":@"id,name,picture"}
                                                HTTPMethod:@"GET"];
    [SVProgressHUD show];
    
    [request1 startWithCompletionHandler:^(FBRequestConnection *connection,
                                          id result,
                                          NSError *error){
        
        NSLog(@"USER FRIENDS FB REQUEST RESULT %@",result);
        
        
    }];

    
    //do the things normally
    //load user fb friends
    // FBRequest *request =  [FBRequest  requestWithGraphPath:@"me/friends"
    
    FBRequest *request =  [FBRequest  requestWithGraphPath:@"me/friends"
                                                parameters:@{@"fields":@"id,name,picture,installed"}
                                                    HTTPMethod:@"GET"];
    
    
    [SVProgressHUD show];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection,
                                          id result,
                                          NSError *error){
        
        NSLog(@"FB REQUEST RESULT %@",result);
        
        NSArray *tmpDataWithFBFriends =[result objectForKey:@"data"];
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        tmpDataWithFBFriends=[tmpDataWithFBFriends sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        
        [self.allFriendsData addObjectsFromArray:tmpDataWithFBFriends];
        [self showFBFriends:self.allFriendsData];
        [SVProgressHUD dismiss];
        [self.facebookFriendsTableView reloadData];
        
        
        
    }];
    
}

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    self.facebookFriendsTableView.hidden=false;
    
    NSLog(@"PROFILE NAME %@", user.name);
    NSLog(@"PROFILE ID %@", user.id);
    
    
    NSString *userFbId = [NSUserDefaults.standardUserDefaults
                          valueForKey:FB_USER_ID];
    
    NSLog(@"FB USER ID %@", userFbId);
    
    
    if(!wasAutoLoggedOut){
        NSLog(@"!wasAutoLoggedOut ");
        
        
        if(![user.id isEqualToString:userFbId]){
            
            NSLog(@"!wasAutoLoggedOut if");
            
            wasAutoLoggedOut=YES;
            [FBSession.activeSession closeAndClearTokenInformation];
            [FBSession.activeSession close];
            [FBSession setActiveSession:nil];
            self.facebookFriendsTableView.hidden=YES;
        }
        else{
            
            NSLog(@"!wasAutoLoggedOut  else");
            
            [self mergeFbMumblerUser:userFbId];
            [self loadFBFriends];
            
        }
    }else{
        NSLog(@"wasAutoLoggedOut ");
        
        [self mergeFbMumblerUser:userFbId];
        [self loadFBFriends];
    }
    
    
}


-(void) showFBFriends:(NSMutableArray *) fbFriends {
    [self.sections removeAllObjects];
    [self.sectionWiseData removeAllObjects];
    
    NSMutableArray *installed=[[NSMutableArray alloc] init];
    NSMutableArray *notInstalled=[[NSMutableArray alloc] init];
    
    for (NSDictionary<FBGraphUser> *friend in  fbFriends) {
        
        NSLog(@"FBGraphUser fbFriends");
        
        if ([friend objectForKey:@"installed" ] == nil) {
            if ([self.sections containsObject:@"Invite FB Friends to Mumbler"]) {
                
                [notInstalled addObject:friend];
                
            }else{
                [self.sections addObject:@"Invite FB Friends to Mumbler"];
                
                [notInstalled addObject:friend];
                
                
                [self.sectionWiseData setValue:notInstalled forKey:@"Invite FB Friends to Mumbler"];
            }
            
            
            
            
        } else {
            
            
            if ([self.sections containsObject:@"FB Friends on Mumbler"]) {
                
                [installed addObject:friend];
                
            }else{
                [self.sections addObject:@"FB Friends on Mumbler"];
                
                [installed addObject:friend];
                
                [self.sectionWiseData setValue:installed forKey:@"FB Friends on Mumbler"];
            }
            
        }
        
        
    }
    NSUserDefaults *userDefault = NSUserDefaults.standardUserDefaults;
    NSString *mumblerUserId=[userDefault valueForKey:MUMBLER_USER_ID];
    FriendDao *friendDao=[[FriendDao alloc]init];
    NSArray *tmpAllFriends=[friendDao getFriendships:mumblerUserId ];
    
    for (MumblerFriendship *mumblerFriend in  tmpAllFriends) {
     for (int x=0; x<installed.count; x++) {
     
     NSDictionary<FBGraphUser> *friend=installed[x];
     if ([mumblerFriend.friendMumblerUser.userFBId isEqualToString: [friend objectForKey:@"id"]
     ]) {
     
     [installed removeObject:friend];
     
     }
     }
     }
    [self.sectionWiseData setValue:installed forKey:@"FB Friends on Mumbler"];
    NSLog(@"installed.........%@",installed);
    [self.facebookFriendsTableView reloadData];
    
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@" %lu ", (unsigned long)[self.sections count]);
    return [self.sections count];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *sectionHeader = [self.sections objectAtIndex:section];
    
    NSLog(@"numberOfRowsInSection %lu %@ ", (unsigned long)[[self.sectionWiseData valueForKey:sectionHeader] count], sectionHeader);
    
    return [[self.sectionWiseData valueForKey:sectionHeader] count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return 70;
    }
    else
    {
        return 55;
    }
    
}


-(IBAction)imageTappedFriendsWithMumbler:(id)sender{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    if(!selectAllOptionFriendsUsingMumbler){
        DDLogVerbose(@"%@: %@: !selectAllOptionFriendsUsingMumbler ", THIS_FILE, THIS_METHOD);
        selectAllOptionFriendsUsingMumbler=true;
        [selectAllImageViewFriendsWithMumbler setImage:[UIImage imageNamed:@"check"]];
    }else{
        
        DDLogVerbose(@"%@: %@: untick selectAllOptionFriendsUsingMumbler ", THIS_FILE, THIS_METHOD);
        
        selectAllOptionFriendsUsingMumbler=false;
        [selectAllImageViewFriendsWithMumbler setImage:[UIImage imageNamed:@"uncheck"]];
        
        /*if ([appDelegate.friendsToBeAddedDictionary count] > 0) {
            
            [appDelegate.friendsToBeAddedDictionary removeAllObjects];
            
        }*/
        
    }
    [self.facebookFriendsTableView reloadData];
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
    
}

-(IBAction)imageTappedInviteFriends:(id)sender{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    if(!selectAllOptionInviteFriends){
        DDLogVerbose(@"%@: %@: !selectAllOptionInviteFriends ", THIS_FILE, THIS_METHOD);
        selectAllOptionInviteFriends=true;
        [selectAllImageViewInviteFriends setImage:[UIImage imageNamed:@"check"]];
        [selectAllImageViewInviteFriends layoutIfNeeded];
    }else{
        DDLogVerbose(@"%@: %@: untick selectAllOptionInviteFriends ", THIS_FILE, THIS_METHOD);
        selectAllOptionInviteFriends=false;
        [selectAllImageViewInviteFriends setImage:[UIImage imageNamed:@"uncheck"]];
        [selectAllImageViewInviteFriends layoutIfNeeded];
        
        /*if (appDelegate.addedFriendsInContactsSelectedForSendingText > 0) {
            
            [appDelegate.addedFriendsInContactsSelectedForSendingText removeAllObjects];
            
        }*/
        
    }
    [self.facebookFriendsTableView reloadData];
    
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [self.sections objectAtIndex:section];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 25)];
    [headerView setBackgroundColor:colorTheme];
    
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 0, 320, 18);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor grayColor];
    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    UILabel *labelSelectAll = [[UILabel alloc] init];
    labelSelectAll.frame = CGRectMake(220, 2.5, 60, 18);
    labelSelectAll.backgroundColor = [UIColor clearColor];
    labelSelectAll.textColor = [UIColor whiteColor];
    labelSelectAll.shadowColor = [UIColor grayColor];
    labelSelectAll.shadowOffset = CGSizeMake(-1.0, 1.0);
    labelSelectAll.font = [UIFont boldSystemFontOfSize:12];
    labelSelectAll.text = @"Select All";
    

    if([sectionTitle isEqualToString:@"FB Friends on Mumbler"]){
        
        selectAllImageViewFriendsWithMumbler= [[UIImageView alloc] init];
        selectAllImageViewFriendsWithMumbler.frame = CGRectMake(290, 2.5, 30, 18);
        if(selectAllOptionFriendsUsingMumbler){
            selectAllImageViewFriendsWithMumbler.image=[UIImage imageNamed:@"check"];
        }else{
            selectAllImageViewFriendsWithMumbler.image=[UIImage imageNamed:@"uncheck"];
        }
        
        [selectAllImageViewFriendsWithMumbler setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTappedFriendsWithMumbler:)];
        [selectAllImageViewFriendsWithMumbler addGestureRecognizer:tap];
        
        
        [headerView addSubview:labelSelectAll];
        
        [headerView addSubview:label];
        
        [headerView addSubview:selectAllImageViewFriendsWithMumbler];
        
    }else{
        
        
        
        selectAllImageViewInviteFriends= [[UIImageView alloc] init];
        selectAllImageViewInviteFriends.frame = CGRectMake(290, 2.5, 30, 18);
        
        if(selectAllOptionInviteFriends){
            
            selectAllImageViewInviteFriends.image=[UIImage imageNamed:@"check"];
        }else{
            selectAllImageViewInviteFriends.image=[UIImage imageNamed:@"uncheck"];
        }
        
        [selectAllImageViewInviteFriends setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTappedInviteFriends:)];
        [selectAllImageViewInviteFriends addGestureRecognizer:tap1];
        
        
        [headerView addSubview:labelSelectAll];
        
        [headerView addSubview:label];
        
        [headerView addSubview:selectAllImageViewInviteFriends];
        
    }

    
    return headerView;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableIdentifier = @"FaceBookCell";
    
    FriendTableViewCell *tablecell = (FriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    tablecell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSString *sectionHeader = [self.sections objectAtIndex:indexPath.section];
    
    NSArray *dataInSection = [self.sectionWiseData objectForKey:sectionHeader];
    
    NSDictionary<FBGraphUser>*friend = [dataInSection objectAtIndex:indexPath.row];
    
    NSLog(@"friend %@ ", friend);
    
    
    tablecell.displayNameOne.text=friend.name;
    tablecell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSLog(@"name %@ ", friend.name);
    tablecell.mumblerUser =friend;
    
    
    if([sectionHeader isEqualToString:@"FB Friends on Mumbler"]){
        
        NSString *selectedFBUserId =[NSString stringWithFormat:@"%@",[friend valueForKey:@"id"]];
        
        
        if (![appDelegate.addedFriendsInFaceBook containsObject:selectedFBUserId]) {
            //ash fb friends using mumbler
            tablecell.friendCellType=FriendCellTypeFBFriendsWithMumbler;
            
        }else{
            //already added friends using mumbler
            tablecell.friendCellType=FriendCellTypeFBAddedFriendsWithMumbler;
            
        }
        
       
        
    }else{
        tablecell.friendCellType=FriendCellTypeFBInviteFriendsToMumbler;
        
    }
    
    return tablecell;
    
}



// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"loginViewShowingLoggedInUser");
    self.facebookFriendsTableView.hidden=false;
    
    
}

// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"loginViewShowingLoggedOutUser");
      wasAutoLoggedOut=YES;
    self.facebookFriendsTableView.hidden=true;
}


// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user Tapped FBErrorUtility");
        
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
