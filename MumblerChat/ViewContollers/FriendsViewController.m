//
//  FriendsViewController.m
//  MumblerChat
//


#import "FriendsViewController.h"
#import "FriendTableViewCell.h"
#import "ASAppDelegate.h"
#import "User.h"
#import "ChatMessageDao.h"
#import "FriendDao.h"
#import "MumblerFriendship.h"
#import "ChatComposerViewController.h"
#import "NSData+Base64.h"
#import "XMPPvCardTemp.h"
#import "XMPPFramework.h"
#import "UserDao.h"


#define colorTheme [UIColor colorWithRed:233.0/255.0 green:153.0/255.0 blue:6.0/255.0 alpha:1]
@interface FriendsViewController (){
    User *mumblerUserFriend;
    BOOL recognizeLongPressGesture;
    
    ChatMessageDao *chatMessageDao;
    FriendDao *friendDao;
    NSString *mumblerFriendId;
    
}

@end

@implementation FriendsViewController
@synthesize friendsTableView;
@synthesize friendsDictionary;
@synthesize actionType;
@synthesize messageNeedToBeSend;
@synthesize composedChatMsg;


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    self.fetchedResultsController.delegate=nil;
    self.fetchedResultsController=nil;
    self.friendsTableView.dataSource=nil;
    self.friendsTableView.delegate=nil;
    
}


- (void)viewWillAppear:(BOOL)animated
{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    appDelegate = (ASAppDelegate *)[UIApplication sharedApplication].delegate;
    self.friendsTableView.dataSource=self;
    self.friendsTableView.delegate=self;
    
    chatMessageDao = [[ChatMessageDao alloc] init];
    friendDao = [[FriendDao alloc] init];
    
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipe.direction = (UISwipeGestureRecognizerDirectionLeft);
    [self.view addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipe.direction = (UISwipeGestureRecognizerDirectionRight);
    [self.view addGestureRecognizer:rightSwipe];
    
    //friend or friends need to be selected
    if([actionType isEqualToString:ACTION_TYPE_FRIEND_TO_BE_SELECTED]){
        NSLog(@" viewWillAppear message need to be send= %@",messageNeedToBeSend);
        NSLog(@" viewWillAppear composed message = %@",composedChatMsg);
        
    } else {
        //nomal way
        NSLog(@" viewWillAppear normal way ");
    }
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //exit(-1);  // Fail
    }
    [self loadXmppContacts];
}

- (ASAppDelegate *)appDelegate
{
    return (ASAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    return view;
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
    
    [headerView addSubview:label];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionInfo = _fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:sectionIndex];
    NSString *section= [sectionInfo name];
    
    NSString *sectionTitle =nil;
    switch (section.intValue) {
        case 1:
            sectionTitle=@"Best Friends";
            break;
        case 2:
            sectionTitle=@"Friends";
            break;
        case 3:
            sectionTitle=@"Blocked Friends";
            break;
        default:
            sectionTitle=@"";
            break;
            
    }
    
    return sectionTitle;
}


- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MumblerFriendship"
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"friendshipStatus"
                                                         ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:10];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:managedObjectContext
                                          sectionNameKeyPath:@"friendshipStatus"
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MumblerFriendship *friendship = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    FriendTableViewCell *tablecell = (FriendTableViewCell *)cell;
    tablecell.selectionStyle=UITableViewCellSelectionStyleNone;
    tablecell.displayNameOne.text = friendship.friendMumblerUser.name;
    tablecell.displayNameTwo.text = friendship.friendMumblerUser.userProfileStatus;
    
    NSData *data = [NSData dataFromBase64String:friendship.friendMumblerUser.profileImageBytes];
    UIImage *image= [UIImage imageWithData:data];
    
    if(image){
        tablecell.profileImageView.image=image;
        
    }else{
        tablecell.profileImageView.image=[UIImage imageNamed:@"mumbler_profile_picture"];
        
    }
    
    //  NSLog(@"friendship.friendMumblerUser.profileImageBytes === %@",friendship.friendMumblerUser.profileImageBytes);
    
    
    //friend or friends need to be selected
    if([actionType isEqualToString:ACTION_TYPE_FRIEND_TO_BE_SELECTED]){
        
        NSLog(@"message need to be send= %@",messageNeedToBeSend);
        tablecell.friendCellType = FriendCellTypeFriendsToBeSelectedToSendMsgs;
        tablecell.friendUser = friendship.friendMumblerUser;
        
        
    }else{
        //nomal way
        if([friendship.friendMumblerUser.onlineStatus isEqualToString:@"online"]){
            
            //tablecell.displayNameTwo.text = friendship.friendMumblerUser.onlineStatus;
            
            tablecell.friendCellType = FriendCellTypeFriendsOnline;
        }else{
            
            // tablecell.displayNameTwo.text = @"offline";
            
            tablecell.friendCellType = FriendCellTypeFriendsOffline;
        }
        
    }
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableIdentifier = @"Friend_status_Cell";
    
    FriendTableViewCell *tablecell = (FriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    
    //friend or friends need to be selected
    //gesture
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.numberOfTouchesRequired = 1;
    tablecell.tag = indexPath.row;
    [tablecell addGestureRecognizer:singleTapGestureRecognizer];
    
    if(![actionType isEqualToString:ACTION_TYPE_FRIEND_TO_BE_SELECTED]){
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 2.0; //seconds
        lpgr.delegate = self;
        [self.friendsTableView addGestureRecognizer:lpgr];
        
    }
    
    
    //gesture
    [self configureCell:tablecell atIndexPath:indexPath];
    return tablecell;
}

