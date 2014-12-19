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


#define colorTheme [UIColor colorWithRed:233.0/255.0 green:153.0/255.0 blue:6.0/255.0 alpha:1]

@interface SearchViewController (){
    ASAppDelegate *appDelegate;
}

@end

@implementation SearchViewController

@synthesize searchFriendsSearchBar;
@synthesize sections;
@synthesize sectionWiseData;
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


- (IBAction)didTapSwipeButton:(id)sender {
    
}

- (void)viewDidLoad
{
    //DDLogVerbose(@"%@: %@: ", THIS_FILE, THIS_METHOD);
    NSLog(@"Search View viewDidLoad");
    [super viewDidLoad];
    
    self.findFriendTableView.dataSource=self;
    self.findFriendTableView.delegate=self;
    
    self.sectionWiseData = [[NSMutableDictionary alloc] init];
    self.allData = [[NSMutableArray alloc] init];
    self.sections = [[NSMutableArray alloc] init];
    appDelegate = (ASAppDelegate *)[[UIApplication sharedApplication]delegate];
    self.addedFriendsBackgroundView.hidden=true;
    self.findFriendTableView.hidden=true;

    
}


- (IBAction)didTapOnSearchButton:(id)sender{
    
    
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    [self.sectionWiseData removeAllObjects];
    [self.sections removeAllObjects];
    [self.allData removeAllObjects];
    
    NSString *searchText =[self.searchFriendsSearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([searchText length]>0){
         [SVProgressHUD show];
        [self.searchFriendsSearchBar resignFirstResponder];
        [self.view endEditing:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        
        NSMutableString *jsonString  = [[NSMutableString alloc] init];
        
        [jsonString appendFormat:@"{"];
        
        [jsonString appendFormat:@"\"search_text\":\"%@\"", searchText];
        
        [jsonString appendFormat:@"}"];

        
        NSArray *keys = [[NSArray alloc] initWithObjects:@"json",nil];
        
        NSArray *values = [[NSArray alloc] initWithObjects:jsonString,nil];
        
        NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
        
        NSString * serverCallRequest = [NSString stringWithFormat:@"%@%@", BASE_URL, @"mumblerUser/searchMumblerUsers.htm"];
        
        [manager GET:serverCallRequest parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [SVProgressHUD dismiss];
            DDLogVerbose(@"%@: %@: searchMumblerUsers responseObject=%@", THIS_FILE, THIS_METHOD,responseObject);
            
            NSString *status = [responseObject valueForKey:@"status"];
        
                if([status isEqualToString:@"success"]) {
                NSDictionary *data=[responseObject valueForKey:@"data"];
                
                
                NSArray *tmpData =[data valueForKey:@"mumbler_users"];
                if ([tmpData count]>0) {
                    
                    [self.allData addObjectsFromArray:tmpData];
                }else{
                    
                    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:nil message:@"Np results found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alertView show];
                    
                }
                
                
                for (NSDictionary *mumblerUser in  allData) {
                    
                    
                    NSString *startingCharacter = [[[mumblerUser valueForKey:@"alias"] substringToIndex:1] uppercaseString];
                    
                    if ([self.sections containsObject:startingCharacter]) {
                        
                        NSMutableArray *sectionedRecordsArray = [self.sectionWiseData valueForKey:startingCharacter];
                        
                        [sectionedRecordsArray addObject:mumblerUser];
                        
                    } else {
                        NSMutableArray *sectionedRecordsArray = [[NSMutableArray alloc] init];
                        [sectionedRecordsArray addObject:mumblerUser];
                        
                        [self.sectionWiseData setValue:sectionedRecordsArray forKey:startingCharacter];
                        [self.sections addObject:startingCharacter];
                        
                    }
                    
                    
                }
                 self.findFriendTableView.hidden=false;
                [self.findFriendTableView reloadData];
                
                
                
            } else {
                
                [[[UIAlertView alloc] initWithTitle:@"Alert"
                                            message:status
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                
                
            }
            
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             
             
             [SVProgressHUD dismiss];
             
             
         }];
        
    }
    
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    return view;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *sectionHeader = [self.sections objectAtIndex:section];
    return [[self.sectionWiseData valueForKey:sectionHeader] count];
    
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    NSInteger integer=0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        integer=42;
        
    }else{
        
        integer=36.5;
        
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(integer,3, 320, 18);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor grayColor];
    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 25)];
    [headerView setBackgroundColor:colorTheme];
    
    [headerView addSubview:label];
    
    return headerView;
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return  [NSString stringWithFormat:@"%@",[self.sections objectAtIndex:section]];//do not touch
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *tableIdentifier = @"FriendTableViewCell";
    
    FriendTableViewCell *tablecell = (FriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    tablecell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSString *sectionHeader = [self.sections objectAtIndex:indexPath.section];
    NSMutableArray *sectionData = [self.sectionWiseData objectForKey:sectionHeader];
    NSDictionary *mumblerUser= [sectionData objectAtIndex: indexPath.row];
 
    
       NSString *userId =[NSString stringWithFormat:@"%@",[mumblerUser valueForKey:@"mumblerUserId"]];
    
   
     //added friends
    if([appDelegate.friendsToBeAddedDictionary objectForKey:userId] != nil){
        
        NSLog(@"picked selectedUserId is there cellForRowAtIndexPath%@",userId);
        tablecell.mumblerUser = mumblerUser;
        tablecell.friendCellType = FriendCellTypeSearch_Added_Friends;
        
     //not added friends
    }else{
        NSLog(@"picked selectedUserId is not there cellForRowAtIndexPath%@",userId);
        
        tablecell.mumblerUser = mumblerUser;
        tablecell.friendCellType = FriendCellTypeSearch_Not_Added_Friends;
        
        
       
        
    }

    return tablecell;
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.searchFriendsSearchBar resignFirstResponder];

    NSString *sectionHeader = [self.sections objectAtIndex:indexPath.section];
    
    NSArray *dataInSection = [self.sectionWiseData objectForKey:sectionHeader];
    
    NSDictionary *mumblerUser = [dataInSection objectAtIndex:indexPath.row];
    
    NSString *mumblerUserId = [NSString stringWithFormat:@"%@",[mumblerUser valueForKey:@"mumblerUserId"]];
    
    DDLogVerbose(@"%@: %@: mumblerUserId= %@ ", THIS_FILE, THIS_METHOD,mumblerUserId);
    
    
}




- (void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addedFriendsLabelUpdated:) name:@"addedFriendsLabelUpdate" object:nil];
}

-(void)addedFriendsLabelUpdated:(NSNotification*)notification {
    
    NSString * addedFriendsNames;
    
    NSLog(@"addedFriendsLabelUpdated called %@",notification.object);
    
    if([appDelegate.friendsToBeAddedDictionary count] > 0){
        self.addedFriendsBackgroundView.hidden=false;
        for(id key in appDelegate.friendsToBeAddedDictionary) {
            id value = [appDelegate.friendsToBeAddedDictionary objectForKey:key];
            NSString *selectedUserName =[NSString stringWithFormat:@"%@",[value valueForKey:@"alias"]];
            
            if(addedFriendsNames == nil){
                addedFriendsNames=selectedUserName;
                NSLog(@"addedFriendsNames if %@",addedFriendsNames);
            }else{
                addedFriendsNames=[NSString stringWithFormat:@"%@%@%@",selectedUserName,@",",addedFriendsNames];
                NSLog(@"addedFriendsNames else %@",addedFriendsNames);
            }
            
        }
        NSLog(@"addedFriendsNames OUT %@",addedFriendsNames);
        self.addedFriendsLabel.text=addedFriendsNames;
        
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
