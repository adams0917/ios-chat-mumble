//
//  ContactsViewController.m
//  MumblerChat
//


#import "ContactsViewController.h"
#import "ASAppDelegate.h"
#import "Constants.h"
#import "FriendDao.h"
#import "FriendsUtils.h"
#import "SVProgressHUD.h"
#import "AFHTTPRequestOperationManager.h"
#import "MumblerFriendship.h"
#import "FriendTableViewCell.h"
#import "User.h"
#import "CMPopTipView.h"

#import "UIAlertView+Utils.h"
#import "NSDictionary+JSON.h"

#define colorTheme [UIColor colorWithRed:233.0/255.0 green:153.0/255.0 blue:6.0/255.0 alpha:1]

typedef enum _MCTooltipTag
{
    MCAddressBookTableViewTooltip = 0,
    MCSwipeButtonTooltip
} MCTooltipTag;

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
    NSMutableDictionary *profileImagesDictionary;
    
    NSMutableDictionary *friends;
    NSArray *friendSectionTitle;

    CMPopTipView *currentPopTipView;
    BOOL tutorialDone;
    __weak IBOutlet UIImageView *swipeButtonBar;
}

@end

@implementation ContactsViewController

@synthesize addressBookTableView,searchAddressBook;
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

/////////////////Added Friends Label

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    self.sectionWiseData = [[NSMutableDictionary alloc] init];
    //    self.sections = [[NSMutableArray alloc] init];
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
    
    friendsAllreadyInMumblerDictionary = [NSMutableDictionary new];
    friendsAllreadyInMumblerArray = [NSMutableArray new];
    
    
    appDelegate = (ASAppDelegate *)UIApplication.sharedApplication.delegate;
    
    profileImagesDictionary = [[NSMutableDictionary alloc] init];
    
    friends = [NSMutableDictionary new];
    friendSectionTitle = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I",
                           @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R",
                           @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    // Set up tutorial
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    tutorialDone = [defaults boolForKey:kContactsTutorialDone];
    
    [self loadContactsData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addedFriendsLabelUpdated:) name:@"addedFriendsLabelUpdate" object:nil];
}

- (void)markTutorialDone
{
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setBool:YES forKey:kContactsTutorialDone];
    [defaults synchronize];
}

- (void)showTooltipWithMessage:(NSString *)message tag:(int)tag atView:(UIView *)view withDirection:(PointDirection)direction
{
    currentPopTipView = [[CMPopTipView alloc] initWithMessage:message];
    currentPopTipView.tag = tag;
    currentPopTipView.preferredPointDirection = direction;
    [currentPopTipView presentPointingAtView:view inView:self.view animated:YES];
}

