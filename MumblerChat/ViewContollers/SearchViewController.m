//
//  SearchViewController.m
//  MumblerChat
//


#import "SearchViewController.h"
#import "ASAppDelegate.h"
#import "AFHTTPRequestOperationManager.h"
#import "SVProgressHUD.h"
#import <AdSupport/AdSupport.h>
#import "Constants.h"
#import "FriendTableViewCell.h"

#import "FriendsUtils.h"

#import "NSDictionary+JSON.h"

#define colorTheme [UIColor colorWithRed:233.0/255.0 green:153.0/255.0 blue:6.0/255.0 alpha:1]

typedef enum _MCTooltipTag
{
    MCSearchBarTooltip = 0,
    MCSearchButtonTooltip,
    MCSearchFriendTableViewTooltip,
    MCSwipeButtonTooltip
} MCTooltipTag;

@interface SearchViewController ()
{
    ASAppDelegate *appDelegate;
    
    NSMutableDictionary *friends;
    NSArray *friendSectionTitle;
    CMPopTipView *currentPopTipView;
    BOOL tutorialDone;
    __weak IBOutlet UIButton *searchButton;
    __weak IBOutlet UIImageView *swipeButtonBar;
}

@end

@implementation SearchViewController

@synthesize searchFriendsSearchBar;
@synthesize findFriendTableView;
@synthesize allData;
@synthesize addedFriendsBackgroundView;
@synthesize addedFriendsLabel;

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
    NSLog(@"Search View viewDidLoad");
    [super viewDidLoad];
    
    appDelegate = (ASAppDelegate *) UIApplication.sharedApplication.delegate;
    
    self.findFriendTableView.dataSource=self;
    self.findFriendTableView.delegate=self;
    
    self.allData = [NSMutableArray new];
    self.addedFriendsBackgroundView.hidden=true;
    self.findFriendTableView.hidden=true;
    
    friends = [NSMutableDictionary new];
    friendSectionTitle = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I",
                           @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R",
                           @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    // Set up tutorial
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    tutorialDone = [defaults boolForKey:kSearchTutorialDone];
    
    if (!tutorialDone) {
        self.searchFriendsSearchBar.delegate = self;
        [self showTooltipWithMessage:@"Type the the name (or part of the name) of a friend who's using MumblerChat"
                                 tag:MCSearchBarTooltip
                              atView:self.searchFriendsSearchBar
                       withDirection:PointDirectionUp];
    }
}

- (IBAction)didTapSwipeButton:(id)sender
{
    if (currentPopTipView && currentPopTipView.tag == MCSwipeButtonTooltip) {
        [currentPopTipView dismissAnimated:YES];
        [self markTutorialDone];
    }
    
    if (appDelegate.addedFriendsInFaceBook.count > 0) {
        [FriendsUtils getFbFriendsMumblerUserIdsWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            ;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
    } else {
        if (appDelegate.friendsToBeAddedDictionary.count > 0) {
            DDLogVerbose(@"%@: %@: START appDelegate.friendsToBeAddedDictionary count]>0", THIS_FILE, THIS_METHOD);
            
            [NSUserDefaults.standardUserDefaults setBool:true forKey:IS_FRIENDS_ADDED];
            
            [NSUserDefaults.standardUserDefaults synchronize];
            
            double delayInSeconds = 0.25;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // code to be executed on the main queue after delay
                [FriendsUtils updateAddedFriends];
            });
        }
    }
    
    [self performSegueWithIdentifier:@"leftFriendsView" sender:self];
}

- (void)markTutorialDone
{
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setBool:YES forKey:kSearchTutorialDone];
    [defaults synchronize];
}

- (void)showTooltipWithMessage:(NSString *)message tag:(int)tag atView:(UIView *)view withDirection:(PointDirection)direction
{
    currentPopTipView = [[CMPopTipView alloc] initWithMessage:message];
    currentPopTipView.tag = tag;
    currentPopTipView.preferredPointDirection = direction;
    [currentPopTipView presentPointingAtView:view inView:self.view animated:YES];
}

- (void)addFriends:(NSArray *)friendsToAdd
{
    for (NSDictionary *friend in friendsToAdd) {
        NSString *alias = friend[@"alias"];
        NSString *sectionTitle = [[alias substringToIndex:1] uppercaseString];
        if (friends[sectionTitle] == nil) {
            friends[sectionTitle] = [NSMutableArray new];
        }
        [friends[sectionTitle] addObject:friend];
    }
}

