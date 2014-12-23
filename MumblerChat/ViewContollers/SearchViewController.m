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
    NSMutableArray *friendSectionTitle;
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
    friendSectionTitle = [NSMutableArray new];
}

- (void)addFriends:(NSMutableArray *)friendsToAdd
{
    for (NSDictionary *friend in friendsToAdd) {
        NSString *alias = friend[@"alias"];
        NSString *sectionTitle = [[alias substringToIndex:1] uppercaseString];
        if (friends[sectionTitle] == nil) {
            friends[sectionTitle] = [NSMutableArray new];
            [friendSectionTitle addObject:sectionTitle];
        }
        [friends[sectionTitle] addObject:friend];
    }
    
    NSArray *sortedKeys = [friends.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSMutableDictionary *sortedFriends = [NSMutableDictionary new];
    for (NSString *key in sortedKeys) {
        sortedFriends[key] = friends[key];
    }
    
    friends = [[NSMutableDictionary alloc] initWithDictionary:sortedFriends copyItems:YES];
    friendSectionTitle = [[NSMutableArray alloc] initWithArray:sortedKeys copyItems:YES];
}

- (IBAction)didTapOnSearchButton:(id)sender {
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    [friends removeAllObjects];
    [friendSectionTitle removeAllObjects];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return friendSectionTitle.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = friendSectionTitle[section];
    return [friends[sectionTitle] count];
}

//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
//    if (sectionTitle == nil) {
//        return nil;
//    }
//    NSInteger integer=0;
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        
//        integer=42;
//        
//    }else{
//        
//        integer=36.5;
//        
//    }
//    
//    UILabel *label = [[UILabel alloc] init];
//    label.frame = CGRectMake(integer,3, 320, 18);
//    label.backgroundColor = [UIColor clearColor];
//    label.textColor = [UIColor whiteColor];
//    label.shadowColor = [UIColor grayColor];
//    label.shadowOffset = CGSizeMake(-1.0, 1.0);
//    label.font = [UIFont boldSystemFontOfSize:16];
//    label.text = sectionTitle;
//    
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 25)];
//    [headerView setBackgroundColor:colorTheme];
//    
//    [headerView addSubview:label];
//    
//    return headerView;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *view = [UIView new];
//    return view;
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [friendSectionTitle objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableIdentifier = @"FriendTableViewCell";
    
    FriendTableViewCell *tablecell = (FriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    tablecell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSString *sectionTitle = friendSectionTitle[indexPath.section];
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