# pragma mark - Gesture recognizers

-(void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if(!recognizeLongPressGesture) {
        if (longPress.state == UIGestureRecognizerStateEnded) {
            recognizeLongPressGesture=true;
            //DDLogVerbose(@"%@: %@: UIGestureRecognizerStateEnded", THIS_FILE, THIS_METHOD);
            NSLog(@"UIGestureRecognizerStateEnded");
            
            CGPoint p = [longPress locationInView:self.friendsTableView];
            
            NSIndexPath *indexPath = [self.friendsTableView indexPathForRowAtPoint:p];
            
            MumblerFriendship *friendship = [_fetchedResultsController objectAtIndexPath:indexPath];
            
            mumblerUserFriend=friendship.friendMumblerUser;
            
            // DDLogVerbose(@"%@: %@: selected friendMumblerUser handleLongPress= %@ ", THIS_FILE, THIS_METHOD,mumblerUserFriend);
            NSLog(@"selected friendMumblerUser handleLongPress");
            
            
            [self performSegueWithIdentifier:@"selectedFriend_ChatComposer" sender:self];
            
        }
    }
}

- (IBAction)swipeLeft:(id)sender
{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    [self performSegueWithIdentifier:@"leftChatThreadScreen" sender:self];
    //chat thread
    //friendsToBeAddedToComposeTheMessage
    if([appDelegate.friendsToBeAddedToComposeTheMessageDictionary count] > 0){
        ChatMessageDao *chatMessageDao = [[ChatMessageDao alloc] init];
        [chatMessageDao saveComposedChatMessageWithFriends:composedChatMsg];
    }
}

- (IBAction)swipeRight:(id)sender
{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectedFriend_ChatComposer"]) {
        NSLog(@"start selectedFriend_ChatComposer prepareForSegue");
        
        ChatComposerViewController *chatComposerViewController = (ChatComposerViewController *) [segue destinationViewController];
        chatComposerViewController.actionType = ACTION_TYPE_WITH_FRIEND;
        chatComposerViewController.mumblerFriend=mumblerUserFriend;
        recognizeLongPressGesture=false;
        
        NSLog(@"finished selectedFriend_ChatComposer prepareForSegue");
        
    }
    
}

- (void)dispalyFindAndAddFriendsScreen{
    DDLogVerbose(@"%@: %@: START", THIS_FILE, THIS_METHOD);
    
    [self performSegueWithIdentifier:@"addAndFindFriends_screen" sender:self];
    
    DDLogVerbose(@"%@: %@: END", THIS_FILE, THIS_METHOD);
}


