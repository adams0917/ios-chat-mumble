
//  ASAppDelegate.m
//  MumblerChat


#import "Constants.h"
#import "ASAppDelegate.h"
#import "XMPPRosterCoreDataStorage.h"

#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"

#import <Foundation/Foundation.h>
#import "NSString+MumblerStringUtils.h"


#import "DDLog.h"
#import "DDTTYLogger.h"


#import "ChatMessageDao.h"

#import "JSONKit.h"

#import <CFNetwork/CFNetwork.h>

#import "XMPPRoomMemoryStorage.h"
#import "XMPPvCardTemp.h"
#import "UserDao.h"
#import "NSData+Base64.h"
#import "FacebookSDK/FacebookSDK.h"
#import "FriendDao.h"
#import "XMPPStreamManagement.h"
#import "XMPPStreamManagementMemoryStorage.h"
#import "ChatUtil.h"
#import "FriendDao.h"
#import "SBJson.h"



// Log levels: off, error, warn, info, verbose



NSString * const XMPPAuthenticationMethodPlain = @"Plain";
NSString * const XMPPAuthenticationMethodDigestMD5 = @"Digest-MD5";

NSString * const OptionHostName = @"...";
NSUInteger const OptionPort = 5222;
BOOL const OptionOldSchoolSSL = NO;
NSString * const OptionJID = @"...";
NSString * const OptionAuthenticationMethod = @"Digest-MD5";
NSString * const OptionPassword = @"...";

@implementation ASAppDelegate{
    
    ChatMessageDao *chatMessageDao;
    
}

@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;

@synthesize xmppStream;
@synthesize xmppStreamManagement;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;

@synthesize window;
@synthesize navigationController;
@synthesize loginButton;
@synthesize tempPresence;

NSString *const FBSessionStateChangedNotification = @"com.mumblerchat:FBSessionStateChangedNotification";



@synthesize addedFriendsInSearch;
//@synthesize addedFriendsInContactsSelectedForSendingText;
@synthesize addedFriendsInFaceBook;


//@synthesize friendsToBeAdded;
@synthesize friendsWithMumblerInContacts;
@synthesize InviteFriendsInContacts;

@synthesize profileImagesDictionary;
@synthesize friendsToBeAddedDictionary;
@synthesize inviteFriendsInContactsDictionary;

