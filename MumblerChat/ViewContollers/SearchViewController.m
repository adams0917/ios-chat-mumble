//
//  SearchViewController.m
//  MumblerChat
//


#import "SearchViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "SVProgressHUD.h"
#import <AdSupport/AdSupport.h>
#import "Constants.h"
#import "FriendTableViewCell.h"
#import "ASAppDelegate.h"

#import "NSDictionary+JSON.h"

#define colorTheme [UIColor colorWithRed:233.0/255.0 green:153.0/255.0 blue:6.0/255.0 alpha:1]

@interface SearchViewController ()
{
    ASAppDelegate *appDelegate;
    
    NSMutableDictionary *friends;
    NSArray *friendSectionTitle;
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

- (IBAction)didTapSwipeButton:(id)sender
{
    NSLog(@"here");
}

- (void)viewDidLoad
{
    //DDLogVerbose(@"%@: %@: ", THIS_FILE, THIS_METHOD);
    NSLog(@"Search View viewDidLoad");
    [super viewDidLoad];
    
    appDelegate = (ASAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    self.findFriendTableView.dataSource=self;
    self.findFriendTableView.delegate=self;
    
    self.allData = [NSMutableArray new];
    self.addedFriendsBackgroundView.hidden=true;
    self.findFriendTableView.hidden=true;
    
    friends = [NSMutableDictionary new];
    friendSectionTitle = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I",
                           @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R",
                           @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
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
    
    [friends removeAllObjects];
    [self.allData removeAllObjects];
    
    NSString *searchText =[self.searchFriendsSearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([searchText length]>0){
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
            
            if(addedFriendsNames == nil){
                addedFriendsNames=selectedUserName;
                NSLog(@"addedFriendsNames if %@", addedFriendsNames);
            }else{
                addedFriendsNames=[NSString stringWithFormat:@"%@%@%@", selectedUserName, @",", addedFriendsNames];
                NSLog(@"addedFriendsNames else %@", addedFriendsNames);
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

@end