-(void)cellTapped:(UITapGestureRecognizer*)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        NSLog(@"cellTapped UIGestureRecognizerStateEnded");
        
        CGPoint p = [tap locationInView:self.friendsTableView];
        NSIndexPath *indexPath = [self.friendsTableView indexPathForRowAtPoint:p];
        MumblerFriendship *friendship = [_fetchedResultsController objectAtIndexPath:indexPath];
        mumblerFriendId = friendship.friendMumblerUser.userId;
        
        DDLogVerbose(@"%@: %@: selected friend mumblerId= %@ ", THIS_FILE, THIS_METHOD,mumblerFriendId);
        
        
        
        if(![actionType isEqualToString:ACTION_TYPE_FRIEND_TO_BE_SELECTED]){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:nil delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Block",@"Cancel",nil];
            [alert show];
            
            
        }else{
            
            
            if([appDelegate.friendsToBeAddedToComposeTheMessageDictionary objectForKey:mumblerFriendId] == nil){
                
                [appDelegate.friendsToBeAddedDictionary setObject:friendship.friendMumblerUser forKey:mumblerFriendId];
                
            }else{
                
                [appDelegate.friendsToBeAddedToComposeTheMessageDictionary removeObjectForKey:mumblerFriendId];
                
                
                
            }
        }
        
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        
        //delete friend
        DDLogVerbose(@"%@: %@: Delete Button pressed", THIS_FILE, THIS_METHOD);
        //DB CALLS
        
        NSString *meMumblerUserId= [NSString stringWithFormat:@"%@",[NSUserDefaults.standardUserDefaults valueForKey:MUMBLER_USER_ID]];
        
        [chatMessageDao removeChatThreadForDeletedUser:mumblerFriendId myUserId:meMumblerUserId];
        [friendDao deleteFriendWithFriendship:mumblerFriendId];
        
        NSString *selectedFriendUserId=[NSString stringWithFormat:@"%@%@",mumblerFriendId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
        
        XMPPJID *removeBuddy = [XMPPJID jidWithString:selectedFriendUserId];
        
        [[[self appDelegate] xmppRoster] removeUser:removeBuddy];
        
    }
    else if (buttonIndex == 1)
    {
        //block friend
        DDLogVerbose(@"%@: %@: Block Button pressed", THIS_FILE, THIS_METHOD);
        NSString *selectedFriendUserId=[NSString stringWithFormat:@"%@%@",mumblerFriendId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
        
        XMPPJID *blockBuddy = [XMPPJID jidWithString:selectedFriendUserId];
        
        [[[self appDelegate] xmppRoster] unsubscribePresenceFromUser:blockBuddy];
        
        [friendDao blockFriend:mumblerFriendId];
        
        
    }
    else if (buttonIndex == 3)
    {
        //cancel friend
        [alertView dismissWithClickedButtonIndex:(buttonIndex) animated:YES];
        
        
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.friendsTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.friendsTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            /*[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];*/
            
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.friendsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.friendsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.friendsTableView endUpdates];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadXmppContacts
{
    NSArray *xmppContactsArray = [[NSArray alloc]init];
    
    xmppContactsArray=[self getEntities:@"XMPPUserCoreDataStorageObject"];
    NSLog(@"XMPPUser..........%@",xmppContactsArray);
    
    for (XMPPUserCoreDataStorageObject *user in xmppContactsArray) {
        
        NSLog(@"allContactsArray displayName =%@",user.displayName);
        NSLog(@"allContactsArray jidStr =%@",user.displayName);
        NSLog(@"allContactsArray nickname==%@",user.nickname);
        
        NSLog(@"allContactsArray user.photo==%@",user.photo);
        NSLog(@"allContactsArray user==%@",user);
        
        NSArray* tempArray = [user.jidStr componentsSeparatedByString: @"@"];
        NSString *userId = [tempArray objectAtIndex: 0];
        
        FriendDao *friednDao=[[FriendDao alloc] init];
        [friednDao addFriendshipsForNewFriend:userId:user.displayName :@""];
        XMPPvCardCoreDataStorage *xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
        XMPPvCardTempModule *xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
        
        //            dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        //            dispatch_async(queue, ^{
        [xmppvCardTempModule  activate:[[self appDelegate] xmppStream]];
        
        XMPPJID *usertst=[XMPPJID jidWithString:user.jidStr];
        XMPPvCardTemp *vCard = [xmppvCardTempModule vCardTempForJID:usertst shouldFetch:YES];
        // NSLog(@"vcard requested from chats view=== %@",vCard.givenName);
        if(vCard!=nil){
            NSLog(@"vcard requested from Friends view view=== %@",vCard.jid);
            // NSLog(@"vcard requested from Friends view view=== %@",vCard.photo);
            //[vCard.photo base64EncodedString]givenName
            
            if(vCard.photo){
                NSLog(@"UPDATING PHOTO FOR vCard.jid= %@",vCard.jid);
                NSLog(@"UPDATING PHOTO FOR givenName= %@",vCard.formattedName);
                
                UserDao *userDao = [[UserDao alloc] init];
                [userDao updateUserByVcard:userId :[vCard.photo base64EncodedString]:vCard.givenName];
                [self.friendsTableView reloadData];
                
            }
            
        }
        //   });
        
    }
    [self.friendsTableView reloadData];
    
}

- (NSArray *)getEntities:(NSString *)entityName
{
    NSManagedObjectContext *managedObjectContext = [[self appDelegate] managedObjectContext_roster];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (objects != nil) {
        return objects;
    } else {
        return nil;
    }
}

@end
