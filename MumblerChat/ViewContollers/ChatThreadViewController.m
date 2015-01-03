//
//  ChatThreadViewController.m
//  MumblerChat
//


#import "ChatThreadViewController.h"
#import "ChatThreadTableViewCell.h"
#import "ChatMessage.h"
#import "ChatThread.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "ChatComposerViewController.h"
#import "Constants.h"
#import "ChatMessageDao.h"
#import "ChatUtil.h"

@interface ChatThreadViewController (){
    ChatThread *chatThread;
    ChatMessageDao *chatMessageDao;
    NSString * meMumblerUserId;
    NSString * meEjabberdId;
    
}

@end

@implementation ChatThreadViewController
@synthesize chatThreadUITableView;
@synthesize isFromSplash;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [DDLog addLogger:DDTTYLogger.sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear Chat Thread");
    
    meMumblerUserId = [NSUserDefaults.standardUserDefaults valueForKey:MUMBLER_USER_ID];
    meEjabberdId=[NSString stringWithFormat:@"%@%@", meMumblerUserId, MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
    
    chatMessageDao = [ChatMessageDao new];
    [self.navigationController setNavigationBarHidden:YES];
    appDelegate = self.appDelegate;
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipe.direction = (UISwipeGestureRecognizerDirectionLeft);
    [self.view addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipe.direction = (UISwipeGestureRecognizerDirectionRight);
    [self.view addGestureRecognizer:rightSwipe];
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

-(void) viewDidDisappear:(BOOL)animated
{
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
}



-(IBAction) didTapOnNewMessageIcon:(id)sender
{
    [self performSegueWithIdentifier:@"newMessage_ChatComposer" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"newMessage_ChatComposer"]) {
        ChatComposerViewController *chatComposerViewController = (ChatComposerViewController *) segue.destinationViewController;
        chatComposerViewController.actionType = ACTION_TYPE_WITHOUT_FRIEND;
    } else if([segue.identifier isEqualToString:@"chatThread_ChatComposer"]) {
        ChatComposerViewController *chatComposerViewController = (ChatComposerViewController *) segue.destinationViewController;
        chatComposerViewController.actionType = ACTION_TYPE_THREAD;
        chatComposerViewController.chatThread = chatThread;
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (ASAppDelegate *)appDelegate
{
    return (ASAppDelegate *) UIApplication.sharedApplication.delegate;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"ChatThread" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort1 = [[NSSortDescriptor alloc]
                               initWithKey:@"threadStatus" ascending:NO];
    
    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc]
                               initWithKey:@"lastUpdatedDateTime" ascending:NO];
    
    
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort1,sort2,nil]];
    
    [fetchRequest setFetchBatchSize:10];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = _fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ChatThread *chatMsgThread = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    long long timeInSeconds = [chatMsgThread.lastUpdatedDateTime longLongValue] / 1000;
    NSDate *tr = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy/MM/dd HH:mm";
    
    NSString *messageDate= [formatter stringFromDate:tr];
    
    ChatThreadTableViewCell *tablecell = (ChatThreadTableViewCell *)cell;
    tablecell.selectionStyle=UITableViewCellSelectionStyleGray;
    
    
    NSString *descriptionText;
    
    if([chatMsgThread.threadLastMessageOwnerId isEqualToString:meEjabberdId]){
        //grey
        //tick
        
        UIImage *imageIcon = [UIImage imageNamed:@"check_icon"];
        tablecell.subMessageStatusImageView.image=imageIcon;
        
        
        if([chatMsgThread.threadLastMessageMedium isEqualToString:MESSAGE_MEDIUM_TEXT]){
            
            if([chatMsgThread.threadLastMessageMediumTextType isEqualToString:TEXT_TYPE_STATEMENT]){
                tablecell.chatThreadCell=ChatThreadCellType_Statement_From_Me;
                descriptionText = [NSString stringWithFormat:@" %@  %@",messageDate,STATEMENT_SENT];
                
                
            }else{
                tablecell.chatThreadCell=ChatThreadCellType_Question_From_Me;
                descriptionText = [NSString stringWithFormat:@" %@  %@",messageDate,QUESTION_SENT];
                
                
            }
            
            tablecell.subUILabel.text = descriptionText;
            
            
            
        }else if([chatMsgThread.threadLastMessageMedium isEqualToString:MESSAGE_MEDIUM_IMAGE]){
            
            tablecell.chatThreadCell=ChatThreadCellType_Image_From_Me;
            descriptionText = [NSString stringWithFormat:@" %@  %@",messageDate,IMAGE_SENT];
            tablecell.subUILabel.text = descriptionText;
            
            
            
            
        }else if([chatMsgThread.threadLastMessageMedium isEqualToString:MESSAGE_MEDIUM_VIDEO]){
            
            tablecell.chatThreadCell=ChatThreadCellType_Video_From_Me;
            descriptionText = [NSString stringWithFormat:@" %@  %@",messageDate,VIDEO_SENT];
            tablecell.subUILabel.text = descriptionText;
            
            
        }
        
    }else{
        //orange
        //replyIcon
        
        UIImage *imageIcon = [UIImage imageNamed:@"reply_icon_right"];
        tablecell.subMessageStatusImageView.image=imageIcon;
        
        
        
        NSString *readStatus=[chatMsgThread.readStatus stringValue];
        
        //opened
        if([readStatus isEqualToString:@"1"]){
            if([chatMsgThread.threadLastMessageMedium isEqualToString:MESSAGE_MEDIUM_TEXT]){
                if([chatMsgThread.threadLastMessageMediumTextType isEqualToString:TEXT_TYPE_STATEMENT]){
                    tablecell.chatThreadCell=ChatThreadCellType_New_Opened_Statement_For_Me;
                    descriptionText = [NSString stringWithFormat:@" %@  %@",messageDate,STATEMENT_RECIEVED];
                    tablecell.subUILabel.text = descriptionText;
                    
                    
                }else{
                    tablecell.chatThreadCell=ChatThreadCellType_New_Opened_Question_For_Me;
                    descriptionText = [NSString stringWithFormat:@" %@  %@",messageDate,QUESTION_RECIEVED];
                    tablecell.subUILabel.text = descriptionText;
                }
                
            }else if([chatMsgThread.threadLastMessageMedium isEqualToString:MESSAGE_MEDIUM_IMAGE]){
                
                tablecell.chatThreadCell=ChatThreadCellType_New_Opened_Image_For_Me;
                descriptionText = [NSString stringWithFormat:@" %@  %@",messageDate,IMAGE_RECIEVED];
                tablecell.subUILabel.text = descriptionText;
                
                
                
            }else if([chatMsgThread.threadLastMessageMedium isEqualToString:MESSAGE_MEDIUM_VIDEO]){
                
                tablecell.chatThreadCell=ChatThreadCellType_New_Opened_Video_For_Me;
                descriptionText = [NSString stringWithFormat:@" %@  %@",messageDate,VIDEO_RECIEVED];
                tablecell.subUILabel.text = descriptionText;
            }
        }
        //non-opened
        else{
            [self startFlashingImage:tablecell.messageStatusImageView];
            if([chatMsgThread.threadLastMessageMedium isEqualToString:MESSAGE_MEDIUM_TEXT]){
                
                if([chatMsgThread.threadLastMessageMediumTextType isEqualToString:TEXT_TYPE_STATEMENT]){
                    tablecell.chatThreadCell=ChatThreadCellType_New_Non_Opened_Statement_For_Me;
                    descriptionText = [NSString stringWithFormat:@" %@  %@",messageDate,STATEMENT_RECIEVED];
                    tablecell.subUILabel.text = descriptionText;
                    
                    
                    
                }else{
                    tablecell.chatThreadCell=ChatThreadCellType_New_Non_Opened_Question_For_Me;
                    ;
                    descriptionText = [NSString stringWithFormat:@" %@  %@",messageDate,QUESTION_RECIEVED];
                    tablecell.subUILabel.text = descriptionText;
                    
                    
                    
                }
                
            }else if([chatMsgThread.threadLastMessageMedium isEqualToString:MESSAGE_MEDIUM_IMAGE]){
                
                tablecell.chatThreadCell=ChatThreadCellType_New_Non_Opened_Image_For_Me;
                descriptionText = [NSString stringWithFormat:@" %@  %@",messageDate,IMAGE_RECIEVED];
                tablecell.subUILabel.text = descriptionText;
                
                
                
            }else if([chatMsgThread.threadLastMessageMedium isEqualToString:MESSAGE_MEDIUM_VIDEO]){
                
                tablecell.chatThreadCell=ChatThreadCellType_New_Non_Opened_Video_For_Me;
                descriptionText = [NSString stringWithFormat:@" %@  %@",messageDate,VIDEO_RECIEVED];
                tablecell.subUILabel.text = descriptionText;
                
                
            }
        }
        
        
    }
    tablecell.messageStatusUILabel.text = chatMsgThread.threadLastMessageMedium;
    tablecell.nameUILabel.text =chatMsgThread.recipient.name;
    
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableIdentifier = @"ChatThreadCell";
    ChatThreadTableViewCell *cell = (ChatThreadTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.chatThreadUITableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.chatThreadUITableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.chatThreadUITableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.chatThreadUITableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.chatThreadUITableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.chatThreadUITableView endUpdates];
}