- (void)addedFriendsLabelUpdated:(NSNotification*)notification
{
    NSString * addedFriendsNames;
    
    if (!tutorialDone && currentPopTipView && currentPopTipView.tag == MCAddressBookTableViewTooltip) {
        [currentPopTipView dismissAnimated:YES];
        [self showTooltipWithMessage:@"Finally tap the arrow button or swipe left to add the selected friends"
                                 tag:MCSwipeButtonTooltip
                              atView:swipeButtonBar
                       withDirection:PointDirectionDown];
    }
    
    NSLog(@"addedFriendsLabelUpdated called %@",notification.object);
    
    if([appDelegate.friendsToBeAddedDictionary count] > 0){
        self.addedFriendsBackgroundView.hidden=false;
        for(id key in appDelegate.friendsToBeAddedDictionary) {
            id value = [appDelegate.friendsToBeAddedDictionary objectForKey:key];
            NSString *selectedUserName = [NSString stringWithFormat:@"%@", value[@"alias"]];
            
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"addedFriendsLabelUpdate" object:nil];
}

////////////////Added Friends label over

#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString*)search scope:(NSString*)scope
{
    if (search != nil && search.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.alias contains[c] %@",search];
        searchResultsAllreadyInMumber = [NSMutableArray arrayWithArray:[friendsAllreadyInMumblerArray filteredArrayUsingPredicate:predicate]];
        searchResultsInviteMumber = [NSMutableArray arrayWithArray:[phoneContactsArray filteredArrayUsingPredicate:predicate]];
        
        [self showContactsFriends:searchResultsAllreadyInMumber showFriends:searchResultsInviteMumber];
    } else {
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

#pragma mark - UISearchDisplayController Delegate Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([addressBookTableView isFirstResponder] && [touch view] != addressBookTableView) {
        [addressBookTableView resignFirstResponder];
    }
    if ([searchAddressBook isFirstResponder] && [touch view] != searchAddressBook) {
        [searchAddressBook resignFirstResponder];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    [addressBookTableView resignFirstResponder];
    [searchAddressBook resignFirstResponder];
}

- (void)sendContactsToTheServer
{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.length > 0"];
    NSDictionary *data = @{@"phoneNumbers": [phoneNumbers filteredArrayUsingPredicate:predicate]};
    NSString *jsonString = [data jsonStringWithPrettyPrint:YES];
    
    NSLog(@"JSON string%@ ", jsonString);
    
    NSString * serverCallRequest = [NSString stringWithFormat:@"%@%@", BASE_URL, @"mumblerUser/getMumblerUsersForPhoneNumbers.htm"];
    
    [manager POST:serverCallRequest
       parameters:@{@"json": jsonString}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [SVProgressHUD dismiss];
              DDLogVerbose(@"%@: %@: getMumblerUsersForPhoneNumbers.htm responseObject =%@ ", THIS_FILE, THIS_METHOD,responseObject);
              
              if (!tutorialDone) {
                  [self showTooltipWithMessage:@"Select one or more friends by tapping on the add friend button on the right of the result"
                                           tag:MCAddressBookTableViewTooltip
                                        atView:self.addressBookTableView
                                 withDirection:PointDirectionDown];
              }
              
              NSString *status = [responseObject valueForKey:@"status"];
              
              if ([status isEqualToString:@"success"]) {
                  friendsAllreadyInMumblerDictionary = [[responseObject valueForKey:@"data"] valueForKey:@"mumbler_users"];
                  
                  if (friendsAllreadyInMumblerDictionary.count > 0) {
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
              } else {
                  [[[UIAlertView alloc] initWithTitle:@"Alert"
                                              message:status
                                             delegate:nil
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil] show];
              }
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              [SVProgressHUD dismiss];
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:[error localizedDescription] delegate:self
                                                    cancelButtonTitle:@"OK" otherButtonTitles: nil];
              
              [alert show];
              
          }];
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
    
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

- (void)showContactsFriends:(NSMutableArray *)friendsAllreadyInMumbler showFriends:(NSMutableArray *)friendsInviteMumblerArray
{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    [friends removeAllObjects];
    
    if (friendsAllreadyInMumbler.count > 0) {
        NSString *mumblerUserId= [NSString stringWithFormat:@"%@",[NSUserDefaults.standardUserDefaults valueForKey:MUMBLER_USER_ID]];
        
        FriendDao *objFriendsDao=[[FriendDao alloc]init];
        NSArray *tmpAllFriends=[objFriendsDao getFriendships:mumblerUserId ];
        
        for (MumblerFriendship *mumblerFriend in tmpAllFriends) {
            
            NSMutableArray *copyArray = [[NSMutableArray alloc] initWithArray:friendsAllreadyInMumbler];
            for (NSDictionary *friend in friendsAllreadyInMumbler) {
                
                if ([friend[@"friendMumblerId"] intValue] == [mumblerFriend.friendMumblerUser.userId intValue]) {
                    if ([friendsAllreadyInMumbler containsObject:friend]) {
                        [copyArray removeObject:friend];
                        if (![appDelegate.friendsWithMumblerInContacts containsObject:mumblerFriend.friendMumblerUser.userId]) {
                            [appDelegate.friendsWithMumblerInContacts addObject:mumblerFriend.friendMumblerUser.userId];
                        }
                    }
                }
            }
            
            friendsAllreadyInMumbler = copyArray;
        }
        
        [self addFriends:friendsAllreadyInMumbler];
    }
    
    if (friendsInviteMumblerArray.count > 0) {
        [self addFriends:friendsInviteMumblerArray];
    }
    
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
}

-(void)loadContactsData
{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    //    [self.sections removeAllObjects];
    [friends removeAllObjects];
    
    CFErrorRef *error = nil;
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
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
        } else { // we're on iOS 5 or older
            accessGranted = YES;
            DDLogVerbose(@"%@: %@: accessGranted ", THIS_FILE, THIS_METHOD);
            
        }
        
        if (accessGranted) {
            NSLog(@" accessGranted");
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
            NSMutableArray *allPeople = (__bridge NSMutableArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
            
            if (ABAddressBookGetPersonCount(addressBook)==0) {
                NSLog(@"Zero contacts");
            } else{
                for(int i = 0; i < ABAddressBookGetPersonCount(addressBook); i++ ){
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
                    
                    
                    if (firstName != nil) {
                        if (lastName==nil) {
                            contactName=firstName;
                        } else {
                            NSString *fullName=[NSString stringWithFormat:@"%@ %@", firstName, lastName];
                            contactName=fullName;
                        }
                    }
                    
                    CFRelease(phoneNumberProperty);
                    
                    if (phoneString!=nil) {
                        phoneNumber = phoneString;
                    }
                    
                    NSMutableDictionary *record = [[NSMutableDictionary alloc] init];
                    [record setValue:contactName forKey:@"alias"];
                    [record setValue:phoneNumber forKey:@"phoneNumber"];
                    [record setValue:@NO forKey:@"isMumblerFriend"];
                    
                    [phoneContactsArray addObject:record];
                    [phoneNumbers addObject:phoneNumber];
                }
                
                [self sendContactsToTheServer];
            }
        }
    } else {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        DDLogVerbose(@"%@: %@: NOT AUTHORIZED ", THIS_FILE, THIS_METHOD);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(granted) {
                    [self loadContactsData];
                } else {
                    [UIAlertView showWithTitle:@"Denied"
                                       message:@"Check Settings -> Privacy -> Contacts and Enable Access for Mumbler"
                             cancelButtonTitle:@"Ok"];
                }
            });
        });
    }
    
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
}

