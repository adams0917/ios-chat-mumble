//
//  ContactsViewController.m
//  MumblerChat
//


#import "ContactsViewController.h"
#import "ASAppDelegate.h"
#import "Constants.h"
#import "FriendDao.h"
#import "SVProgressHUD.h"
#import "AFHTTPRequestOperationManager.h"
#import "MumblerFriendship.h"
#import "FriendTableViewCell.h"
#import "User.h"

#define colorTheme [UIColor colorWithRed:233.0/255.0 green:153.0/255.0 blue:6.0/255.0 alpha:1]
@interface ContactsViewController ()
{
    
    NSArray *keySelect;
    NSString *sectionHeaderSelect;
    NSMutableArray *contactListSelect;
    NSMutableArray *friendsToBeAdded;
    ASAppDelegate *appDelegate;
    
    NSMutableArray *searchResultsAllreadyInMumber;
    NSMutableArray *searchResultsInviteMumber;
    NSMutableDictionary *friendsAllreadyInMumblerDictionary ;
    NSMutableArray *friendsAllreadyInMumblerArray;
    
    
    NSMutableArray *selectAllImageViewsForEachSectionArray;
    NSArray *searchResult;
    NSString *searchText;
    
    BOOL selectAllOptionFriendsUsingMumbler;
    BOOL selectAllOptionInviteFriends;
    UIImageView *selectAllImageViewInviteFriends;
    UIImageView *selectAllImageViewFriendsWithMumbler;

  NSMutableArray* phoneContactsArray;
  NSMutableArray* phoneNumbers;
  NSMutableDictionary *sectionWiseDataWithNumbers;
  NSMutableDictionary * profileImagesDictionary;


}

@end

@implementation ContactsViewController
@synthesize addressBookTableView,searchAddressBook;
@synthesize sections;
@synthesize sectionWiseData;
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

/////////////////Added Friends Label

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
        
    }else{
         self.addedFriendsLabel.text=@"";
    }
    
    
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addedFriendsLabelUpdate" object:nil];
}