-(IBAction)swipeLeft:(id)sender{
    NSLog(@"swipeLeft----");
    
    [self performSegueWithIdentifier:@"left_Settings" sender:self];
    
}
-(IBAction)swipeRight:(id)sender{
    NSLog(@"swipeRight----");
    
    if(!isFromSplash) {
        NSLog(@"swipeRight is not FromSplash");
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NSLog(@"swipeRight isFromSplash");
        [self performSegueWithIdentifier:@"chatThread_addFriend" sender:self];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    return view;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatThread *chatThreadInCell = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    
    NSLog(@"CHAT THREAD MESSAGE %@",chatThreadInCell.threadId);
    
    
    if([chatThreadInCell.threadStatus intValue] == ACTIVE_THREAD){
        
        if(![chatThreadInCell.threadLastMessageOwnerId isEqualToString:meEjabberdId]){
            
            chatThread = chatThreadInCell;
            //When Clicking The Thread, Mark it as it read
            
            [chatMessageDao updateChatThreadReadStatus:chatThread.threadId threadStatus:[NSNumber numberWithInt:1]];
            
            //when clicking call upadteLastMessageOpenedTime
            
            if([chatThreadInCell.lastReceivedMessageOpenedTime isEqualToString:@""]){
                NSLog(@"updateLastMessageOpenedTime chatThreadInCell.lastReceivedMessageOpenedTime == nil");
                
                NSString *timeInMiliseconds = [ChatUtil getTimeInMiliSeconds:[NSDate date]];
                
                NSLog(@"updateLastMessageOpenedTime %@",timeInMiliseconds);
                [chatMessageDao updateLastMessageOpenedTime:chatThread.threadId threadLastmessageOpenedTime:timeInMiliseconds];
            }else{
                NSLog(@"updateLastMessageOpenedTime chatThreadInCell.lastReceivedMessageOpenedTime not empty");
                
            }
            
            [self performSegueWithIdentifier:@"chatThread_ChatComposer" sender:self];
            
            
        }else{
            //not selectable
            //I replyed last
            
        }
        
    }else{
        //not selectable
        NSLog(@"CHAT THREAD STATUS NOT ACTIVE ");
        
    }
    
    
}

- (void)startFlashingImage:(id)view
{
    [view setAlpha:1.0f];
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         [view setAlpha:0.0f];
                     }
                     completion:^(BOOL finished){
                         // Do nothing
                     }];
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