#pragma mark - UITableViewDataSource

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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return 70;
    }
    return 55;
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
    
    tablecell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *sortedKeys = [friends.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSString *sectionTitle = sortedKeys[indexPath.section];
    NSMutableArray *sectionData = friends[sectionTitle];
    NSDictionary *mumblerUser = sectionData[indexPath.row];
    
    NSString *userId =[NSString stringWithFormat:@"%@",[mumblerUser valueForKey:@"mumblerUserId"]];
    NSMutableArray *records = friends[sectionTitle];
    NSDictionary *record = [records objectAtIndex:indexPath.row];
    
    //load normally
    if(mumblerUser[@"isMumblerFriend"]) {
        tablecell.selectAllCheckboxImageView = selectAllImageViewFriendsWithMumbler;
        [NSUserDefaults.standardUserDefaults setObject:[NSString stringWithFormat:@"%lu", (unsigned long)[sectionData count]] forKey:FRIENDS_USING_MUMBLER_IN_CONTACTS];
        [NSUserDefaults.standardUserDefaults synchronize];
        
        DDLogVerbose(@"%@: %@: Friends Using Mumbler ", THIS_FILE, THIS_METHOD);
        
        if(record[@"alias"] != nil) {
            //using mumler
            
            //select all option has has pressed
            if (selectAllOptionFriendsUsingMumbler) {
                if(appDelegate.friendsToBeAddedDictionary[userId] == nil) {
                    appDelegate.friendsToBeAddedDictionary[userId] = mumblerUser;
                }
                tablecell.friendCellType = FriendCellTypeContactsAdddedFriend;
                tablecell.mumblerUser = mumblerUser;
            } else {
                if (appDelegate.friendsToBeAddedDictionary[userId] != nil) {
                    tablecell.mumblerUser = mumblerUser;
                    tablecell.friendCellType = FriendCellTypeContactsAdddedFriend;
                } else{
                    //added now
                    tablecell.friendCellType =FriendCellTypeContactsFriendsWithMumbler;
                    tablecell.mumblerUser = mumblerUser;
                }
            }
        }
    } else {//if ([sectionHeader isEqualToString:@"Invite Friends"]) {
        tablecell.selectAllCheckboxImageView = selectAllImageViewInviteFriends;
        [NSUserDefaults.standardUserDefaults setObject:[NSString stringWithFormat:@"%lu", (unsigned long)[sectionData count]] forKey:INVITE_FRIENDS_IN_CONTACTS];
        [NSUserDefaults.standardUserDefaults synchronize];
        
        
        NSString *selectedMobile = [record valueForKey:@"phoneNumber"];
        
        if (selectAllOptionInviteFriends) {
            if([appDelegate.inviteFriendsInContactsDictionary objectForKey:selectedMobile] == nil){
                [appDelegate.inviteFriendsInContactsDictionary setObject:mumblerUser forKey:selectedMobile];
            }
            tablecell.friendCellType =FriendCellTypeContactsSelectedForSendATextToFriend;
            tablecell.mumblerUser = mumblerUser;
        } else {
            if ([appDelegate.inviteFriendsInContactsDictionary objectForKey:selectedMobile] == nil) {
                tablecell.friendCellType =FriendCellTypeContactsInviteFriendsToMumbler;
                tablecell.mumblerUser = mumblerUser;
            } else {
                tablecell.mumblerUser = mumblerUser;
                tablecell.friendCellType = FriendCellTypeContactsSelectedForSendATextToFriend;
            }
        }
    }
    
    return tablecell;
}

#pragma mark - Event handlers

-(IBAction)imageTappedFriendsWithMumbler:(id)sender
{
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
