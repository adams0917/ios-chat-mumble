
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "XMPPFramework.h"
#import <Foundation/Foundation.h>
#import "FacebookSDK/FacebookSDK.h"
#import "XMPPStreamManagement.h"

@interface ASAppDelegate : UIResponder <UIApplicationDelegate,XMPPRoomDelegate,FBLoginViewDelegate>{
    XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    XMPPStreamManagement *xmppStreamManagement;
    
   
	
	NSString *password;
	
	BOOL customCertEvaluation;
	
	BOOL isXmppConnected;
	
	UIWindow *window;
	UINavigationController *navigationController;
    //ASContactsViewController *contactsViewController;
    UIBarButtonItem *loginButton;
    NSMutableArray *gropNamesArray;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPStreamManagement *xmppStreamManagement;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

//@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navigationController;
//@property (nonatomic, strong) IBOutlet SettingsViewController *settingsViewController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *loginButton;
@property (nonatomic, strong) XMPPPresence *tempPresence;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;//models handling
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@property(nonatomic,strong) NSMutableDictionary * profileImagesDictionary;


- (NSURL *)applicationDocumentsDirectory;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

- (BOOL)connect;
- (void)disconnect;

@property(nonatomic,retain) NSMutableArray *addedFriendsInSearch;
//@property(nonatomic,retain) NSMutableArray *addedFriendsInContactsSelectedForSendingText;
@property(nonatomic,retain) NSMutableArray *addedFriendsInFaceBook;

//All
//@property(nonatomic,retain) NSMutableArray *friendsToBeAdded;
@property(nonatomic,strong) NSMutableDictionary * friendsToBeAddedDictionary;

//Contacts..contacts screen
@property(nonatomic,retain) NSMutableArray *friendsWithMumblerInContacts;

//invites  friends in contacts
@property(nonatomic,retain) NSMutableArray *InviteFriendsInContacts;
@property(nonatomic,strong) NSMutableDictionary * inviteFriendsInContactsDictionary;


//Friends..chat composer
@property(nonatomic,retain) NSMutableDictionary *friendsToBeAddedToComposeTheMessageDictionary;


@end
