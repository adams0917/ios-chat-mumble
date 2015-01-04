
#import "DDLog.h"
#import "DDTTYLogger.h"


#ifndef MumblerChat_Constants_h
#define MumblerChat_Constants_h

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

//base url
static NSString * const BASE_URL = @"http://54.227.54.114:8080/MumblerChatWeb/";

//Chat
static NSString * const BASE_IP = @"54.227.54.114";
static NSString * const MUMBLER_CHAT_EJJABBERD_SERVER_NAME = @"@ejabberd.server.mumblerchat";
static NSString * const XMPP_CONTAINS_SERACH = @"@ejabberd";
static NSString * const VIDEIO_PATH = @"http://54.198.191.57:8080/MumblerChatWeb/chatVideo/";


//chat compser
static NSString * const ACTION_TYPE = @"action_type";
static NSString * const ACTION_TYPE_WITH_FRIEND = @"action_type_with_seleted_friend";
static NSString * const ACTION_TYPE_WITHOUT_FRIEND = @"action_type_without_friend";
static NSString * const ACTION_TYPE_THREAD = @"action_type_thread";

static NSString * const ACTION_TYPE_FRIEND_TO_BE_SELECTED = @"action_type_friend_to_be_selected";


static NSString * const THREAD_ID = @"thread_id";
static NSString * const TEXT_TYPE = @"text_type";
static NSString * const TEXT_TYPE_QUESTION = @"question";
static NSString * const TEXT_TYPE_STATEMENT = @"statement";

static NSString * const MESSAGE_MEDIUM = @"message_medium";
static NSString * const MESSAGE_MEDIUM_TEXT = @"text";
static NSString * const MESSAGE_MEDIUM_IMAGE = @"image";
static NSString * const MESSAGE_MEDIUM_VIDEO = @"video";
static NSString * const RECEIVE_TYPE_OUTGOING = @"outgoing";
static NSString * const RECEIVE_TYPE_INCOMING = @"incomming";

static NSString * const SENDER_USERNAME = @"sender_username";
static NSString * const TIME_GIVEN_TO_RESPOND = @"time_given_to_respond";


//FriendsScreen
static NSString * const FRIEND = @"2";
static NSString * const BLOCKED_FRIEND = @"3";
static NSString * const BEST_FRIEND = @"1";
static NSString * const IS_FRIENDS_ADDED = @"is_friends_added";

//Chat Thread
static NSInteger const ACTIVE_THREAD = 1;
static NSInteger const IN_ACTIVE_THREAD = 0;

static NSString * const STATEMENT_SENT = @"Statement Sent";
static NSString * const QUESTION_SENT = @"Question Sent";
static NSString * const IMAGE_SENT = @"Image Sent";
static NSString * const VIDEO_SENT = @"Video Sent";

static NSString * const STATEMENT_RECIEVED = @"Statement Recived";
static NSString * const QUESTION_RECIEVED = @"Question Recived";
static NSString * const IMAGE_RECIEVED = @"Image Recived";
static NSString * const VIDEO_RECIEVED = @"Video Recived";


////////////User
static NSString * const MUMBLER_USER_ID = @"mumbler_user_id";
//Username
static NSString * const USERNAME = @"username";
//Password
static NSString * const PASSWORD = @"password";
//FB logged in user_id
static NSString * const FB_USER_ID = @"fb_user_id";
static NSString * const FB_USER_DETAILS = @"fb_user_details";

static NSString * const MUMBLER_USER_IMAGE_URL = @"mumbler_user_image_url";

//Settings
static NSString * const MUMBLER_CHAT_SETTINGS = @"mumbler_chat_settings";
//User Profile
static NSString * const MUMBLER_CHAT_USER_PROFILE = @"mumbler_chat_user_profile";



//Is used before
static NSString * const IS_USED_BEFORE = @"is_used_before";
static NSString * const IS_USED_BEFORE_YES = @"is_used_before_yes";
//Sign in type
static NSString * const SIGN_IN_TYPE = @"sign_in_type";
static NSString * const SIGN_IN_TYPE_FB = @"sign_in_type_fb";
static NSString * const SIGN_IN_TYPE_NORMAL = @"sign_in_type_normal";
//Logout
static NSString * const USER_LOG_OUT = @"user_log_out";
static NSString * const USER_LOG_OUT_YES = @"user_log_out_yes";

//Add & Find Friend Screen
static NSString * const ADD_FRIEND_TAB_TO_SELECTED = @"add_friend_tab_to_be_selected";
static NSString * const ADD_FRIEND_CONTACT_TAB = @"add_friend_contact_tab";
static NSString * const ADD_FRIEND_FACEBOOK_TAB = @"add_friend_facebook_tab";


static NSString * const INTERNET_CONNECTION_AVAILABLE = @"internet_connection_available";
static NSString * const INTERNET_CONNECTION_NOT_AVAILABLE = @"internet_connection_not_available";

static NSString * const FB_SESSION_STATUS = @"fb_session_status";
static NSString * const FB_SESSION_ACTIVE = @"fb_session_active";
static NSString * const FB_SESSION_NOT_ACTIVE = @"fb_session_not_active";

static NSString * const FRIENDS_USING_MUMBLER_IN_CONTACTS = @"friends_using_mumbler_in_contacts";
static NSString * const INVITE_FRIENDS_IN_CONTACTS = @"invite_friends_in_contacts";

// Notifications

static NSString * const kUserStateUpdated = @"userStateUpdated";

// XMPP

static NSString * const kXMPPmyJID = @"kXMPPmyJID";
static NSString * const kXMPPmyPassword = @"kXMPPmyPassword";
static NSString * const kXMPPStreamDidAuthenticate = @"xmppStreamDidAuthenticate";

// Facebook

static NSString *const FBSessionStateChangedNotification = @"com.mumblerchat:FBSessionStateChangedNotification";

// Tutorial

static NSString *const kContactsTutorialDone = @"ContactsTutorialDone";
static NSString *const kSearchTutorialDone = @"SearchTutorialDone";

#endif