//friends screen
@synthesize friendsToBeAddedToComposeTheMessageDictionary;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBLoginView class];
    [FBProfilePictureView class];
    
    //CHECK AND REMOVE
    addedFriendsInFaceBook = [[NSMutableArray alloc]init];
    addedFriendsInSearch = [[NSMutableArray alloc]init];
    //no need later
    //friendsToBeAdded = [[NSMutableArray alloc]init];
    friendsWithMumblerInContacts = [[NSMutableArray alloc]init];
    //addedFriendsInContactsSelectedForSendingText = [[NSMutableArray alloc]init];
    
    
    //Dictionary to add friends from search and contact
    friendsToBeAddedDictionary =[[NSMutableDictionary alloc]init];
    //Dictionary to invite friends in contact
    inviteFriendsInContactsDictionary=[[NSMutableDictionary alloc]init];
    
    friendsToBeAddedToComposeTheMessageDictionary= [[NSMutableDictionary alloc]init];
    
    
    // Configure logging framework
	[DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
    
    // Setup the XMPP stream
    
	[self setupStream];
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store
	// enough application state information to restore your application to its current state in case
	// it is terminated later.
	//
	// If your application supports background execution,
	// called instead of applicationWillTerminate: when the user quits.
	
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
#if TARGET_IPHONE_SIMULATOR
	DDLogError(@"The iPhone simulator does not process background network traffic. "
			   @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
#endif
    
	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
	{
		[application setKeepAliveTimeout:600 handler:^{
			
			DDLogVerbose(@"KeepAliveHandler");
			
			// Do other keep alive stuff here.
		}];
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
	NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
	xmppStream = [[XMPPStream alloc] init];
   	
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
	
	// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    
    
    xmppStreamManagement = [[XMPPStreamManagement alloc] initWithStorage:[XMPPStreamManagementMemoryStorage new]];
    
    // And then configured however you like.
    // This is just an example:
    xmppStreamManagement.autoResume = YES;
    xmppStreamManagement.ackResponseDelay = 0.2;
    
    [xmppStreamManagement automaticallyRequestAcksAfterStanzaCount:3 orTimeout:0.4];
    [xmppStreamManagement automaticallySendAcksAfterStanzaCount:10 orTimeout:5.0];
    
    
    
	// Activate xmpp modules
    
	[xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
	[xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];
    [xmppStreamManagement activate:xmppStream];
    
    
    //  [XMPPRoom      activate:xmppStream];
    // [xmppCapabilities      activate:xmppStream];
    
    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppStreamManagement addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
	// Optional:
	//
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	//
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	//
	// If you don't specify a hostPort, then the default (5222) will be used.
	
    //54.198.191.57
	[xmppStream setHostName:BASE_IP];
    // [xmppStream setHostName:@"192.168.2.102"];
    
	[xmppStream setHostPort:5222];
	
    
	// You may need to alter these settings depending on the server you're connecting to
	customCertEvaluation = YES;
}
- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// https://github.com/robbiehanson/XMPPFramework/wiki/WorkingWithElements

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    //    if([domain isEqualToString:@"gmail.com"]
    //       || [domain isEqualToString:@"gtalk.com"]
    //       || [domain isEqualToString:@"talk.google.com"])
    //    {
    NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
     NSXMLElement *status = [NSXMLElement elementWithName:@"status" stringValue:@"Testing 2222"];
    
    [presence addChild:priority];
    [presence addChild:status];
    
    // }
	
	[[self xmppStream] sendElement:presence];
    //    XMPPRoom *xmppRoom=nil;
    //    NSMutableArray *tempArray= [[NSMutableArray alloc]init];
    //    tempArray= [[NSUserDefaults standardUserDefaults] objectForKey:@"xmppGroupNamesArray"];
    //
    //    for (NSString *groupName in tempArray ) {
    //        NSLog(@"didFinishLaunchingWithOptions testing group array ==== %@",groupName);
    //       ASAppDelegate *dele =(ASAppDelegate *) [[UIApplication sharedApplication]delegate];
    //        XMPPRoomMemoryStorage *rosterstorage = [[XMPPRoomMemoryStorage alloc] init];
    //
    //        xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:rosterstorage jid:[XMPPJID jidWithString:groupName] dispatchQueue:dispatch_get_main_queue()];
    //        [xmppRoom addDelegate:dele delegateQueue:dispatch_get_main_queue()];
    //        [xmppRoom activate:dele.xmppStream];
    //        [xmppRoom joinRoomUsingNickname:@"kesh" history:nil];
    ////        NSString *room = [[groupName stringByAppendingString:@"@app.xmpp.syn.in"] stringByAppendingString:@"Kesh"];
    ////        [presence addAttributeWithName:@"to" stringValue:room];
    //
    //
    //    }
    
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	NSLog(@"goOffline goOffline ");
	[[self xmppStream] sendElement:presence];
}

#pragma mark Connect/disconnect

- (BOOL)connect
{
	if (![xmppStream isDisconnected]) {
        
        
		return YES;
	}
    
	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:@"kXMPPmyJID"];
	NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"kXMPPmyPassword"];
    
	//
	// If you don't want to use the Settings view to set the JID,
	// uncomment the section below to hard code a JID and password.
	//
	// myJID = @"user@gmail.com/xmppframework";
	// myPassword = @"";
	
	if (myJID == nil || myPassword == nil) {
		return NO;
	}
    
	[xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    
    NSLog(@"myjid=== %@",[xmppStream myJID]);
    
	password = myPassword;
    
	NSError *error = nil;
	if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
        
		DDLogError(@"Error connecting: %@", error);
        
		return NO;
	}
    
    
	return YES;
}


- (void)disconnect
{
	[self goOffline];
	[xmppStream disconnect];
}

#pragma mark XMPPStream Delegate


- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	NSString *expectedCertName = [xmppStream.myJID domain];
	if (expectedCertName)
	{
		[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
	}
	
	if (customCertEvaluation)
	{
		[settings setObject:@(YES) forKey:GCDAsyncSocketManuallyEvaluateTrust];
	}
}

- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    NSLog(@"didReceiveTrust");
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	// The delegate method should likely have code similar to this,
	// but will presumably perform some extra security code stuff.
	// For example, allowing a specific self-signed certificate that is known to the app.
	
	dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(bgQueue, ^{
		
		SecTrustResultType result = kSecTrustResultDeny;
		OSStatus status = SecTrustEvaluate(trust, &result);
		
		if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
			completionHandler(YES);
		}
		else {
			completionHandler(NO);
		}
	});
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidSecure");
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidConnect");
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXmppConnected = YES;
    
    
    NSError *error = nil;
    
    NSLog(@"authenticateWithPassword:password == %@",password);
    
    if(password==nil || [password isEqualToString:@"(null)"] || password.length==0){
        NSLog(@"No password,,, registering a user -------");
        //        NSString *tjid = @"1234@tanhai-vps";
        //[[self xmppStream] setMyJID:[XMPPJID jidWithString:tjid]];
        [[self xmppStream] registerWithPassword:@"1qaz2wsx" error:&error];
    }else{
        NSLog(@"authenticating user ");
        if (![[self xmppStream] authenticateWithPassword:@"1qaz2wsx" error:&error])
        {
            NSLog(@"Error authenticating: %@", error);
            DDLogError(@"Error authenticating: %@", error);
        }
        //                NSString *tjid = @"0001@ejabberd.server.chat";
        //                [[self xmppStream] setMyJID:[XMPPJID jidWithString:tjid]];
        //        [[self xmppStream] registerWithPassword:XMPP_PASSWORD error:&error];
    }
    
    Class authClass = nil;
    if ([OptionAuthenticationMethod isEqual:XMPPAuthenticationMethodPlain])
        authClass = [XMPPPlainAuthentication class];
    else if ([OptionAuthenticationMethod isEqual:XMPPAuthenticationMethodDigestMD5])
        authClass = [XMPPDigestMD5Authentication class];
    else {
        DDLogWarn(@"Unrecognized auhthentication method '%@', falling back on Plain",
                  OptionAuthenticationMethod);
        authClass = [XMPPPlainAuthentication class];
    }
    id<XMPPSASLAuthentication> auth = [[authClass alloc] initWithStream:sender
                                                               password:OptionPassword];
    NSError *error1 = nil;
    if (![sender authenticate:auth error:&error1])
        NSLog(@"Error authenticating: %@", error1);
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidAuthenticate");
    
    
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
    /// Check to see we resumed a previous session
    NSArray *stanzaIds = nil;
    if ([xmppStreamManagement didResumeWithAckedStanzaIds:&stanzaIds serverResponse:NULL])
    {
        // Situation A
        NSLog(@"Situation A");
        
    }
    else
    {
        // Situation B
        NSLog(@"Situation B");
        
        // [xmppStream sendElement:[XMPPPresence presence]]; // send available presence
        // [self goOnline];
        
        if ([sender supportsStreamManagement]) {
            [xmppStreamManagement enableStreamManagementWithResumption:YES maxTimeout:0];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"xmppStreamDidAuthenticate" object:nil];
    
    [self goOnline];
    
    
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"didNotAuthenticate");
    DDLogVerbose(@"didNotAuthenticate %@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	//DDLogVerbose(@"didReceiveIQ === %@: %@", THIS_FILE, THIS_METHOD);
    
    NSLog(@"didReceiveIQ === %@",iq);
    NSLog(@"didReceiveIQ  Type New=== %@", iq.type);
    
    NSLog(@"didReceiveIQ   New TO === %@", iq.to);
    
    
    if([iq isGetIQ]){
        
        
        NSLog(@"isGetIQ New === ");
        
    }
    else if([iq isSetIQ]){
        
        NSLog(@"isSetIQ === ");
        
        NSXMLElement *child = [iq childElement];
        
        NSLog(@"CHILD ELEMNT %@",child);
        
        XMPPIQ *childIq=[XMPPIQ iqFromElement:child];
        
        NSXMLElement *itemElement =[childIq elementForName:@"item"];
        
        NSLog(@"itemElement %@",itemElement);
        
        NSString *subscriptionElement = [[itemElement
                                          attributeForName:@"subscription"] stringValue];
        
        NSString *jid = [[itemElement
                          attributeForName:@"jid"] stringValue];
        
        NSLog(@"jid %@",jid);
        
        if(subscriptionElement!=nil){
            NSLog(@"subscriptionElement is not nil %@",subscriptionElement);
            
            if([subscriptionElement isEqualToString:@"none"] || [subscriptionElement isEqualToString:@"to"] || [subscriptionElement isEqualToString:@"from" ] || [subscriptionElement isEqualToString:@"both"]){
                //update the db
                
                FriendDao *friendDao=[[FriendDao alloc]init];
                
                NSArray *arr = [jid componentsSeparatedByString:@"@"];
                if (arr)
                {
                    NSString * firstString = [arr objectAtIndex:0];
                    NSLog(@"CREATED FRIEND ID %@",firstString);
                }
                
                NSString* newBuddyId=[arr objectAtIndex:0];
                [friendDao updateFriendshipWithEjabberdStatusFor:newBuddyId];
                
                
            }
            
            
        }else{
            NSLog(@"subscriptionElement is nil");
        }
        
        
    }
    
    
    NSXMLElement *vCardPhotoElement = (NSXMLElement *)[[iq
                                                        elementForName:@"vCard"] elementForName:@"PHOTO"];
    
    NSXMLElement *vCard=(NSXMLElement *)[iq elementForName:@"vCard"];
    
    
    
    NSString *given= [[vCard elementForName:@"GIVEN"] stringValue];
    NSString *nickName= [[vCard elementForName:@"NICKNAME"] stringValue];
    // NSString *photo= [[vCard elementForName:@"PHOTO"] stringValue];
    
    NSString *jabberId= [[vCard elementForName:@"JABBERID"] stringValue];
    NSLog(@"vCard====== %@",vCard);
    NSLog(@"GIVEN====== %@",given);
    NSLog(@"nickName====== %@",nickName);
    NSLog(@"vCardPhotoElement====== %@",vCardPhotoElement);
    NSLog(@"jabberId====== %@",jabberId);
    
    
    
    
    NSLog(@"vCardPhotoElement %@",vCardPhotoElement);
    if (vCardPhotoElement != nil) {
        // avatar data
        NSString *base64DataString = [[vCardPhotoElement
                                       elementForName:@"BINVAL"] stringValue];
        NSData *imageData = [NSData
                             dataFromBase64String:base64DataString];   // you need to get NSData
        UIImage *avatarImage = [UIImage imageWithData:imageData];
        
        XMPPJID *senderJID = [iq from];
        
        NSLog(@"senderJID == %@",senderJID);
        NSLog(@"avatarImage == %@",avatarImage);
        
    }
    /////////////////////Keshan/////////////
    // NSXMLElement *vCard=(NSXMLElement *)[iq elementForName:@"vCard"];
    
    if(vCard!=nil){
        NSXMLElement *vCardTelElement = (NSXMLElement *)[[iq
                                                          elementForName:@"vCard"] elementForName:@"TEL"];
        NSXMLElement *vCardPhotoElement = (NSXMLElement *)[[iq
                                                            elementForName:@"vCard"] elementForName:@"PHOTO"];
        
        NSString *given= [[vCard elementForName:@"GIVEN"] stringValue];
        NSString *nickName= [[vCard elementForName:@"NICKNAME"] stringValue];
        NSString *jabberId= [[vCard elementForName:@"JABBERID"] stringValue];
        NSString *str=[[vCardPhotoElement elementForName:@"BINVAL"] stringValue];
        NSString *phoneNumber=[[vCardTelElement elementForName:@"NUMBER"]stringValue];
        NSString *gender=[[vCard elementForName:@"GENDER"] stringValue];
        NSString *firstName=[[vCard elementForName:@"FN"] stringValue];
        
        NSXMLElement *n=[vCard elementForName:@"N"];
        NSString *middleName=[[n elementForName:@"MIDDLE"] stringValue];
        
        
        
        NSLog(@"11middleName====== %@",middleName);
        NSLog(@"11firstName====== %@",firstName);
        
        
        NSLog(@"11phoneNumber====== %@",phoneNumber);
        NSLog(@"11vCard====== %@",vCard);
        NSLog(@"11GIVEN====== %@",given);
        NSLog(@"11nickName====== %@",nickName);
        NSLog(@"11jabberId====== %@",jabberId);
        NSLog(@"11vCardPhotoElement====== %@",str);
        NSLog(@"11vCardPhotoElement vCardPhotoElement====== %@",vCardPhotoElement);

        NSLog(@"11gender gender gender ==== %@",gender);
        NSString *stringTestTo=[NSString stringWithFormat:@"%@",iq.to];
        
        NSArray* jabberIdArray = [stringTestTo componentsSeparatedByString: @"@"];
        NSString* idString = [jabberIdArray objectAtIndex: 0];
        
        
        UserDao *userDao = [[UserDao alloc] init];
        User *user= [userDao getUserForId:idString];
        if(str){
            NSLog(@"adding image profile bites to user ==== %@",user.name);
            user.profileImageBytes=str;
        }
        if(user && middleName!=nil){
            NSLog(@"skckjdnjkcndcjdkcnkjsncjknjsdknc user==%@",user.name);
            
            NSError *error;
            NSData *data = [middleName dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:kNilOptions
                                                                           error:&error];
            NSLog(@"phone numbers to server appdelegate-=== %@",jsonResponse);
            
            // NSLog(@"skckjdnjkcndcjdkcnkjsncjknjsdknc user==%@",obj);
            
            
            NSLog(@"usernam IDID %@",user.userId);
            user.alertsStatus=[NSString stringWithFormat:@"%@",[jsonResponse valueForKey:@"alerts"]];
            user.saveOutgoingMediaStatus=[NSString stringWithFormat:@"%@",[jsonResponse valueForKey:@"save_out_going_media"]];
            user.whoCanSendMeMessages=[NSString stringWithFormat:@"%@",[jsonResponse valueForKey:@"who_can_message"]];
            user.timeGivenToRenspond=[NSString stringWithFormat:@"%@",[jsonResponse valueForKey:@"global_timer"]];
            
        }
        
        
        
	}
    
    
    
    
	
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	
    if(chatMessageDao == nil){
        chatMessageDao = [[ChatMessageDao alloc] init];
    }
    
    
    //////////////////Added
    NSLog(@"xmppStream didReceiveMessage ===");
    NSLog(@"xmppStream didReceiveMessage === %@",message);
    
    NSString *type = [[message attributeForName:@"type"]stringValue];
    
    if ([[type lowercaseString] isEqualToString:@"chat"]) {
        NSString *to = [[message attributeForName:@"to"]stringValue];
        NSString *from = [[message attributeForName:@"from"]stringValue];
        NSString *messageId = [[message attributeForName:@"id"]stringValue];
        NSString *body = [[message elementForName:@"body"] stringValue];
        
        
        NSRange range = [from rangeOfString:@"@"];
        NSString *fromEjabberdUser = [from substringToIndex:range.location];
        
        
        NSRange rangeTo = [to rangeOfString:@"@"];
        NSString *toEjabberdUser = [to substringToIndex:rangeTo.location];
        
        NSRange rangeLastThreadOwner = [to rangeOfString:@"@"];      NSString *lastThreadOwner = [from substringToIndex:rangeLastThreadOwner.location];
        
        UserDao *userDao = [[UserDao alloc] init];
        FriendDao *friendDao = [[FriendDao alloc] init];
        User *userTo= [userDao getUserForId:toEjabberdUser];
        User *userFrom= [userDao getUserForId:fromEjabberdUser];
        
        
        
        NSXMLElement *extras=[message elementForName:@"extras"];
        NSString *messageThreadId = [[extras attributeForName:THREAD_ID]stringValue];
        
        NSString *messageMedium = [[extras attributeForName:MESSAGE_MEDIUM]stringValue];
        
        NSString *timeToRespond = [[extras attributeForName:TIME_GIVEN_TO_RESPOND]stringValue];
        
        if(timeToRespond == nil){
            timeToRespond = @"21";
        }
        
        
        int respondTime =[timeToRespond intValue];
        
        BOOL saveMessage = NO;
        
        //if userFrom is != nil..no issue
        
        if(userFrom == nil){
            
            NSLog(@"userFrom == ");
            
            //if userFrom is == nil
            userTo.whoCanSendMeMessages = @"EVERYONE";
            
            //check who can message me
            //everyone
            if([userTo.whoCanSendMeMessages isEqualToString:@"EVERYONE"]){
                NSLog(@"userFrom == EVERYONE");
                
                saveMessage = YES;
                
                //If it is everyone..need to create a friend user and save the msg
                
                NSString *senderUsername = [[extras attributeForName:SENDER_USERNAME]stringValue];
                
                
                [friendDao addFriendshipsForNewFriend:fromEjabberdUser :senderUsername :@""];
                
                NSString *fromEjabberdUserId=[NSString stringWithFormat:@"%@%@",fromEjabberdUser,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
                
                XMPPJID *newBuddy = [XMPPJID jidWithString:fromEjabberdUserId];
                [[self xmppRoster] addUser:newBuddy withNickname:senderUsername];
                
                
                userFrom= [userDao getUserForId:fromEjabberdUser];
                
                
            }else{
                //only FRIENDS
                NSLog(@"userFrom == FRIENDS");
                
            }
            
        }else{
            
            NSLog(@"userFrom != ");
            saveMessage = YES;
            
        }
        
        ///////////
        
        if(saveMessage){
            
            
            NSString *timeInMiliseconds = [ChatUtil getTimeInMiliSeconds:[NSDate date]];
            
            NSString *deliverdDate= [ChatUtil getDate:timeInMiliseconds inFormat:@"EEEE, MMMM dd, yyyy"];
            
            
            if([messageMedium isEqual:MESSAGE_MEDIUM_TEXT]){//text
                
                NSString *textType = [[extras attributeForName:TEXT_TYPE]stringValue];
                
                
                //normal chat
                if([textType isEqual:TEXT_TYPE_STATEMENT]){
                    
                    //chat
                    //messageId senderEjabberdId:fromEjabberdUser recipientEjabberdId:to
                    
                    //sender will be the me(current user)
                    
                    //recipient will be the one who sent the msg
                    
                    [chatMessageDao saveChatMessageWithThreadId:messageThreadId  messageId:messageId senderUser:userTo recipient:userFrom messageMedium:MESSAGE_MEDIUM_TEXT messageContent:body messageDateTime:timeInMiliseconds deliveredDateTime:deliverdDate messageDelivered:[NSNumber numberWithInt:1] imageEncodedString:nil sentSeen:[NSNumber numberWithInt:0]threadLastMessage:lastThreadOwner receiveType:RECEIVE_TYPE_INCOMING timeGivenToRespond:[NSNumber numberWithInt:respondTime]chatTextType:TEXT_TYPE_STATEMENT];
                    
                    
                }
                else if([textType isEqual:TEXT_TYPE_QUESTION]){
                    
                    //question
                    
                    [chatMessageDao saveChatMessageWithThreadId:messageThreadId  messageId:messageId senderUser:userTo recipient:userFrom messageMedium:MESSAGE_MEDIUM_TEXT messageContent:body messageDateTime:timeInMiliseconds deliveredDateTime:deliverdDate messageDelivered:[NSNumber numberWithInt:1] imageEncodedString:nil sentSeen:[NSNumber numberWithInt:0]threadLastMessage:lastThreadOwner receiveType:RECEIVE_TYPE_INCOMING timeGivenToRespond:[NSNumber numberWithInt:respondTime]chatTextType:TEXT_TYPE_QUESTION];
                    
                }
                
                
            }else if([messageMedium isEqual:MESSAGE_MEDIUM_IMAGE]){
                //image
                
                [chatMessageDao saveChatMessageWithThreadId:messageThreadId  messageId:messageId senderUser:userTo recipient:userFrom messageMedium:MESSAGE_MEDIUM_IMAGE messageContent:body messageDateTime:timeInMiliseconds deliveredDateTime:deliverdDate messageDelivered:[NSNumber numberWithInt:1] imageEncodedString:nil sentSeen:[NSNumber numberWithInt:0]threadLastMessage:lastThreadOwner receiveType:RECEIVE_TYPE_INCOMING timeGivenToRespond:[NSNumber numberWithInt:respondTime]chatTextType:nil];
                
                
                
            }else if([messageMedium isEqual:MESSAGE_MEDIUM_VIDEO]){
                //video
                
                [chatMessageDao saveChatMessageWithThreadId:messageThreadId  messageId:messageId senderUser:userTo recipient:userFrom messageMedium:MESSAGE_MEDIUM_VIDEO  messageContent:body messageDateTime:timeInMiliseconds deliveredDateTime:deliverdDate messageDelivered:[NSNumber numberWithInt:1] imageEncodedString:nil sentSeen:[NSNumber numberWithInt:0]threadLastMessage:lastThreadOwner receiveType:RECEIVE_TYPE_INCOMING timeGivenToRespond:[NSNumber numberWithInt:respondTime]chatTextType:nil];
                
            }
            
            NSXMLElement *seenReceived=[message elementForName:@"seen_received"];
            if(seenReceived!=nil){
                NSString *seenMessageId=[[seenReceived attributeForName:@"seen"] stringValue];
                NSLog(@"seenMessageId ===%@",seenMessageId);
                [self updateMessageSeenState:seenMessageId];
            }
            
            
            NSXMLElement *messageReceived=[message elementForName:@"received"];
            NSLog(@"messageReceived====== %@",messageReceived);
            
            if(messageReceived!=nil){
                NSString *deliveredMessageId=[[messageReceived attributeForName:@"id"] stringValue];
                NSLog(@"message delivered MessageId ===%@",deliveredMessageId);
                [self updateMessageDeliveredState:deliveredMessageId];
            }
            
            
        }
        
        
        
    }
    
    
    ///////////////////Addded over
    
    
    NSXMLElement *messageReceived=[message elementForName:@"received"];
    NSLog(@"messageReceived====== %@",messageReceived);
    
    if(messageReceived!=nil){
        NSString *deliveredMessageId=[[messageReceived attributeForName:@"id"] stringValue];
        NSLog(@"message delivered MessageId ===%@",deliveredMessageId);
        [self updateMessageDeliveredState:deliveredMessageId];
    }
    
    XMPPRoom *xmppRoom=nil;
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSLog(@"didReceivePresence %@ ",presence);
	DDLogVerbose(@"didReceivePresence === %@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
    
    
    NSString *presenceType = [presence type];            // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    NSString *myStatus=[presence status];
    
    NSLog(@"didReceivePresence presenceType ==%@",presenceType);
    NSLog(@"didReceivePresence myUsername ==%@",myUsername);
    NSLog(@"didReceivePresence presenceFromUser ==%@",presenceFromUser);
    NSLog(@"didReceivePresence mystatus ==%@",myStatus);
    
    
    
    //new request from unknow user
    if (![presenceFromUser isEqualToString:myUsername])
    {
        if  ([presenceType isEqualToString:@"subscribe"])
        {
            //[_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, kHostName]];
            NSLog(@"AddBuddy didReceivePresence presence user wants to subscribe %@",presenceFromUser);
            tempPresence = [[XMPPPresence alloc] init];
            tempPresence = presence;
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New request From:" message:presenceFromUser delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            //            [alert show];
            
            //accept request
            //[xmppRoster subscribePresenceToUser:[tempPresence from]];
            [xmppRoster acceptPresenceSubscriptionRequestFrom:[tempPresence from] andAddToRoster:NO];
            
        }else if([presenceType isEqualToString:@"available"]) {
            
            NSLog(@"YES %@ is online", presenceFromUser);
            UserDao *userDao = [[UserDao alloc] init];
            [userDao updateUserOnlineStatus :presenceFromUser:@"online":myStatus];
            
            
            NSMutableDictionary *dict=[[NSMutableDictionary alloc]initWithDictionary:@{@"userId":presenceFromUser,@"state":@"online"}];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userStateUpdated" object:dict];
            
            
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            
            NSLog(@"YES %@ is offline", presenceFromUser);
            
            UserDao *userDao = [[UserDao alloc] init];
            [userDao updateUserOnlineStatus:presenceFromUser :@"offline":myStatus];
            
            
            NSMutableDictionary *dict=[[NSMutableDictionary alloc]initWithDictionary:@{@"userId":presenceFromUser,@"state":@"offline"}];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userStateUpdated" object:dict];
            
        }
    }
       /* xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
        xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
     //  dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
     //   dispatch_async(queue, ^{
    
    [xmppvCardTempModule  activate:xmppStream];
    
    NSString *userId=[NSString stringWithFormat:@"%@%@",presenceFromUser,@"@ejabberd.server.mumblerchat"];
    
    NSLog(@"userId userId userId=== %@",userId);
            XMPPJID *usertst=[XMPPJID jidWithString:userId];
            XMPPvCardTemp *vCard = [xmppvCardTempModule vCardTempForJID:usertst shouldFetch:YES];
            NSLog(@"Vcard === %@",vCard);
            if(vCard!=nil){
                NSLog(@"vcard requested from chats view=== %@",vCard.namespaces);
                NSLog(@"vcard requested from chats view middleName=== %@",vCard.middleName);
               // NSLog(@"vcard requested from chats view nickname=== %@",vCard.photo);
                
                UserDao *userDao = [[UserDao alloc] init];
                User *user= [userDao getUserForId:presenceFromUser];
                if(vCard.photo){
                    NSLog(@"adding image profile bites to user presenceFromUser ==== %@",presenceFromUser);

                    NSLog(@"adding image profile bites to user ==== %@",user.userId);
                    user.profileImageBytes=[vCard.photo base64EncodedString];
                }
                if(user && vCard.middleName!=nil){
                    NSLog(@"skckjdnjkcndcjdkcnkjsncjknjsdknc user==%@",user.name);
                    
                    NSError *error;
                    NSData *data = [vCard.middleName dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                                 options:kNilOptions
                                                                                   error:&error];
                    NSLog(@"phone numbers to server appdelegate-=== %@",jsonResponse);
                    
                    // NSLog(@"skckjdnjkcndcjdkcnkjsncjknjsdknc user==%@",obj);
                    
                    NSLog(@"usernam IDID %@",user.userId);
                    user.alertsStatus=[NSString stringWithFormat:@"%@",[jsonResponse valueForKey:@"alerts"]];
                    user.saveOutgoingMediaStatus=[NSString stringWithFormat:@"%@",[jsonResponse valueForKey:@"save_out_going_media"]];
                    user.whoCanSendMeMessages=[NSString stringWithFormat:@"%@",[jsonResponse valueForKey:@"who_can_message"]];
                    user.timeGivenToRenspond=[NSString stringWithFormat:@"%@",[jsonResponse valueForKey:@"global_timer"]];
                    
                }
                
                NSError *error = nil;
                if([managedObjectContext save:&error] ) {
                    NSLog(@"User updateUserOnlineStatus---------------- change");
                } else {
                    
                    NSLog(@"User updateUserOnlineStatus--------- not change");
                }

                
            }
     //   });*/
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //accept request
    if(buttonIndex==1){
        [xmppRoster subscribePresenceToUser:[tempPresence from]];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"didReceiveError == %@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"xmppStreamDidDisconnect  ===%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
	}
}




- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    
    NSLog(@"didSendMessage ");
    
    
}

- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(NSXMLElement *)item {
    NSLog(@"today item %@ ", item);
}


#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
	DDLogVerbose(@"didReceiveBuddyRequest %@: %@", THIS_FILE, THIS_METHOD);
	
	XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
	                                                         xmppStream:xmppStream
	                                               managedObjectContext:[self managedObjectContext_roster]];
	//NSLog(@"User info===== %@",user);
	NSString *displayName = [user displayName];
	NSString *jidStrBare = [presence fromStr];
	NSString *body = nil;
	
	if (![displayName isEqualToString:jidStrBare])
	{
		body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
	}
	else
	{
		body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
	}
	
    NSLog(@"AddBuddy didReceiveBuddyRequest from === %@",body);
    
	
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
		                                                    message:body
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Not implemented"
		                                          otherButtonTitles:nil];
		[alertView show];
	}
	else
	{
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = @"Not implemented";
		localNotification.alertBody = body;
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
	
}
#pragma mark - Core Data stack


- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MumblerChatDb" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MumblerChat.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


-(NSString *) generateThreadId {
    
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSData *mumblerUserData = [userDefaults valueForKey:@"mumbler_user_json"];
    NSDictionary *mumblerUserDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:mumblerUserData];
    NSString *mumblerUserId = [mumblerUserDictionary valueForKey:@"mumblerUserId"];
    NSString *threadId = [NSString stringWithFormat:@"%@-%f", mumblerUserId, [NSDate timeIntervalSinceReferenceDate]];
    return threadId;
    
}


-(NSString *) generateMessageId:(NSString *) threadId {
    
    NSString *messageId = [NSString stringWithFormat:@"%@-%f", threadId, [NSDate timeIntervalSinceReferenceDate]];
    return messageId;
    
}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitation:(XMPPMessage *)message{
    NSLog(@"didReceiveInvitation === ");
}
- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitationDecline:(XMPPMessage *)message{
    NSLog(@"didReceiveInvitationDecline === ");
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    
    NSLog(@"xmppStreamDidRegister1 =%@",sender);
    NSLog(@"xmppStreamDidRegister2 =%@",sender.myJID);
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",sender.myJID] forKey:@"kXMPPmyJID"];
    [[NSUserDefaults standardUserDefaults] setObject:@"1qaz2wsx" forKey:@"kXMPPmyPassword"];
    
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"xmppStreamDidRegister" object:nil];
    
    if ([self connect])
    {
        NSLog(@"Login logged in as 1234== %@",[[[self xmppStream] myJID] bare]);
        
        NSError *error;
        if (![[self xmppStream] authenticateWithPassword:@"1qaz2wsx" error:&error])
        {
            NSLog(@"Error authenticating after registration: %@", error);
            DDLogError(@"Error authenticating: %@", error);
        }
        
    } else
    {
        NSLog(@"Login logged in as 1234== %@", @"No JID");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Unable to login to xmpp server as 162@jabber.local" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement*)error{
    NSLog(@"Sorry the registration is failed %@",error);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didNotRegister" object:nil];
}