////////////////Added Friends label over

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)search scope:(NSString*)scope
{
    
        if (search != nil && search.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.alias contains[c] %@",search];
        searchResultsAllreadyInMumber = [NSMutableArray arrayWithArray:[friendsAllreadyInMumblerArray filteredArrayUsingPredicate:predicate]];
        searchResultsInviteMumber = [NSMutableArray arrayWithArray:[phoneContactsArray filteredArrayUsingPredicate:predicate]];
        
        [self showContactsFriends:searchResultsAllreadyInMumber showFriends:searchResultsInviteMumber];
        
    }else{
        [self showContactsFriends:friendsAllreadyInMumblerArray showFriends:phoneContactsArray];
        
    }
    [self.addressBookTableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)search {
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    [self filterContentForSearchText:search
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sectionWiseData = [[NSMutableDictionary alloc] init];
    self.sections = [[NSMutableArray alloc] init];
    searchResult=[[NSMutableArray alloc ]init];
    selectAllImageViewsForEachSectionArray= [[NSMutableArray alloc] init];
    
    self.addressBookTableView.dataSource=self;
    self.addressBookTableView.delegate=self;
    
    [self.addressBookTableView setNeedsLayout];
    self.addedFriendsBackgroundView.hidden=true;
    searchResultsAllreadyInMumber=[[NSMutableArray alloc]init];
    searchResultsInviteMumber=[[NSMutableArray alloc]init];
    
    phoneContactsArray = [[NSMutableArray alloc] init];
    phoneNumbers = [[NSMutableArray alloc] init];
    
    friendsAllreadyInMumblerDictionary = [[NSMutableDictionary alloc] init];
    friendsAllreadyInMumblerArray = [[NSMutableArray alloc] init];
    
    
    appDelegate = (ASAppDelegate *)[UIApplication sharedApplication].delegate;
    
    profileImagesDictionary = [[NSMutableDictionary alloc] init];
    
    [self loadContactsData];
    
}

#pragma mark - UISearchDisplayController Delegate Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([addressBookTableView isFirstResponder] && [touch view] != addressBookTableView)
    {
        [addressBookTableView resignFirstResponder];
    }
    if ([searchAddressBook isFirstResponder] && [touch view] != searchAddressBook)
    {
        [searchAddressBook resignFirstResponder];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    [addressBookTableView resignFirstResponder];
    [searchAddressBook resignFirstResponder];
    
}




-(void)sendContactsToTheServer{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    NSMutableString *jsonString  = [[NSMutableString alloc] init];
    
    [jsonString appendFormat:@"{"];
    
    [jsonString appendFormat:@"\"phoneNumbers\":%@",phoneNumbers];
    
    [jsonString appendFormat:@"}"];
    
    NSLog(@"JSON string%@ ", jsonString);
    
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"json",nil];
    
    NSArray *values = [[NSArray alloc] initWithObjects:jsonString,nil];
    
    NSDictionary *requestParameters = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    NSString * serverCallRequest = [NSString stringWithFormat:@"%@%@", BASE_URL, @"mumblerUser/getMumblerUsersForPhoneNumbers.htm"];
    
    [manager POST:serverCallRequest parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        [SVProgressHUD dismiss];
        DDLogVerbose(@"%@: %@: getMumblerUsersForPhoneNumbers.htm responseObject =%@ ", THIS_FILE, THIS_METHOD,responseObject);
        
        NSString *status = [responseObject valueForKey:@"status"];
        
        if([status isEqualToString:@"success"])
        {
            friendsAllreadyInMumblerDictionary = [[responseObject valueForKey:@"data"] valueForKey:@"mumbler_users"];
            
            if ([friendsAllreadyInMumblerDictionary count]>0) {
                [self.sections addObject:@"Friends Using Mumbler"];
                
                
                NSArray *inMumblerKeys = [friendsAllreadyInMumblerDictionary allKeys];
                for (NSString *inMumblerKey in inMumblerKeys) {
                    
                    NSDictionary *inMumblerRecord = [friendsAllreadyInMumblerDictionary valueForKey:inMumblerKey];
                    
                    [friendsAllreadyInMumblerArray addObject:inMumblerRecord];
                    
                    for (int a=0; a<[phoneContactsArray count]; a++) {
                        
                        NSDictionary *contactRecord = [phoneContactsArray objectAtIndex:a];
                        
                        if ([inMumblerKey isEqualToString:[contactRecord valueForKey:@"phoneNumber"]]) {
                            [phoneContactsArray removeObjectAtIndex:a];
                           
                            break;
                        }
                        
                    }
                    
                    
                }
                
                
            }
            
            
            [self showContactsFriends:friendsAllreadyInMumblerArray showFriends:phoneContactsArray];
            
            [self.addressBookTableView reloadData];
            
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
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
    
}



-(void) showContactsFriends:(NSMutableArray *) friendsAllreadyInMumbler showFriends:(NSMutableArray *) friendsInviteMumblerArray {
    
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    
    [self.sections removeAllObjects];
    [self.sectionWiseData removeAllObjects];
    
    if ([friendsAllreadyInMumbler count]>0) {
        
        
        NSString *mumblerUserId= [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:MUMBLER_USER_ID]];
        
        
        FriendDao *objFriendsDao=[[FriendDao alloc]init];
        NSArray *tmpAllFriends=[objFriendsDao getFriendships:mumblerUserId ];
        
        for (MumblerFriendship *mumblerFriend in  tmpAllFriends) {
            
            NSMutableArray *copyArray=[[NSMutableArray alloc] initWithArray:friendsAllreadyInMumbler];
            for ( NSDictionary *friend in friendsAllreadyInMumbler) {
                
                if ([[friend valueForKey:@"friendMumblerId"] intValue]== [mumblerFriend.friendMumblerUser.userId intValue]) {
                  
                    if ([friendsAllreadyInMumbler containsObject:friend]) {
                        
                        [copyArray removeObject:friend];
                        if (![appDelegate.friendsWithMumblerInContacts containsObject:mumblerFriend.friendMumblerUser.userId]) {
                            [appDelegate.friendsWithMumblerInContacts addObject:mumblerFriend.friendMumblerUser.userId];
                            
                        }
                        
                        
                    }
                }
                
            }
            
            friendsAllreadyInMumbler=copyArray;
        }
        
        [self.sections addObject:@"Friends Using Mumbler"];
        [self.sectionWiseData setValue:friendsAllreadyInMumbler forKey:@"Friends Using Mumbler"];
        
    }
    
    if ([friendsInviteMumblerArray count]>0) {
        
        [self.sections addObject:@"Invite Friends"];
        [self.sectionWiseData setValue:friendsInviteMumblerArray forKey:@"Invite Friends"];
    }
    
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
    
    
}

-(void)loadContactsData
{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    [self.sections removeAllObjects];
    
    CFErrorRef *error = nil;
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        NSLog(@"kABAuthorizationStatusAuthorized");
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        
        __block BOOL accessGranted = NO;
        
        if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            NSLog(@" ABAddressBookRequestAccessWithCompletion!nill ");
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                accessGranted = granted;
                dispatch_semaphore_signal(sema);
                
                NSLog(@"%d",accessGranted);
            });
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            //  dispatch_release(sema);kanishka
            accessGranted = YES;
        }
        else { // we're on iOS 5 or older
            accessGranted = YES;
            DDLogVerbose(@"%@: %@: accessGranted ", THIS_FILE, THIS_METHOD);
            
        }
        
        
        if (accessGranted) {
            
            NSLog(@" accessGranted");
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
            NSMutableArray *allPeople = (__bridge NSMutableArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
           
            if (ABAddressBookGetPersonCount(addressBook)==0) {
                NSLog(@"Zero contacts");
            }
            else{
                
                for(int i=0; i < ABAddressBookGetPersonCount(addressBook); i++ ){
                    ABRecordRef person = (__bridge ABRecordRef)([allPeople objectAtIndex:i]);
                    NSString *contactName=@"";
                    NSString *phoneNumber=@"";
                    NSString *firstName = @"";
                    NSString *lastName=@"";
                    
                    if(ABRecordCopyValue(person, kABPersonFirstNameProperty) != NULL)
                        firstName = [[NSString stringWithFormat:@"%@", ABRecordCopyValue(person, kABPersonFirstNameProperty)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    lastName  = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                    ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
                    CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phoneNumberProperty, 0);
                    NSString *phoneString = (__bridge NSString*)phoneNumberRef;
                    
                    
                    if (firstName!=nil) {
                        
                        
                        if (lastName==nil)
                        {
                            
                            
                            contactName=firstName;
                            
                        }else{
                            
                            
                            NSString *fullName=[NSString stringWithFormat:@"%@ %@",firstName,lastName];
                            contactName=fullName;
                            
                        }
                        
                    }
                    
                    
                    CFRelease(phoneNumberProperty);
                    
                    if (phoneString!=nil) {
                        
                        phoneNumber=phoneString;
                        
                    }
                    
                    NSMutableDictionary *record = [[NSMutableDictionary alloc] init];
                    [record setValue:contactName forKey:@"alias"];
                    [record setValue:phoneNumber forKey:@"phoneNumber"];
                    
                    [phoneContactsArray addObject:record];
                    [phoneNumbers addObject:phoneNumber];
                    
                    
                }
                
                [self sendContactsToTheServer];
                
            }
        }
        
    }
    
    else
    {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        DDLogVerbose(@"%@: %@: NOT AUTHORIZED ", THIS_FILE, THIS_METHOD);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(granted)
                {
                    [self loadContactsData];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"DENIED"
                                                                        message:@"Check Settings -> Privacy -> Contacts and Enable Access for Mumbler"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
                
            });
            
        });
    }
    
   DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *sectionHeader = [self.sections objectAtIndex:section];
    return [[self.sectionWiseData valueForKey:sectionHeader] count];
    
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
        
        if ([appDelegate.friendsToBeAddedDictionary count] > 0) {
            
            [appDelegate.friendsToBeAddedDictionary removeAllObjects];
            
        }
        
    }
    [self.addressBookTableView reloadData];
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
        
        if ([appDelegate.inviteFriendsInContactsDictionary count] > 0) {
            
            [appDelegate.inviteFriendsInContactsDictionary removeAllObjects];
            
        }

    }
    [self.addressBookTableView reloadData];
    
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
    
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 35)];
    [headerView setBackgroundColor:colorTheme];
    
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 2.5, 200, 18);
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
    
    
    if([sectionTitle isEqualToString:@"Friends Using Mumbler"]){
        
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return 70;
    }
    else
    {
        return 55;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [self.sections objectAtIndex:section];
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
    
    NSMutableArray *records = [self.sectionWiseData valueForKey:sectionHeader];
    
    NSDictionary *record = [records objectAtIndex:indexPath.row];
    
    
    //load normally
    if([sectionHeader isEqualToString:@"Friends Using Mumbler"]){
        
        tablecell.selectAllCheckboxImageView = selectAllImageViewFriendsWithMumbler;
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu", (unsigned long)[sectionData count]] forKey:FRIENDS_USING_MUMBLER_IN_CONTACTS];
        [[NSUserDefaults standardUserDefaults] synchronize];

        
        DDLogVerbose(@"%@: %@: Friends Using Mumbler ", THIS_FILE, THIS_METHOD);
        
        if([record valueForKey:@"alias"] != nil){
            //using mumler
            
            //select all option has has pressed
            if(selectAllOptionFriendsUsingMumbler){
                
                if([appDelegate.friendsToBeAddedDictionary objectForKey:userId] == nil){
                    [appDelegate.friendsToBeAddedDictionary setObject:mumblerUser forKey:userId];
                    
                   
                }
                tablecell.friendCellType =FriendCellTypeContactsAdddedFriend;
                tablecell.mumblerUser = mumblerUser;
                
                }else{
                    
                    if([appDelegate.friendsToBeAddedDictionary objectForKey:userId] != nil){
                        
                        tablecell.mumblerUser = mumblerUser;
                        tablecell.friendCellType = FriendCellTypeContactsAdddedFriend;
                        
                    }
                    //added now
                    else{
                        tablecell.friendCellType =FriendCellTypeContactsFriendsWithMumbler;
                        tablecell.mumblerUser = mumblerUser;
                        
                        
                    }
                    
                  
                }
                
                
            }
        
    }
    
    else if([sectionHeader isEqualToString:@"Invite Friends"]){
        
        tablecell.selectAllCheckboxImageView = selectAllImageViewInviteFriends;
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu", (unsigned long)[sectionData count]] forKey:INVITE_FRIENDS_IN_CONTACTS];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        NSString *selectedMobile = [record valueForKey:@"phoneNumber"];
        
        if(selectAllOptionInviteFriends){
           
            
            
            if([appDelegate.inviteFriendsInContactsDictionary objectForKey:selectedMobile] == nil){
                [appDelegate.inviteFriendsInContactsDictionary setObject:mumblerUser forKey:selectedMobile];
               
            }
            tablecell.friendCellType =FriendCellTypeContactsSelectedForSendATextToFriend;
            tablecell.mumblerUser = mumblerUser;
            
        }else{
            
            if([appDelegate.inviteFriendsInContactsDictionary objectForKey:selectedMobile] == nil){
                
                tablecell.friendCellType =FriendCellTypeContactsInviteFriendsToMumbler;
                tablecell.mumblerUser = mumblerUser;
                
                
            }else{
                tablecell.mumblerUser = mumblerUser;
                tablecell.friendCellType = FriendCellTypeContactsSelectedForSendATextToFriend;
            }
            
        }
        
    }
    
    return tablecell;
    
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