- (IBAction)didTapOnSearchButton:(id)sender {
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    if (currentPopTipView && currentPopTipView.tag == MCSearchButtonTooltip) {
        [currentPopTipView dismissAnimated:YES];
    }
    
    [friends removeAllObjects];
    [self.allData removeAllObjects];
    
    NSString *searchText =[self.searchFriendsSearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (searchText.length > 0) {
        [SVProgressHUD show];
        [self.searchFriendsSearchBar resignFirstResponder];
        [self.view endEditing:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *jsonData = @{@"search_text": searchText};
        NSDictionary *requestParameters = @{@"json": [jsonData jsonStringWithPrettyPrint:YES]};
        NSString *serverCallRequest = [NSString stringWithFormat:@"%@%@", BASE_URL, @"mumblerUser/searchMumblerUsers.htm"];
        
        [manager GET:serverCallRequest
          parameters:requestParameters
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 [SVProgressHUD dismiss];
                 DDLogVerbose(@"%@: %@: searchMumblerUsers responseObject=%@", THIS_FILE, THIS_METHOD,responseObject);
                 
                 NSString *status = [responseObject valueForKey:@"status"];
                 
                 if([status isEqualToString:@"success"]) {
                     if (!tutorialDone) {
                         [self showTooltipWithMessage:@"Select one or more friends by tapping on the add friend button on the right of the result"
                                                  tag:MCSearchFriendTableViewTooltip
                                               atView:self.findFriendTableView
                                        withDirection:PointDirectionDown];
                     }
                     
                     NSDictionary *data= responseObject[@"data"];
                     
                     NSArray *tmpData = data[@"mumbler_users"];
                     if (tmpData.count > 0) {
                         [self.allData addObjectsFromArray:tmpData];
                     } else {
                         UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"Np results found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                         [alertView show];
                     }
                     
                     [self addFriends:allData];
                     self.findFriendTableView.hidden=false;
                     [self.findFriendTableView reloadData];
                 } else {
                     [self markTutorialDone];
                     [[[UIAlertView alloc] initWithTitle:@"Alert"
                                                 message:status
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil] show];
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [SVProgressHUD dismiss];
             }];
    }
    
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return friendSectionTitle;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSArray *sortedKeys = [friends.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSString *match = sortedKeys[0];
    for (NSString *sectionTitle in sortedKeys) {
        if ([sectionTitle compare:title] == NSOrderedDescending) {
            break;
        }
        match = sectionTitle;
    }
    return [friends.allKeys indexOfObject:match];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return friends.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sortedKeys = [friends.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSString *sectionTitle = sortedKeys[section];
    return [friends[sectionTitle] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *sortedKeys = [friends.allKeys sortedArrayUsingSelector:@selector(compare:)];
    return sortedKeys[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableIdentifier = @"FriendTableViewCell";
    
    FriendTableViewCell *tablecell = (FriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    tablecell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSArray *sortedKeys = [friends.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSString *sectionTitle = sortedKeys[indexPath.section];
    NSMutableArray *sectionData = friends[sectionTitle];
    NSDictionary *mumblerUser = sectionData[indexPath.row];
    
    NSString *userId = [NSString stringWithFormat:@"%@",[mumblerUser valueForKey:@"mumblerUserId"]];
    
    //added friends
    if([appDelegate.friendsToBeAddedDictionary objectForKey:userId] != nil){
        
        NSLog(@"picked selectedUserId is there cellForRowAtIndexPath%@",userId);
        tablecell.mumblerUser = mumblerUser;
        tablecell.friendCellType = FriendCellTypeSearch_Added_Friends;
        
        //not added friends
    } else {
        NSLog(@"picked selectedUserId is not there cellForRowAtIndexPath%@",userId);
        
        tablecell.mumblerUser = mumblerUser;
        tablecell.friendCellType = FriendCellTypeSearch_Not_Added_Friends;
    }
    
    return tablecell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchFriendsSearchBar resignFirstResponder];
    NSString *sectionTitle = friendSectionTitle[indexPath.section];
    NSMutableArray *sectionData = friends[sectionTitle];
    NSDictionary *mumblerUser = sectionData[indexPath.row];
    
    NSString *mumblerUserId = [NSString stringWithFormat:@"%@",[mumblerUser valueForKey:@"mumblerUserId"]];
    DDLogVerbose(@"%@: %@: mumblerUserId= %@ ", THIS_FILE, THIS_METHOD,mumblerUserId);
}

- (void)viewDidAppear:(BOOL)animated
{
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(addedFriendsLabelUpdated:) name:@"addedFriendsLabelUpdate" object:nil];
}

-(void)addedFriendsLabelUpdated:(NSNotification*)notification
{
    NSString * addedFriendsNames;
    
    NSLog(@"addedFriendsLabelUpdated called %@",notification.object);
    
    if(appDelegate.friendsToBeAddedDictionary.count > 0) {
        self.addedFriendsBackgroundView.hidden = false;
        for (id key in appDelegate.friendsToBeAddedDictionary) {
            id value = [appDelegate.friendsToBeAddedDictionary objectForKey:key];
            NSString *selectedUserName =[NSString stringWithFormat:@"%@",[value valueForKey:@"alias"]];
            
            if (addedFriendsNames == nil) {
                addedFriendsNames=selectedUserName;
                NSLog(@"addedFriendsNames if %@", addedFriendsNames);
            } else {
                addedFriendsNames=[NSString stringWithFormat:@"%@%@%@", selectedUserName, @",", addedFriendsNames];
                NSLog(@"addedFriendsNames else %@", addedFriendsNames);
            }
            
            if (!tutorialDone && currentPopTipView && currentPopTipView.tag == MCSearchFriendTableViewTooltip) {
                [currentPopTipView dismissAnimated:YES];
                [self showTooltipWithMessage:@"Finally tap the arrow button or swipe left to add the selected friends"
                                         tag:MCSwipeButtonTooltip
                                      atView:swipeButtonBar
                               withDirection:PointDirectionDown];
            }
        }
        NSLog(@"addedFriendsNames OUT %@", addedFriendsNames);
        self.addedFriendsLabel.text = addedFriendsNames;
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addedFriendsLabelUpdate" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (!tutorialDone && currentPopTipView && currentPopTipView.tag == MCSearchBarTooltip && searchText.length >= 3) {
        [currentPopTipView dismissAnimated:YES];
        [self showTooltipWithMessage:@"Now tap this button to see the results of your search"
                                 tag:MCSearchButtonTooltip
                              atView:searchButton
                       withDirection:PointDirectionUp];
    }
}

@end