-(void)updateMessageSeenState:(NSString *)messageId{
    
    //NSManagedObjectContext *managedObjectContext = nil;
    
    managedObjectContext = [self managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(messageId = %@)", messageId];
    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"messageDateTime" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    [request setPredicate:predicate];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (objects.count >=1) {
        
        NSLog(@"objects====%@",objects);//seenByUser=1
        
        ChatMessage *c = [objects objectAtIndex:0];
        NSLog(@"chat messag ==== %@",c);
        // c.seenByUser=[NSNumber numberWithInt:1];
        [c setValue:[NSNumber numberWithInt:1] forKey:@"seenByUser"];
        
        
        //yourManagedObject.date = [(UIDatePicker *)sender date];
        
        NSError *error;
        if([managedObjectContext save:&error]){
            NSLog(@"didn't save %@",error);
        }
        
        
    } else {
        NSLog(@"objects are nil====");
    }
    
}
-(void)updateMessageDeliveredState:(NSString *)messageId{
    managedObjectContext = [self managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(messageId = %@)", messageId];
    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"messageDateTime" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    [request setPredicate:predicate];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (objects.count >=1) {
        
        NSLog(@"objects in deliverd====%@",objects);//seenByUser=1
        
        ChatMessage *c = [objects objectAtIndex:0];
        NSLog(@"chat messag deliverd==== %@",c);
        //c.messageDelivered=[NSNumber numberWithInt:2];
        [c setValue:[NSNumber numberWithInt:2] forKey:@"messageDelivered"];
        
        
        //yourManagedObject.date = [(UIDatePicker *)sender date];
        //
        //        NSError *error;
        //        if([managedObjectContext save:&error]){
        //            NSLog(@"didn't save %@",error);
        //        }
        
        
    } else {
        NSLog(@"objects are nil====");
    }
    
}

-(void)sendDeliveryReport:(NSString*)messageId : (NSString*)fromId{
    NSLog(@"sendDeliveryReport messageId=== %@",messageId);
    NSLog(@"sendDeliveryReport fromId=== %@",fromId);
    NSLog(@"delivary sending fron iOS");
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    
    [message addAttributeWithName:@"to" stringValue:fromId];
    
    NSXMLElement *received = [NSXMLElement elementWithName:@"received" URI:@"urn:xmpp:receipts"];
    [message addAttributeWithName:@"id" stringValue:messageId];
    
    [message addChild:received];
    NSLog(@"test------------%@",message.init);
    //[message addAttributeWithName:@"id" stringValue:message.init];
    
    NSLog(@"test_____________message%@",message);
    
    [self.xmppStream sendElement:message];
}

/* if ([message isChatMessageWithBody])
 {
 
 if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
 {
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
 message:body
 delegate:nil
 cancelButtonTitle:@"Ok"
 otherButtonTitles:nil];
 [alertView show];
 }
 else
 {
 // We are not active, so use a local notification instead
 UILocalNotification *localNotification = [[UILocalNotification alloc] init];
 localNotification.alertAction = @"Ok";
 localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
 
 [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
 }
 }*/





@end
