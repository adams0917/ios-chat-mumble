//
//  ChatComposerViewController.m
//  MumblerChat
//
//  Created by Ransika De Silva on 9/9/14.
//
//

#import "ChatComposerViewController.h"
#import "ChatMessageDao.h"
#import "ASAppDelegate.h"


#import <CoreLocation/CoreLocation.h>
#import "ASAppDelegate.h"
#import "ASSliderView.h"

#import "MyChatTableViewCell.h"

#import "ChatThread.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FaceBoard.h"
#import "ChatThreadDao.h"
#import "UserDao.h"
#import "ChatMessage.h"
#import "SVProgressHUD.h"
#import "AFHTTPRequestOperationManager.h"
#import "Constants.h"
#import "NSData+Base64.h"
#import "ChatUtil.h"
#import "FriendsViewController.h"

#import "User.h"


#define CAMERA_TRANSFORM_X 2.0
#define CAMERA_TRANSFORM_Y 2.0

@interface ChatComposerViewController ()
{
    float floor;
    NSString *chatThreadId;
    NSString *meEjabberdId;
    NSString *friendEjabberdId;
    UIButton *butonBackCam;
    UIButton *buttonSwitchCam;
    UILabel*labelCount;
    UIImageView *editmodeView;
    UIButton *editModeCloseButton;
    UIButton *uploadImageButton;
    MPMoviePlayerController *moviePlayer;
    MPMoviePlayerViewController *playerController;
    UIView *moviewHolderView;
    
    ASAppDelegate *appDelegate;
    UIImagePickerController *imagePicker;
    UIButton *buttonCapture;
    UIButton *buttonFlashCam;
    
    AVCaptureDevice *device ;
    AVCaptureDeviceInput *flashInput;
    AVCaptureVideoDataOutput *output;
    ChatMessage *composedChatWithoutFriend;
    NSString *composedMsg;
    ChatMessageDao *chatMessageDao;
    UserDao *userDao;
    
    
    NSString *dateFormat;
    NSString *timeFormat;
    NSMutableDictionary *profileImagesDictionary;
    NSMutableDictionary *chatImagesDictionary;
    NSMutableDictionary *chatVideoThumbnailsDictionary;
    User *meUser;
    NSString *timeGivenToRespond;
    MyChatTableViewCell *globalCell;
    // Boolean to figure out new record got inserted
    BOOL insertedNewRecordFromFriend;
    NSInteger remainingSecondsTrack;
    // Boolean to figure out whether we need to handle the timer
    BOOL shouldHandleTimer;
    BOOL shouldRemoveFetchDelegate;
    BOOL isTimeOver;
    
    
    
}

@end

@implementation ChatComposerViewController
@synthesize chatComposerTableView;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize chatTextField;
@synthesize chatThread;
@synthesize mumblerFriend;
@synthesize actionType;
@synthesize chatHeaderLabel;
@synthesize sliderView;

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

////////below 3 buttons

- (IBAction) didTapOnViedioButton:(id)sender
{
    NSLog(@"didTapOnViedioButton----");
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = @[(NSString *) kUTTypeMovie];
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;
    [imagePicker setVideoMaximumDuration:10];
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (IBAction) didTapOnImageButton:(id)sender
{
    NSLog(@"didTapOnImageButton----");
    
    [self showCameraMode:NO];
}

- (IBAction) didTapOnRandomQuestionButton:(id)sender
{
    NSLog(@"didTapOnRandomQuestionButton----");
}


-(IBAction) cameraDismiss:(id)sender
{
    
    NSLog(@"cameraDismiss---");
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction) capture:(id)sender
{
    NSLog(@"capture--------");
    
    NSLog(@"takepicture-----");
    [imagePicker takePicture];
    
    imagePicker.delegate=self;
}


-(IBAction) cameraSwitchMode:(id)sender
{
    NSLog(@"isFlipping,Capturing");
    
    [UIView transitionWithView:imagePicker.view
                      duration:1.0
                       options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        if ([UIImagePickerController isCameraDeviceAvailable:imagePicker.cameraDevice]) {
                            if (imagePicker.cameraCaptureMode == UIImagePickerControllerCameraCaptureModePhoto) {
                                if (imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
                                    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                                } else if (imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
                                    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                                }
                            } else if(imagePicker.cameraCaptureMode == UIImagePickerControllerCameraCaptureModeVideo) {
                                if (imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
                                    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                                } else if ( imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
                                    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                                }
                                
                            }
                            
                            imagePicker.delegate = self;
                        }
                    }
                    completion:nil];
}

-(IBAction) cameraFlash:(id)sender
{
    
    NSLog(@"cameraFlash------");
    
    [self toggleTorch];
}

- (void) toggleTorch
{
    //flash on off
    
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (device.hasTorch && device.hasFlash){
        
        
        NSLog(@"It's currently off.. turning on now.");
        if (device.torchMode == AVCaptureTorchModeOff) {
            [buttonFlashCam setBackgroundImage:[UIImage imageNamed:@"flash_on_2"] forState:UIControlStateNormal];
            flashInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            output = [AVCaptureVideoDataOutput new];
            [device lockForConfiguration:nil];
            device.torchMode = AVCaptureTorchModeOn;
            device.flashMode = AVCaptureFlashModeOn;
        } else {
            [buttonFlashCam setBackgroundImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
            [device lockForConfiguration:nil];
            device.torchMode = AVCaptureTorchModeOff;
            device.flashMode = AVCaptureFlashModeOff;
        }
        
        [device unlockForConfiguration];
    }
}

-(UIImage*) unrotateImage:(UIImage*)image
{
    NSLog(@"unrotateImage");
    CGSize size = image.size;
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width ,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


-(void) imagePickerController:(UIImagePickerController *) picker didFinishPickingMediaWithInfo:(NSDictionary *) info
{
    
    NSLog(@"didFinishPickingMediaWithInfo info == %@",info);
    
    if([[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.image"]){
        
        NSLog(@"UIImagePickerControllerMediaType image --- ");
        
        UIImage * originalImage;
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];//image lies inside ths dictionary
        
        UIImage * imageToSave=[self unrotateImage:originalImage];
        NSData *imageData =UIImageJPEGRepresentation(imageToSave, 90);
        NSString *imagebase64String = [imageData base64EncodedString];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [SVProgressHUD showInView:self.view status:@"Uploading image"];
        [self uploadImageFile:imageData:imagebase64String];
        
    }
    //viedio
    else if ([[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.movie"]){
        NSLog(@"UIImagePickerControllerMediaType Video --- ");
        
        
        //////////////
        
        
        NSLog(@"UIImagePickerControllerMediaType Video --- ");
        NSString *mediaUrl=[info objectForKey:@"UIImagePickerControllerMediaURL"];
        
        NSLog(@"moviePath %@",mediaUrl);
        [SVProgressHUD showInView:self.view status:@"Uploading video"];
        
        NSData *videoData = [NSData dataWithContentsOfURL:[info objectForKey:@"UIImagePickerControllerMediaURL"]];
        NSString *videoBase64String=[videoData base64EncodedString];
        
        [self uploadVideoFile :videoData:videoBase64String];
        
        
        
        //////////////
        
        
        
        /* NSString *mediaUrl=[info objectForKey:@"UIImagePickerControllerMediaURL"];
         
         NSLog(@"moviePath %@",mediaUrl);
         [SVProgressHUD showInView:self.view status:@"Uploading video"];
         
         
         
         
         UIImage * originalImage;
         originalImage = (UIImage *) [info objectForKey:
         UIImagePickerControllerMediaURL];//image lies inside ths dictionary
         
         
         
         
         
         UIImage * imageToSave=[self unrotateImage:originalImage];
         NSData *videoData =UIImageJPEGRepresentation(imageToSave, 90);
         NSString *videoBase64String = [videoData base64EncodedString];
         
         
         NSLog(@"moviePath videoBase64String %@",videoBase64String);
         
         [self uploadVideoFile :videoData:videoBase64String];*/
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    
}

-(void)uploadImageFile :(NSData *)imageToUpload :(NSString *) base64ImageString{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url=[NSString stringWithFormat:@"%@%@",BASE_URL,@"mumblerUser/uploadImageToSend.htm"];
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:imageToUpload name:@"image" fileName:@"files.jpeg" mimeType:@"image/jpeg"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"Response: %@", responseObject);
        NSString *status=[responseObject valueForKey:@"status"];
        if([status isEqualToString:@"success"]){
            
            NSDictionary *data=[responseObject objectForKey:@"data"];
            NSString *imageUrl=[data valueForKey:@"image_url"];
            NSLog(@"image url=== %@",imageUrl);
            
            [self sendFile : base64ImageString:imageUrl:@"image"];
            
        }
        else{
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        NSError *error1 = nil;
        [[self fetchedResultsController] performFetch:&error1];
        [chatComposerTableView reloadData];
        
        
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", nil) message:[error localizedDescription] delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
        
        [alert show];
        
    }];
    
}



-(void)uploadVideoFile : (NSData *)videoToUpload :(NSString *)videoBase64String{
    
    NSLog(@"uploadVideoFile");
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url=[NSString stringWithFormat:@"%@%@",BASE_URL,@"mumblerUser/uploadVideoToSend.htm"];
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:videoToUpload name:@"video" fileName:@"video" mimeType:@"video/mp4"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Response in video upload %@", responseObject);
        NSString *status=[responseObject valueForKey:@"status"];
        if([status isEqualToString:@"success"]){
            NSDictionary *data=[responseObject objectForKey:@"data"];
            NSString *videoUrlFromServer=[data valueForKey:@"videoName"];
            NSLog(@"video url=== %@",videoUrlFromServer);
            
            // get the thumbnail from movie
            UIImage * capturedPhoto = [self thumbnailFromVideoAtURL:[NSURL fileURLWithPath:videoBase64String]];
            
            // [self sendFile :videoBase64String:videoUrlFromServer:@"video"];
            [self sendFile :nil:videoUrlFromServer:@"video"];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil) message:[error localizedDescription] delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];
        
        [alert show];
    }];
    
    
}




-(UIImage *)thumbnailFromVideoAtURL:(NSURL *)contentURL {
    NSLog(@"Starting Thumbnail From Video file");
    UIImage *theImage = nil;
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:contentURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
    theImage = [[UIImage alloc] initWithCGImage:imgRef];
    CGImageRelease(imgRef);
    NSLog(@"End thumbnail from video file");
    return theImage;
}





-(void)sendFile :(NSString *) imageString : (NSString *) imageUrl :(NSString *) fileType{
    
    NSLog(@"sendFile");
    // NSLog(@"sendFile imageString %@=",imageString);
    NSLog(@"sendFile imageUrl %@=",imageUrl);
    NSLog(@"sendFile fileType %@=",fileType);
    
    timeGivenToRespond = [NSString stringWithFormat:@"%i", self.sliderView.currentValue];
    int timeToRespond = [timeGivenToRespond intValue];
    
    //Used to without friend
    composedMsg =imageUrl;
    
    
    if([fileType isEqualToString:MESSAGE_MEDIUM_IMAGE]){
        fileType=MESSAGE_MEDIUM_IMAGE;
    }else if([fileType isEqualToString:MESSAGE_MEDIUM_VIDEO]){
        fileType=MESSAGE_MEDIUM_VIDEO;
    }
    
    if([actionType isEqualToString:ACTION_TYPE_WITHOUT_FRIEND]){
        
        NSString *timeInMiliseconds = [ChatUtil getTimeInMiliSeconds:[NSDate date]];
        
        NSString *messageId=[NSString stringWithFormat:@"%@%@%@",@"ios_",timeInMiliseconds,meEjabberdId];
        
        NSString *messageDate= [ChatUtil getDate:timeInMiliseconds inFormat:dateFormat];
        
        //update the UI
        
        composedChatWithoutFriend = [chatMessageDao saveChatMessageWithOutFriend:chatThreadId messageId:messageId senderEjabberdId:meEjabberdId messageMedium:MESSAGE_MEDIUM_TEXT messageContent:imageUrl messageDateTime:timeInMiliseconds deliveredDateTime:messageDate messageDelivered:[NSNumber numberWithInt:1] imageEncodedString:nil receiveType:RECEIVE_TYPE_OUTGOING timeGivenToRespond:[NSNumber numberWithInt:timeToRespond] chatTextType:nil];
        
        if(composedChatWithoutFriend){
            
            NSError *error = nil;
            [[self fetchedResultsController] performFetch:&error];
            
            [chatComposerTableView reloadData];
            
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // code to be executed on the main queue after delay
                [self performSegueWithIdentifier:@"chatComposer_Friends" sender:self];
            });
            
            
        }else{
            DDLogVerbose(@"%@: %@: chatThreadId chatmessage  not returned ACTION_TYPE_WITHOUT_FRIEND", THIS_FILE, THIS_METHOD);
            
            
        }
        
        
        
    }
    //From chat thread
    else if([actionType isEqualToString:ACTION_TYPE_THREAD] || [actionType isEqualToString:ACTION_TYPE_WITH_FRIEND]){
        
        
        NSString *timeInMiliseconds = [ChatUtil getTimeInMiliSeconds:[NSDate date]];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        NSXMLElement *received = [NSXMLElement elementWithName:@"request" URI:@"urn:xmpp:receipts"];
        
        NSXMLElement *extras=[NSXMLElement elementWithName:@"extras" URI:@"urn:xmpp:extras"];
        
        NSString *messageId=[NSString stringWithFormat:@"%@%@%@",@"ios_",timeInMiliseconds,meEjabberdId];
        
        
        [body setStringValue:imageUrl];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"id" stringValue:messageId];
        [message addAttributeWithName:@"to" stringValue:friendEjabberdId];
        
        [extras addAttributeWithName:MESSAGE_MEDIUM stringValue:fileType];
        [extras addAttributeWithName:THREAD_ID stringValue:chatThreadId];
        [extras addAttributeWithName:SENDER_USERNAME stringValue:meUser.name];
        [extras addAttributeWithName:TIME_GIVEN_TO_RESPOND stringValue:timeGivenToRespond];
        
        
        [message addChild:extras ];
        [message addChild:body];
        [message addChild:received];
        DDLogVerbose(@"%@: %@: messaged Typed =%@ ", THIS_FILE, THIS_METHOD,message);
        
        [appDelegate.xmppStream sendElement:message];
        
        DDLogVerbose(@"%@: %@: chatThreadId =%@ ", THIS_FILE, THIS_METHOD,chatThreadId);
        
        NSString *messageDate= [ChatUtil getDate:timeInMiliseconds inFormat:dateFormat];
        
        
        /* ChatMessage *chatMessage = [chatMessageDao saveChatMessageWithThreadId:chatThreadId messageId:messageId senderEjabberdId:meEjabberdId recipientEjabberdId:friendEjabberdId messageMedium:fileType messageContent:imageUrl messageDateTime:timeInMiliseconds deliveredDateTime:messageDate messageDelivered:[NSNumber numberWithInt:1] imageEncodedString:imageString sentSeen:[NSNumber numberWithInt:2]threadLastMessage:imageUrl receiveType:RECEIVE_TYPE_OUTGOING timeGivenToRespond:[NSNumber numberWithInt:21] chatTextType:nil];*/
        
        
        ChatMessage *chatMessage;
        
        if([actionType isEqualToString:ACTION_TYPE_THREAD]){
            
            chatMessage = [chatMessageDao saveChatMessageWithThreadId:chatThreadId messageId:messageId senderUser:chatThread.threadOwner recipient:chatThread.recipient messageMedium:fileType messageContent:imageUrl messageDateTime:timeInMiliseconds deliveredDateTime:messageDate messageDelivered:[NSNumber numberWithInt:1]  imageEncodedString:imageString sentSeen:[NSNumber numberWithInt:2] threadLastMessage:meEjabberdId receiveType:RECEIVE_TYPE_OUTGOING timeGivenToRespond:[NSNumber numberWithInt:timeToRespond] chatTextType:nil];
            
        }else{
            
            chatMessage = [chatMessageDao saveChatMessageWithThreadId:chatThreadId messageId:messageId senderUser:meUser recipient:mumblerFriend messageMedium:fileType messageContent:imageUrl messageDateTime:timeInMiliseconds deliveredDateTime:messageDate messageDelivered:[NSNumber numberWithInt:1]  imageEncodedString:imageString sentSeen:[NSNumber numberWithInt:2] threadLastMessage:meEjabberdId receiveType:RECEIVE_TYPE_OUTGOING timeGivenToRespond:[NSNumber numberWithInt:timeToRespond] chatTextType:nil];
            
        }
        
        
        if(chatMessage) {
            DDLogVerbose(@"%@: %@: chatThreadId chatImage textMessage returned=%@ ", THIS_FILE, THIS_METHOD,chatMessage.textMessage);
            
            DDLogVerbose(@"%@: %@: chatThreadId chatImage threadId returned=%@ ", THIS_FILE, THIS_METHOD,chatMessage.threadId);
            
            NSError *error = nil;
            [self.fetchedResultsController performFetch:&error];
            
            [chatComposerTableView reloadData];
            
            if([actionType isEqualToString:ACTION_TYPE_WITH_FRIEND]) {
                double delayInSeconds = 2.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    // code to be executed on the main queue after delay
                    [self performSegueWithIdentifier:@"composedMsg_ChatThread" sender:self];
                });
            }
        } else {
            DDLogVerbose(@"%@: %@: chatThreadId chatImage  not returned=%@ ", THIS_FILE, THIS_METHOD,chatMessage.textMessage);
        }
    }
}



-(IBAction)editModeViewSetHidden:(id)sender{
    
    NSLog(@"editModeViewSetHidden");
    
    if ([(UIButton*)sender tag]==1) {
        NSLog(@"editModeViewSetHidden tag1");
        [editmodeView setHidden:YES];
        [editModeCloseButton setEnabled:NO];
        [editModeCloseButton setHidden:YES];
        [uploadImageButton setEnabled:NO];
        [uploadImageButton setHidden:YES];
        
        
    }else{
        
        NSLog(@"editModeViewSetHidden tag2");
        [uploadImageButton setEnabled:NO];
        [uploadImageButton setHidden:YES];
        
    }
    
    
}

-(void)showCameraMode:(BOOL)video{
    
    // shouldRemoveFetchDelegate = NO;
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    imagePicker=[[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [imagePicker setShowsCameraControls:NO];
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    
    if(video){
        
        //isClicked=NO;
        //isRecordingOn=YES;
        imagePicker.mediaTypes =
        [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;
        [imagePicker setVideoMaximumDuration:10];
        
    }
    
    
    if (IS_IPAD) {
        
        butonBackCam=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [butonBackCam setFrame:CGRectMake(10, 14, 33, 33)];
        [butonBackCam addTarget:self action:@selector(cameraDismiss:) forControlEvents:UIControlEventTouchUpInside];
        [butonBackCam setBackgroundImage:[UIImage imageNamed:@"camera_back_button.png"] forState:UIControlStateNormal];
        [butonBackCam setTintColor:[UIColor clearColor]];
        [imagePicker.view addSubview:butonBackCam];
        
        buttonCapture = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buttonCapture setFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width/2 - 40), [[UIScreen mainScreen] bounds].size.height-100, 80, 80)];
        [buttonCapture addTarget:self action:@selector(capture:) forControlEvents:UIControlEventTouchUpInside];
        [buttonCapture setBackgroundImage:[UIImage imageNamed:@"capture_button.png"] forState:UIControlStateNormal];
        [buttonCapture setTintColor:[UIColor clearColor]];
        [imagePicker.view addSubview:buttonCapture];
        
        buttonSwitchCam=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buttonSwitchCam setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-75, 14, 60, 40)];
        [buttonSwitchCam addTarget:self action:@selector(cameraSwitchMode:) forControlEvents:UIControlEventTouchUpInside];
        [buttonSwitchCam setBackgroundImage:[UIImage imageNamed:@"camera_switch_mode.png"] forState:UIControlStateNormal];
        [imagePicker.view addSubview:buttonSwitchCam];
        
        buttonFlashCam=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buttonFlashCam setFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height-70, 33, 33)];
        [buttonFlashCam addTarget:self action:@selector(cameraFlash:) forControlEvents:UIControlEventTouchUpInside];
        [buttonFlashCam setBackgroundImage:[UIImage imageNamed:@"auto_flash.png"] forState:UIControlStateNormal];
        [buttonFlashCam setTintColor:[UIColor clearColor]];
        [imagePicker.view addSubview:buttonFlashCam];
        imagePicker.cameraViewTransform=CGAffineTransformScale(imagePicker.cameraViewTransform, CAMERA_TRANSFORM_X, CAMERA_TRANSFORM_Y);
        
        labelCount=[[UILabel alloc] init];
        [labelCount setFrame:CGRectMake(screenWidth/2 -5 , 940, 50, 50)];
        labelCount.textColor=[UIColor whiteColor];
        labelCount.backgroundColor=[UIColor clearColor];
        [labelCount setFont:[UIFont boldSystemFontOfSize:20]];
        [imagePicker.view addSubview:labelCount];
        
        editmodeView=[[UIImageView alloc] initWithFrame:CGRectMake(0, -20, self.view.frame.size.width,self.view.frame.size.height+20)];
        [editmodeView setBackgroundColor:[UIColor clearColor]];
        [imagePicker.view addSubview:editmodeView];
        
        editModeCloseButton=[[UIButton alloc] initWithFrame:CGRectMake(10, 10, 33, 33)];
        [editModeCloseButton setBackgroundImage:[UIImage imageNamed:@"editclose_icon.png"] forState:UIControlStateNormal];
        [editModeCloseButton addTarget:self action:@selector(editModeViewSetHidden:) forControlEvents:UIControlEventTouchUpInside];
        editModeCloseButton.tag=1;
        
        if(!video){
            uploadImageButton =[[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 500, 40, 40)];
            [uploadImageButton setBackgroundImage:[UIImage imageNamed:@"EditModesend_icon.png"] forState:UIControlStateNormal];
            [uploadImageButton addTarget:self action:@selector(editModeViewSetHidden:) forControlEvents:UIControlEventTouchUpInside];
            uploadImageButton.tag=2;
        }
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
        
        
    } else{
        
        butonBackCam=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [butonBackCam setFrame:CGRectMake(10, 14, 33, 33)];
        [butonBackCam addTarget:self action:@selector(cameraDismiss:) forControlEvents:UIControlEventTouchUpInside];
        [butonBackCam setBackgroundImage:[UIImage imageNamed:@"camera_back_button.png"] forState:UIControlStateNormal];
        [butonBackCam setTintColor:[UIColor clearColor]];
        [imagePicker.view addSubview:butonBackCam];
        
        buttonCapture = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buttonCapture setFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width/2 - 40), 470, 80, 80)];
        [buttonCapture addTarget:self action:@selector(capture:) forControlEvents:UIControlEventTouchUpInside];
        [buttonCapture setBackgroundImage:[UIImage imageNamed:@"capture_button.png"] forState:UIControlStateNormal];
        [buttonCapture setTintColor:[UIColor clearColor]];
        [imagePicker.view addSubview:buttonCapture];
        
        buttonSwitchCam=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buttonSwitchCam setFrame:CGRectMake(250, 14, 60, 40)];
        [buttonSwitchCam addTarget:self action:@selector(cameraSwitchMode:) forControlEvents:UIControlEventTouchUpInside];
        [buttonSwitchCam setBackgroundImage:[UIImage imageNamed:@"camera_switch_mode.png"] forState:UIControlStateNormal];
        [imagePicker.view addSubview:buttonSwitchCam];
        
        buttonFlashCam=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buttonFlashCam setFrame:CGRectMake(10, 480, 33, 33)];
        [buttonFlashCam addTarget:self action:@selector(cameraFlash:) forControlEvents:UIControlEventTouchUpInside];
        [buttonFlashCam setBackgroundImage:[UIImage imageNamed:@"auto_flash.png"] forState:UIControlStateNormal];
        [buttonFlashCam setTintColor:[UIColor clearColor]];
        [imagePicker.view addSubview:buttonFlashCam];
        
        if([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            
            imagePicker.cameraViewTransform = CGAffineTransformMakeScale(1.0, 1.670);
        } else {
            if ([[UIScreen mainScreen] bounds].size.height == 568) {
                imagePicker.cameraViewTransform = CGAffineTransformMakeScale(1.0, 1.930);
            } else {
                imagePicker.cameraViewTransform = CGAffineTransformMakeScale(1.0, 1.260);
            }
            //            imagePicker.cameraViewTransform=CGAffineTransformScale(imagePicker.cameraViewTransform, CAMERA_TRANSFORM_X, CAMERA_TRANSFORM_Y);
        }
        
        
        labelCount=[[UILabel alloc] init];
        [labelCount setFrame:CGRectMake(screenWidth/2 -5 , 484, 50, 50)];
        labelCount.textColor=[UIColor whiteColor];
        labelCount.backgroundColor=[UIColor clearColor];
        [labelCount setFont:[UIFont boldSystemFontOfSize:20]];
        [imagePicker.view addSubview:labelCount];
        
        editmodeView=[[UIImageView alloc] initWithFrame:CGRectMake(0, -20, self.view.frame.size.width,self.view.frame.size.height+20)];
        [editmodeView setBackgroundColor:[UIColor clearColor]];
        [imagePicker.view addSubview:editmodeView];
        
        editModeCloseButton=[[UIButton alloc] initWithFrame:CGRectMake(10, 10, 33, 33)];
        [editModeCloseButton setBackgroundImage:[UIImage imageNamed:@"editclose_icon.png"] forState:UIControlStateNormal];
        [editModeCloseButton addTarget:self action:@selector(editModeViewSetHidden:) forControlEvents:UIControlEventTouchUpInside];
        editModeCloseButton.tag=1;
        
        if(!video){
            uploadImageButton =[[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 500, 40, 40)];
            [uploadImageButton setBackgroundImage:[UIImage imageNamed:@"EditModesend_icon.png"] forState:UIControlStateNormal];
            [uploadImageButton addTarget:self action:@selector(editModeViewSetHidden:) forControlEvents:UIControlEventTouchUpInside];
            uploadImageButton.tag=2;
        }
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    
}







-(IBAction)swipeLeft:(id)sender{
    NSLog(@"swipeLeft----");
    
    
}
-(IBAction)swipeRight:(id)sender{
    NSLog(@"swipeRight----");
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

- (ASAppDelegate *)appDelegate
{
    return (ASAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboardWillShow");
    
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.size.height;
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    NSUInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    [UIView animateWithDuration:animationDuration delay:0.0
                        options:animationCurve
                     animations:^ {
                         self.bottomConstraint.constant = keyboardTop;
                         [self.view layoutIfNeeded];
                         [self.sliderView layoutSubviews];
                         
                     } completion:nil];
    
    
    CGPoint offset = CGPointMake(0, (floor));
    [self.chatComposerTableView setContentOffset:offset animated:NO];
    
    
}

- (void)keyboardWillHide:(NSNotification *)notification{
    NSLog(@"keyboardWillHide");
    
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    NSUInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    [UIView animateWithDuration:animationDuration delay:0.0
                        options:animationCurve
                     animations:^ {
                         self.bottomConstraint.constant = 0.0;
                         [self.view layoutIfNeeded];
                         [self.sliderView layoutSubviews];
                         
                     } completion:nil];
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.controlView.hidden = YES;
    _countDownView.hidden = YES;
    
    self.mainOptionView.bottomConstraint = _bottomConstraint;
    
    
    
    
    // DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    NSLog(@"viewDidLoad chat composer");
    
    // DDLogVerbose(@"%@: %@: START viewWillAppear", THIS_FILE, THIS_METHOD);
    
    appDelegate = (ASAppDelegate *)[UIApplication sharedApplication].delegate;
    chatMessageDao = [[ChatMessageDao alloc] init];
    userDao = [[UserDao alloc] init];
    
    profileImagesDictionary =[[NSMutableDictionary alloc]init];
    chatImagesDictionary =[[NSMutableDictionary alloc]init];
    chatVideoThumbnailsDictionary=[[NSMutableDictionary alloc]init];
    
    NSString *meMumblerUserId = [NSUserDefaults.standardUserDefaults
                                 valueForKey:MUMBLER_USER_ID];
    self.sliderView.currentValue =21;
    
    
    
    meUser =  [userDao getUserForId:meMumblerUserId];
    
    meEjabberdId=[NSString stringWithFormat:@"%@%@",meMumblerUserId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
    
    dateFormat = @"EEEE, MMMM dd, yyyy";
    timeFormat =@"hh:mm a";
    
    
    DDLogVerbose(@"%@: %@: meEjabberdId=%@ ", THIS_FILE, THIS_METHOD,meEjabberdId);
    
    
    
    //From selected friend
    if([actionType isEqualToString:ACTION_TYPE_WITH_FRIEND]){
        DDLogVerbose(@"%@: %@: ACTION_TYPE_WITH_FRIEND ", THIS_FILE, THIS_METHOD);
        
        chatHeaderLabel.text = mumblerFriend.name;
        
        NSString *friendUserId= mumblerFriend.userId;
        friendEjabberdId=[NSString stringWithFormat:@"%@%@",friendUserId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
        
        
        DDLogVerbose(@"%@: %@: friendEjabbereId=%@ ", THIS_FILE, THIS_METHOD,friendEjabberdId);
        
        //get current time, thread id should be unique
        NSTimeInterval  timeInMillis = [[NSDate date] timeIntervalSince1970] * 1000;
        long long integerMilliSeconds = timeInMillis;
        NSString *timeInMillisStr = [NSString stringWithFormat:@"%lld", integerMilliSeconds];
        
        chatThreadId=[NSString stringWithFormat:@"%@_%@_%@",meEjabberdId, friendEjabberdId,timeInMillisStr];
        
        DDLogVerbose(@"%@: %@: chatThreadId =%@ ", THIS_FILE, THIS_METHOD,chatThreadId);
        
        
        
    }
    
    //From chat composer icon
    else if([actionType isEqualToString:ACTION_TYPE_WITHOUT_FRIEND]){
        DDLogVerbose(@"%@: %@: ACTION_TYPE_WITHOUT_FRIEND ", THIS_FILE, THIS_METHOD);
        
        //get current time, thread id should be unique
        NSTimeInterval  timeInMillis = [[NSDate date] timeIntervalSince1970] * 1000;
        long long integerMilliSeconds = timeInMillis;
        NSString *timeInMillisStr = [NSString stringWithFormat:@"%lld", integerMilliSeconds];
        
        chatThreadId=[NSString stringWithFormat:@"%@_%@",meEjabberdId, timeInMillisStr];
        
        
    }
    //From chat thread
    else if([actionType isEqualToString:ACTION_TYPE_THREAD]){
        
        _countDownView.hidden = NO;
        
        self.cdp.chatViewController = self;
        
        // Execute the nsfetch request
        NSLog(@"countDownProgress");
        
        if (self.cdp == nil) {
            NSLog(@"self.countDownProgress == nil");
        }
        
        long long remainingSeconds = 0;
        
        NSString *millisecondsStr = chatThread.lastReceivedMessageOpenedTime;
        
        NSLog(@"milliSecondsStr %@", millisecondsStr);
        
        
        long long chatOpenedTimeInSeconds = millisecondsStr.longLongValue / 1000;
        
        NSLog(@"chatOpenedTimeInSeconds %lld",chatOpenedTimeInSeconds);
        
        
        long long currentTimeInSecondsAsInt = NSDate.date.timeIntervalSince1970;
        
        NSLog(@"currentTimeInSecondsAsInt %lld", currentTimeInSecondsAsInt);
        
        long long countDifference = currentTimeInSecondsAsInt - chatOpenedTimeInSeconds;
        remainingSeconds = (chatThread.timeGivenToRespond.integerValue * 1000 - countDifference) ;
        int secondsRemaining = (int) remainingSeconds;
        int timeGivenToRespondLastMsg = (int) chatThread.timeGivenToRespond.integerValue;

        NSLog(@"secondsRemaining %d",secondsRemaining/1000);
        NSLog(@"timeGivenToRespondLastMsg %d",timeGivenToRespondLastMsg);
        
        [self.cdp startCountDownFromSeconds:timeGivenToRespondLastMsg:30];//secondsRemaining / 1000];
        
        NSLog(@"countDownProgress 1");
        
        chatHeaderLabel.text = chatThread.recipient.name;
        
        DDLogVerbose(@"%@: %@: ACTION_TYPE_THREAD ", THIS_FILE, THIS_METHOD);
        
        chatThreadId=chatThread.threadId;
        DDLogVerbose(@"%@: %@: chatThreadId =%@", THIS_FILE, THIS_METHOD,chatThreadId);
        
        meEjabberdId=[NSString stringWithFormat:@"%@%@",chatThread.threadOwner.userId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
        
        
        // meEjabberdId=chatThread.threadOwner;
        
        DDLogVerbose(@"%@: %@: chatThread meEjabberdId=%@", THIS_FILE, THIS_METHOD,meEjabberdId);
        
        friendEjabberdId=[NSString stringWithFormat:@"%@%@",chatThread.recipient.userId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
        
        //  friendEjabberdId = chatThread.threadRecipient;
        
        DDLogVerbose(@"%@: %@: friendEjabberdId =%@ ", THIS_FILE, THIS_METHOD,friendEjabberdId);
        
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
    }
    
    floor = 1000000.0;
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipe.direction = (UISwipeGestureRecognizerDirectionLeft);
    [self.view addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipe.direction = (UISwipeGestureRecognizerDirectionRight);
    [self.view addGestureRecognizer:rightSwipe];
    
    imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    NSLog(@"viewWillAppear chat composer end");
}


-(void) tick :(NSString *) remainingSeconds {
    
    remainingSecondsTrack=[remainingSeconds intValue];
    
    if (!shouldHandleTimer) {
        
        labelCount.text = remainingSeconds;
    }
    
}


-(void) notifyCountDownTimerComplete {
    NSLog(@"notifyCountDownTimerComplete");
    
    shouldRemoveFetchDelegate = YES;
    
    NSString *content = self.messageTextView.text;
    
    if (content != nil && content.length > 0) {
        isTimeOver = YES;
        [self sendTextMessage:nil];
        
    } else {
        
        // Check whether the user already sent a reply, current respondent id
        // The user has already replied
        if(![chatThread.threadLastMessageOwnerId isEqualToString:meEjabberdId]){
            // Go back to chat thread
            
            
            
        }else{
            [self killCurrentChatThread];
        }
    }
    
    [butonBackCam setHidden:YES];
    [buttonSwitchCam setHidden:YES];
    [labelCount setHidden:YES];
    [moviewHolderView setHidden:YES];
    [moviePlayer stop];
    labelCount=nil;
    butonBackCam=nil;
    buttonSwitchCam=nil;
    moviePlayer=nil;
    moviewHolderView=nil;
    NSArray *views=[[[UIApplication sharedApplication] keyWindow] subviews];
    
    for (id element in views) {
        
        NSLog(@"removing from superview");
        if ([element isKindOfClass:[UIButton class]]) {
            
            [element removeFromSuperview];
            
        }
        
        if ([element isKindOfClass:[UILabel class]]) {
            
            [element removeFromSuperview];
        }
        
        
    }
    
    
}


-(void) killCurrentChatThread {
    NSLog(@"killCurrentChatThread-------");
    
    [chatMessageDao updateThreadInActiveStatus:chatThread.threadId];
    
    //go back to the chat thread
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // code to be executed on the main queue after delay
        [self performSegueWithIdentifier:@"composedMsg_ChatThread" sender:self];
    });
    
    
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    
    NSLog(@"viewDidDisappear");
    if (shouldRemoveFetchDelegate) {
        _fetchedResultsController.delegate = nil;
        _fetchedResultsController = nil;
        [self.self.cdp stopCountDown];
    }
    
    
    //self.fetchedResultsController.delegate=nil;
    //self.fetchedResultsController=nil;
    //self.chatComposerTableView.dataSource=nil;
    //self.chatComposerTableView.delegate=nil;
    
}





/*-(void)sendSeenMessage:(NSString *) messageId :(NSString *)messageSender{
 
 NSLog(@"sendSeenMessage===messageId=== %@",messageId);
 NSLog(@"sendSeenMessage=== messageSender===%@",messageSender);
 NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
 
 [message addAttributeWithName:@"to" stringValue:messageSender];
 
 NSXMLElement *received = [NSXMLElement elementWithName:@"seen_received" URI:@"urn:xmpp:receipts"];
 [message addAttributeWithName:@"id" stringValue:messageId];
 [received addAttributeWithName:@"seen" stringValue:messageId];
 
 [message addChild:received];
 NSLog(@"test_____seen________message%@",message);
 
 [appDelegate.xmppStream sendElement:message];
 ChatMessageDao *chatMsgDao=[[ChatMessageDao alloc]init];
 [chatMsgDao updateMessageSeenState:messageId];
 
 }*/


/////sections/////

//Ransika
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return [_fetchedResultsController sectionIndexTitles];
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//    return [_fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id  sectionInfo =
    [[[self fetchedResultsController] sections] objectAtIndex: section];
    NSLog(@"numberOfRowsInSection sectionInfo === %@",[sectionInfo objects]);
    return [sectionInfo numberOfObjects] ;
    
    
}
- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    NSArray *sections = [[self fetchedResultsController] sections];
    
    if (sectionIndex < [sections count])
    {
        NSLog(@"titleForHeaderInSection sectionIndex=== %ld",(long)sectionIndex);
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        NSString *header=@"";
        for(ChatMessage *chat in [sectionInfo objects]){
            header=chat.messageDeliveredDateTime;
        }
        return header;
        
    }
    
    return @"";
}


-(IBAction)sendTextMessage:(id)sender {
    
    DDLogVerbose(@"%@: %@: sendTextMessage ", THIS_FILE, THIS_METHOD);
    
    [self.messageTextView endEditing:YES];
    
    NSString *messageText = self.messageTextView.text;
    
    messageText = [messageText stringByTrimmingCharactersInSet:
                   [NSCharacterSet whitespaceCharacterSet]];
    
    if(messageText.length >0){
        
        timeGivenToRespond = [NSString stringWithFormat:@"%i", self.sliderView.currentValue];
        int timeToRespond = [timeGivenToRespond intValue];
        
        //With Friend
        if([actionType isEqualToString:ACTION_TYPE_WITH_FRIEND]){
            
            NSString *textType = [ChatUtil getTextType:messageText];
            
            NSString *timeInMiliseconds = [ChatUtil getTimeInMiliSeconds:[NSDate date]];
            
            NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
            NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
            NSXMLElement *received = [NSXMLElement elementWithName:@"request" URI:@"urn:xmpp:receipts"];
            
            NSXMLElement *extras=[NSXMLElement elementWithName:@"extras" URI:@"urn:xmpp:extras"];
            
            NSString *messageId=[NSString stringWithFormat:@"%@%@%@",@"ios_",timeInMiliseconds,meEjabberdId];
            
            self.messageTextView.text = @"";
            
            
            [body setStringValue:messageText];
            [message addAttributeWithName:@"type" stringValue:@"chat"];
            [message addAttributeWithName:@"id" stringValue:messageId];
            [message addAttributeWithName:@"to" stringValue:friendEjabberdId];
            
            [extras addAttributeWithName:MESSAGE_MEDIUM stringValue:MESSAGE_MEDIUM_TEXT];
            [extras addAttributeWithName:TEXT_TYPE stringValue:textType];
            [extras addAttributeWithName:THREAD_ID stringValue:chatThreadId];
            [extras addAttributeWithName:SENDER_USERNAME stringValue:meUser.name];
            [extras addAttributeWithName:TIME_GIVEN_TO_RESPOND stringValue:timeGivenToRespond];
            
            [message addChild:extras ];
            [message addChild:body];
            [message addChild:received];
            DDLogVerbose(@"%@: %@: messaged Typed =%@ ", THIS_FILE, THIS_METHOD,message);
            
            [appDelegate.xmppStream sendElement:message];
            
            DDLogVerbose(@"%@: %@: chatThreadId =%@ ", THIS_FILE, THIS_METHOD,chatThreadId);
            DDLogVerbose(@"%@: %@: textType =%@ ", THIS_FILE, THIS_METHOD,textType);
            
            
            NSString *messageDate= [ChatUtil getDate:timeInMiliseconds inFormat:dateFormat];
            
            
            ChatMessage *chatMessage  = [chatMessageDao saveChatMessageWithThreadId:chatThreadId messageId:messageId senderUser:meUser recipient:mumblerFriend messageMedium:MESSAGE_MEDIUM_TEXT messageContent:messageText  messageDateTime:timeInMiliseconds deliveredDateTime:messageDate messageDelivered:[NSNumber numberWithInt:1]  imageEncodedString:nil sentSeen:[NSNumber numberWithInt:2] threadLastMessage:meEjabberdId receiveType:RECEIVE_TYPE_OUTGOING timeGivenToRespond:[NSNumber numberWithInt:timeToRespond] chatTextType:textType];
            
            
            
            
            
            if(chatMessage){
                
                
                DDLogVerbose(@"%@: %@: chatThreadId chatmessage textMessage returned=%@ ", THIS_FILE, THIS_METHOD,chatMessage.textMessage);
                
                DDLogVerbose(@"%@: %@: chatThreadId chatmessage threadId returned=%@ ", THIS_FILE, THIS_METHOD,chatMessage.threadId);
                
                NSError *error = nil;
                [[self fetchedResultsController] performFetch:&error];
                
                [chatComposerTableView reloadData];
                
                double delayInSeconds = 5.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    // code to be executed on the main queue after delay
                    [self performSegueWithIdentifier:@"composedMsg_ChatThread" sender:self];
                });
                
                
                
            }else{
                DDLogVerbose(@"%@: %@: chatThreadId chatmessage  not returned=%@ ", THIS_FILE, THIS_METHOD,chatMessage.textMessage);
                
                
            }
            
        }
        //From chat composer icon
        else if([actionType isEqualToString:ACTION_TYPE_WITHOUT_FRIEND]){
            
            DDLogVerbose(@"%@: %@: ACTION_TYPE_WITHOUT_FRIEND TYPED MSG %@=", THIS_FILE, THIS_METHOD,messageText);
            
            
            NSString *textType = [ChatUtil getTextType:messageText];
            
            NSString *timeInMiliseconds = [ChatUtil getTimeInMiliSeconds:[NSDate date]];
            
            NSString *messageId=[NSString stringWithFormat:@"%@%@%@",@"ios_",timeInMiliseconds,meEjabberdId];
            
            composedMsg=messageText;
            self.messageTextView.text = @"";
            
            NSString *messageDate= [ChatUtil getDate:timeInMiliseconds inFormat:dateFormat];
            
            composedChatWithoutFriend = [chatMessageDao saveChatMessageWithOutFriend:chatThreadId messageId:messageId senderEjabberdId:meEjabberdId messageMedium:MESSAGE_MEDIUM_TEXT messageContent:messageText messageDateTime:timeInMiliseconds deliveredDateTime:messageDate messageDelivered:[NSNumber numberWithInt:1] imageEncodedString:nil receiveType:RECEIVE_TYPE_OUTGOING timeGivenToRespond:[NSNumber numberWithInt:timeToRespond] chatTextType:textType];
            
            
            if(composedChatWithoutFriend){
                
                DDLogVerbose(@"%@: %@: chatThreadId composedChatWithoutFriend textMessage returned ACTION_TYPE_WITHOUT_FRIEND =%@ ", THIS_FILE, THIS_METHOD,composedChatWithoutFriend.textMessage);
                
                self.messageTextView.text = @"";
                
                NSError *error = nil;
                [[self fetchedResultsController] performFetch:&error];
                
                [chatComposerTableView reloadData];
                
                
                double delayInSeconds = 2.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    // code to be executed on the main queue after delay
                    [self performSegueWithIdentifier:@"chatComposer_Friends" sender:self];
                });
                
                
                
            }else{
                DDLogVerbose(@"%@: %@: chatThreadId chatmessage  not returned ACTION_TYPE_WITHOUT_FRIEND", THIS_FILE, THIS_METHOD);
                
                
            }
            
        }
        
        
        //From chat thread
        else if([actionType isEqualToString:ACTION_TYPE_THREAD]){
            
            DDLogVerbose(@"%@: %@: ACTION_TYPE_THREAD TYPED MSG %@=", THIS_FILE, THIS_METHOD,messageText);
            
            
            NSString *textType = [ChatUtil getTextType:messageText];
            
            NSString *timeInMiliseconds = [ChatUtil getTimeInMiliSeconds:[NSDate date]];
            
            NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
            NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
            NSXMLElement *received = [NSXMLElement elementWithName:@"request" URI:@"urn:xmpp:receipts"];
            
            NSXMLElement *extras=[NSXMLElement elementWithName:@"extras" URI:@"urn:xmpp:extras"];
            
            
            NSString *messageId=[NSString stringWithFormat:@"%@%@%@",@"ios_",timeInMiliseconds,meEjabberdId];
            
            self.messageTextView.text = @"";
            
            
            [body setStringValue:messageText];
            [message addAttributeWithName:@"type" stringValue:@"chat"];
            [message addAttributeWithName:@"id" stringValue:messageId];
            [message addAttributeWithName:@"to" stringValue:friendEjabberdId];
            
            [extras addAttributeWithName:MESSAGE_MEDIUM stringValue:MESSAGE_MEDIUM_TEXT];
            [extras addAttributeWithName:TEXT_TYPE stringValue:textType];
            [extras addAttributeWithName:THREAD_ID stringValue:chatThreadId];
            [extras addAttributeWithName:SENDER_USERNAME stringValue:meUser.name];
            [extras addAttributeWithName:TIME_GIVEN_TO_RESPOND stringValue:timeGivenToRespond];
            
            [message addChild:extras ];
            [message addChild:body];
            [message addChild:received];
            DDLogVerbose(@"%@: %@: messaged Typed =%@ ", THIS_FILE, THIS_METHOD,message);
            
            [appDelegate.xmppStream sendElement:message];
            
            DDLogVerbose(@"%@: %@: chatThreadId =%@ ", THIS_FILE, THIS_METHOD,chatThreadId);
            DDLogVerbose(@"%@: %@: textType =%@ ", THIS_FILE, THIS_METHOD,textType);
            
            
            NSString *messageDate= [ChatUtil getDate:timeInMiliseconds inFormat:dateFormat];
            
            ChatMessage *chatMessage  = [chatMessageDao saveChatMessageWithThreadId:chatThreadId messageId:messageId senderUser:chatThread.threadOwner recipient:chatThread.recipient messageMedium:MESSAGE_MEDIUM_TEXT messageContent:messageText  messageDateTime:timeInMiliseconds deliveredDateTime:messageDate messageDelivered:[NSNumber numberWithInt:1]  imageEncodedString:nil sentSeen:[NSNumber numberWithInt:2] threadLastMessage:meEjabberdId receiveType:RECEIVE_TYPE_OUTGOING timeGivenToRespond:[NSNumber numberWithInt:timeToRespond] chatTextType:textType];
            
            
            
            if(chatMessage){
                
                
                NSLog(@"ACTION_TYPE_THREAD chatThreadId chatmessage textMessage returned=%@",chatMessage.textMessage);
                if(shouldRemoveFetchDelegate){
                    //go back to the chat thread
                    double delayInSeconds = 2.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        // code to be executed on the main queue after delay
                        [self performSegueWithIdentifier:@"composedMsg_ChatThread" sender:self];
                    });
                    
                }
                
                
            }else{
                DDLogVerbose(@"%@: %@: chatThreadId chatmessage  not returned=%@ ", THIS_FILE, THIS_METHOD,chatMessage.textMessage);
                
                
            }
            
        }
        
    }else{
        DDLogVerbose(@"%@: %@: sendTextMessage messageText.length not >0", THIS_FILE, THIS_METHOD);
        
    }
    
}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"chatComposer_Friends"]) {
        
        composedMsg = [composedMsg stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceCharacterSet]];
        if(composedMsg.length >0){
            
            
            FriendsViewController *friendsViewController = (FriendsViewController *) [segue destinationViewController];
            friendsViewController.actionType = ACTION_TYPE_FRIEND_TO_BE_SELECTED;
            friendsViewController.messageNeedToBeSend=composedMsg;
            friendsViewController.composedChatMsg=composedChatWithoutFriend;
            
            
        }
    }
    
    
}




- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn==");
    [textField resignFirstResponder];
    // [self viewDidLayoutSubviews];
    // [self sendTextMessage:chatTextField.text];
    return NO;
}


-(void)sendSeenMessage:(NSString *) messageId :(NSString *)messageSender{
    
    NSLog(@"sendSeenMessage===messageId=== %@",messageId);
    NSLog(@"sendSeenMessage=== messageSender===%@",messageSender);
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    
    [message addAttributeWithName:@"to" stringValue:messageSender];
    
    
    NSXMLElement *received = [NSXMLElement elementWithName:@"seen_received" URI:@"urn:xmpp:receipts"];
    [message addAttributeWithName:@"id" stringValue:messageId];
    [received addAttributeWithName:@"seen" stringValue:messageId];
    
    [message addChild:received];
    NSLog(@"test_____seen________message%@",message);
    
    [appDelegate.xmppStream sendElement:message];
    ChatMessageDao *chatMsgDao=[[ChatMessageDao alloc]init];
    [chatMsgDao updateMessageSeenState:messageId];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSLog(@"heightForRowAtIndexPath");
    
    ChatMessage *chatMessage = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    
    
    if (chatMessage.messageMediumType  == MESSAGE_MEDIUM_IMAGE || chatMessage.messageMediumType == MESSAGE_MEDIUM_VIDEO) {
        
        return 130.0;
    } else {
        
        MyChatTableViewCell *cell = nil;
        
        cell = [self.chatComposerTableView dequeueReusableCellWithIdentifier:@"my_chat"];
        
        cell.messageLabel.text = chatMessage.textMessage;
        [cell layoutIfNeeded];
        
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        return size.height + 1;
        
        
        
        
    }
    
    
    
}


-(void)updateCountDownTimer:(NSString *)lastReceivedMessageOpenedTime {
    
    NSUInteger remainingSeconds = 0;
    
    long long chatOpenedTimeInSeconds = [lastReceivedMessageOpenedTime longLongValue]/1000;
    
    NSTimeInterval currentTimeInSeconds = [[NSDate date] timeIntervalSince1970];
    long long currentTimeInSecondsAsInt = currentTimeInSeconds;
    
    NSUInteger countDifference= currentTimeInSecondsAsInt -chatOpenedTimeInSeconds;
    
    
    remainingSeconds= ([chatThread.timeGivenToRespond integerValue]*1000 - countDifference) ;
    
    
    int secondsRemaining = (int)remainingSeconds;
    
    int timeGivenToRespondLastMsg = (int)[chatThread.timeGivenToRespond integerValue];
    
    [self.cdp stopCountDown];
    
    [self.cdp startCountDownFromSeconds:timeGivenToRespondLastMsg:secondsRemaining/1000];
    
    //[self.cdp resetCountDownTimer:[timeGivenToRespondLastMsg:secondsRemaining/1000];
    
    
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"cellForRowAtIndexPath==");
    
    MyChatTableViewCell *cell =nil;
    ChatMessage *chatMessage = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *myJID=[NSUserDefaults.standardUserDefaults objectForKey:@"kXMPPmyJID"];
    
    NSLog(@"myJID==%@",myJID);
    
    
    //update chat thread read status
    if([actionType isEqualToString:ACTION_TYPE_THREAD]){
        
        [chatMessageDao updateChatThreadReadStatus:chatThread.threadId threadStatus:[NSNumber numberWithInt:1]];
        
        
    }
    
    if(![chatThread.threadLastMessageOwnerId isEqualToString:meEjabberdId]){
        
        if(insertedNewRecordFromFriend){
            
            insertedNewRecordFromFriend=NO;
            
            NSString*lastOpenedTime =[ChatUtil getTimeInMiliSeconds:[NSDate date]];
            [chatMessageDao updateLastMessageOpenedTime:chatThread.threadId threadLastmessageOpenedTime:lastOpenedTime];
            
            NSUInteger remainingSeconds = 0;
            
            long long chatOpenedTimeInSeconds = [lastOpenedTime longLongValue]/1000;
            
            NSTimeInterval currentTimeInSeconds = [[NSDate date] timeIntervalSince1970];
            long long currentTimeInSecondsAsInt = currentTimeInSeconds;
            
            NSUInteger countDifference= currentTimeInSecondsAsInt -chatOpenedTimeInSeconds;
            
            
            remainingSeconds= ([chatMessage.timeGivenToRespond integerValue]*1000 - countDifference) ;
            
            int secondsRemaining = (int)remainingSeconds;
            
            int timeGivenToRespondLastMsg = (int)[chatMessage.timeGivenToRespond integerValue];
            
            [self.cdp stopCountDown];
            
            [self.cdp startCountDownFromSeconds:timeGivenToRespondLastMsg:secondsRemaining/1000];
            
            
            //[self updateCountDownTimer:chatMessage.timeGivenToRespond];
            
            
            
        }
        
    }else{
        if(insertedNewRecordFromFriend){
            insertedNewRecordFromFriend=NO;
        }
    }
    
    
    if([chatMessage.messageMediumType isEqualToString:MESSAGE_MEDIUM_TEXT]){
        
        //my chat
        if ([chatMessage.messageSender isEqual:myJID]) {
            
            static NSString *tableIdentifier = @"my_chat";
            
            cell = (MyChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
            
            globalCell = cell;
            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            
            NSString *messageDate= [ChatUtil getDate:chatMessage.messageDateTime  inFormat:timeFormat];
            
            cell.messageLabel.text= chatMessage.textMessage;
            cell.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.messageLabel.numberOfLines = 0;
            
            cell.dateTimeLabel.text= messageDate;
            //cell.profileImageView.image = [UIImage imageNamed:@"mumbler_profile_picture"];
            
            NSData *data = [NSData dataFromBase64String:chatThread.threadOwner.profileImageBytes];
            UIImage *image= [UIImage imageWithData:data];
            
            if(image){
                cell.profileImageView.image=image;
                
            }else{
                cell.profileImageView.image=[UIImage imageNamed:@"mumbler_profile_picture"];
                
            }
            cell.profileImageView.layer.cornerRadius = 20;
            cell.profileImageView.layer.masksToBounds = YES;
            
            
            
            
            if(chatMessage.seenByUser==[NSNumber numberWithInt:1]){
                NSLog(@"chat seen id  ------ %@",chatMessage.messageId);
                cell.chatSeenLabel.text = @"Seen";
            }else{
                NSLog(@"chat is not seen but sent ------ %@",chatMessage.messageId);
                cell.chatSeenLabel.text = @"Sent";
            }
            
            
            if ([chatMessage.messageDelivered isEqualToNumber:[NSNumber numberWithInt:2]]) {
                cell.deliveryStatusImageView.hidden = NO;
            } else {
                cell.deliveryStatusImageView.hidden = YES;
            }
            
            
            //Ash Balloon my statement
            if([chatMessage.textMessageType isEqualToString:TEXT_TYPE_STATEMENT]){
                
                cell.chatCellType=ChatCellTypeMyChat_Statement;
            }
            //Orange Balloon my question
            else{
                cell.chatCellType=ChatCellTypeMyChat_Question;
            }
            
            
            /*if([chatMessage.messageDelivered intValue] == 2){
             
             NSLog(@"CHAT DELIVERED");
             //cell.deliveryStatusImageView
             cell.deliveryStatusImageView.image = [UIImage imageNamed:@"mumbler_deleverd_img"];
             
             }*/
            
            
            return cell;
        }
        //friends Chat
        else{
            
            
            static NSString *tableIdentifier = @"friend_chat";
            cell = (MyChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
            
            
            globalCell = cell;
            
            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            
            
            NSString *messageDate= [ChatUtil getDate:chatMessage.messageDateTime  inFormat:timeFormat];
            cell.messageLabel.text= chatMessage.textMessage;
            
            cell.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.messageLabel.numberOfLines = 0;
            
            cell.dateTimeLabel.text= messageDate;
            //cell.profileImageView.image = [UIImage imageNamed:@"mumbler_profile_picture"];
            NSData *data = [NSData dataFromBase64String:chatThread.recipient.profileImageBytes];
            UIImage *image= [UIImage imageWithData:data];
            
            if(image){
                cell.profileImageView.image=image;
                
            }else{
                cell.profileImageView.image=[UIImage imageNamed:@"mumbler_profile_picture"];
                
            }
            
            cell.profileImageView.layer.cornerRadius = 20;
            cell.profileImageView.layer.masksToBounds = YES;
            
            
            
            
            if(chatMessage.seenByUser==[NSNumber numberWithInt:1]){
                NSLog(@"chat seen id  ------ %@",chatMessage.messageId);
                cell.chatSeenLabel.text = @"Seen";
            }
            
            
            if ([chatMessage.messageDelivered isEqualToNumber:[NSNumber numberWithInt:2]]) {
                cell.deliveryStatusImageView.hidden = NO;
            } else {
                cell.deliveryStatusImageView.hidden = YES;
            }
            
            
            /*if([chatMessage.messageDelivered intValue] == 2){
             
             NSLog(@"CHAT DELIVERED ");
             //cell.deliveryStatusImageView
             cell.deliveryStatusImageView.image = [UIImage imageNamed:@"mumbler_deleverd_img"];
             
             }*/
            
            //Friend statement Blue Balloon
            if([chatMessage.textMessageType isEqualToString:TEXT_TYPE_STATEMENT]){
                
                cell.chatCellType=ChatCellTypeFriendChat_statement;
            }
            //Friend question Orange Balloon
            else{
                cell.chatCellType=ChatCellTypeFriendChat_Question;
            }
            
            
            return cell;
            
        }
        
    }else{
        NSLog(@"TESTING IMAGE SENDING TYPE IS NOT CHAT");
        
        if([chatMessage.messageMediumType isEqualToString:MESSAGE_MEDIUM_IMAGE] || [chatMessage.messageMediumType isEqualToString:MESSAGE_MEDIUM_VIDEO]){
            
            //my chat image or viedio
            if ([chatMessage.messageSender isEqual:myJID]) {
                
                
                static NSString *tableIdentifier = @"myChatOtherMessage";
                cell = (MyChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
                
                globalCell = cell;
                
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                
                NSString *messageDate= [ChatUtil getDate:chatMessage.messageDateTime  inFormat:timeFormat];
                
                cell.dateTimeLabel.text= messageDate;
                //cell.profileImageView.image = [UIImage imageNamed:@"mumbler_profile_picture"];
                
                NSData *data = [NSData dataFromBase64String:chatThread.threadOwner.profileImageBytes];
                UIImage *image= [UIImage imageWithData:data];
                
                if(image){
                    cell.profileImageView.image=image;
                    
                }else{
                    cell.profileImageView.image=[UIImage imageNamed:@"mumbler_profile_picture"];
                    
                }
                cell.profileImageView.layer.cornerRadius = 20;
                cell.profileImageView.layer.masksToBounds = YES;
                
                
                
                
                if(chatMessage.seenByUser==[NSNumber numberWithInt:1]){
                    NSLog(@"chat seen id  ------ %@",chatMessage.messageId);
                    cell.chatSeenLabel.text = @"Seen";
                }else{
                    NSLog(@"chat is not seen but sent ------ %@",chatMessage.messageId);
                    cell.chatSeenLabel.text = @"Sent";
                }
                
                
                if ([chatMessage.messageDelivered isEqualToNumber:[NSNumber numberWithInt:2]]) {
                    cell.deliveryStatusImageView.hidden = NO;
                } else {
                    cell.deliveryStatusImageView.hidden = YES;
                }
                
                
                
                
                //message type Viedio
                if([chatMessage.messageMediumType isEqualToString:MESSAGE_MEDIUM_VIDEO]){
                    NSLog(@"TESTING IMAGE SENDING  MY MESSAGE_MEDIUM_VIDEO");
                    
                    /////////new
                    
                    //its already there
                    if([chatVideoThumbnailsDictionary objectForKey:chatMessage.messageId] != nil){
                        
                        //cell.bubbleImageView.image =[chatVideoThumbnailsDictionary objectForKey:chatMessage.messageId];
                        
                        
                        cell.chatImage =[chatVideoThumbnailsDictionary objectForKey:chatMessage.messageId];
                        cell.maskImage = [UIImage imageNamed:@"mask_img_right"];
                        cell.chatCellType=ChatCellTypeMyChatOther;
                        
                        NSLog(@"thumbnail != nil its already there");
                        
                        
                    }else{
                        
                        
                        // NSString *viedioFullPath=[NSString stringWithFormat:@"%@%@",VIDEIO_PATH,chatMessage.textMessage];
                        NSString *viedioFullPath= @"http://mumblerchat.com:1935/mumblerchat/mp4:1398780589751.mp4/playlist.m3u8";
                        
                        NSLog(@"viedioFullPath textMessage %@",viedioFullPath);
                        NSURL *url = [NSURL URLWithString:viedioFullPath];
                        
                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                            
                            AVAsset *asset = [AVAsset assetWithURL:url];
                            
                            //  Get thumbnail at the very start of the video
                            
                            CMTime thumbnailTime = [asset duration];
                            //thumbnailTime.value = thumbnailTime.timescale * 1;
                            thumbnailTime.value = 1;
                            
                            /* CMTime thumbnailTime = [asset duration];
                             thumbnailTime.value = 0;*/
                            
                            //  Get image from the video at the given time
                            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                            
                            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbnailTime actualTime:NULL error:NULL];
                            UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
                            CGImageRelease(imageRef);
                            
                            
                            if(thumbnail !=nil){
                                
                                NSLog(@"thumbnail != nil ");
                                
                                // cell.bubbleImageView.image =thumbnail;
                                
                                cell.chatImage =thumbnail;
                                cell.maskImage = [UIImage imageNamed:@"mask_img_right"];
                                cell.chatCellType=ChatCellTypeMyChatOther;
                                [chatVideoThumbnailsDictionary setObject:cell.chatImage forKey:chatMessage.messageId];
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    NSLog(@"chatComposerTableView reloadInputViews my viedio before");
                                    //[cell layoutIfNeeded];
                                    cell.bubbleImageView.image =thumbnail;
                                    
                                    // [chatComposerTableView reloadInputViews];
                                    NSLog(@"chatComposerTableView reloadInputViews my viedio after");
                                    
                                });
                            }else{
                                NSLog(@"thumbnail == nil ");
                                
                            }
                            
                            
                        });
                        
                        
                        
                        /*  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                         
                         NSString *viedioFullPath=[NSString stringWithFormat:@"%@%@",VIDEIO_PATH,chatMessage.textMessage];
                         
                         NSLog(@"viedioFullPath %@",viedioFullPath);
                         
                         MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:viedioFullPath]];
                         
                         UIImage *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
                         
                         if(thumbnail !=nil){
                         
                         NSLog(@"thumbnail != nil ");
                         
                         cell.chatImage =thumbnail;
                         cell.maskImage = [UIImage imageNamed:@"mask_img_right"];
                         cell.chatCellType=ChatCellTypeMyChatOther;
                         [chatVideoThumbnailsDictionary setObject:cell.chatImage forKey:chatMessage.messageId];
                         dispatch_sync(dispatch_get_main_queue(), ^{
                         NSLog(@"chatComposerTableView reloadInputViews my viedio before");
                         //[cell layoutIfNeeded];
                         
                         // [chatComposerTableView reloadInputViews];
                         NSLog(@"chatComposerTableView reloadInputViews my viedio after");
                         
                         });
                         }else{
                         NSLog(@"thumbnail == nil ");
                         
                         }
                         
                         
                         });*/
                        
                        
                        ///////////new over
                        
                    }
                    
                }
                //message type Image
                else{
                    NSLog(@"TESTING IMAGE SENDING  MY MESSAGE_MEDIUM_IMAGE");
                    
                    //its already there
                    if([chatImagesDictionary objectForKey:chatMessage.messageId] != nil){
                        
                        cell.chatImage =[chatImagesDictionary objectForKey:chatMessage.messageId];
                        cell.maskImage = [UIImage imageNamed:@"mask_img_right"];
                        cell.chatCellType=ChatCellTypeMyChatOther;
                        
                        
                        
                        
                    }else{
                        
                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                            NSURL *imageURL = [NSURL URLWithString:chatMessage.textMessage];
                            
                            NSData *thumbnailData = [NSData dataWithContentsOfURL:imageURL];
                            
                            
                            if(thumbnailData!=nil){
                                cell.chatImage =[UIImage imageWithData:thumbnailData];
                                cell.maskImage = [UIImage imageNamed:@"mask_img_right"];
                                cell.chatCellType=ChatCellTypeMyChatOther;
                                [chatImagesDictionary setObject:cell.chatImage forKey:chatMessage.messageId];
                                
                            }
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                NSLog(@"chatComposerTableView reloadInputViews before");
                                [cell layoutIfNeeded];
                                
                                // [chatComposerTableView reloadInputViews];
                                NSLog(@"chatComposerTableView reloadInputViews after");
                                
                            });
                        });
                        
                        
                        
                        /* NSLog(@"chatMessage.threadState imageURL else %@",chatMessage.textMessage);
                         NSURL *imageURL = [NSURL URLWithString:chatMessage.textMessage];
                         
                         NSURLRequest *request = [[NSURLRequest alloc] initWithURL:imageURL];
                         AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                         
                         
                         [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                         
                         cell.chatImage =[UIImage imageWithData:responseObject];
                         cell.maskImage = [UIImage imageNamed:@"mask_img_right.png"];
                         cell.chatCellType=ChatCellTypeMyChatOther;
                         [chatImagesDictionary setObject:cell.chatImage forKey:chatMessage.messageId];
                         
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         NSLog(@"Image error: %@", error);
                         }];
                         [requestOperation start];
                         
                         */
                        
                    }
                    
                }
                
            }
            //friends image or viedio chat
            else{
                
                NSLog(@"TESTING IMAGE SENDING TYPE IS NOT CHAT FRIEND CHAT");
                
                //friendChatOtherMessage
                static NSString *tableIdentifier = @"friendChatOtherMessage";
                cell = (MyChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentifier];
                
                globalCell = cell;
                
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                
                
                //////////
                
                
                long long timeInSeconds = [chatMessage.messageDateTime longLongValue]/1000;
                NSDate *tr = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"hh:mm a"];
                
                NSString *messageDate= [formatter stringFromDate:tr];
                
                cell.dateTimeLabel.text= messageDate;
                // cell.profileImageView.image = [UIImage imageNamed:@"mumbler_profile_picture"];
                NSData *data = [NSData dataFromBase64String:chatThread.recipient.profileImageBytes];
                UIImage *image= [UIImage imageWithData:data];
                
                if(image){
                    cell.profileImageView.image=image;
                    
                }else{
                    cell.profileImageView.image=[UIImage imageNamed:@"mumbler_profile_picture"];
                    
                }
                
                cell.profileImageView.layer.cornerRadius = 20;
                cell.profileImageView.layer.masksToBounds = YES;
                
                
                
                //message type Viedio
                if([chatMessage.messageMediumType isEqualToString:@"video"]){
                    
                    /* cell.bubbleImageView.image=[UIImage imageNamed:@"popup_back.png"];*/
                    
                    NSString * url =@"http://mumblerchat.com:1935/mumblerchat/mp4:1398780589751.mp4/playlist.m3u8";
                    
                    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:url]];
                    
                    UIImage *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
                    NSData *imageData =UIImageJPEGRepresentation(thumbnail, 90);
                    /*NSString *imagebase64String = [imageData base64EncodedString];
                     [chatMsgDao updateMessageImageStringForMessageId:chat.messageId imageString:imagebase64String];
                     */
                    
                    if(thumbnail!=nil){
                        //cell.playButtonImageView.hidden=false;
                        cell.bubbleImageView.image=thumbnail;
                    }else{
                        //cell.bubbleImageView.image=[UIImage imageNamed:@"popup_back.png"];
                    }
                    
                    
                    
                }
                //message type Friend Image
                else{
                    
                    NSLog(@"TESTING IMAGE SENDING FRIEND CHAT chatMessage.messageId %@=",chatMessage.messageId);
                    
                    
                    //its already there
                    if([chatImagesDictionary objectForKey:chatMessage.messageId] != nil){
                        
                        cell.chatImage =[chatImagesDictionary objectForKey:chatMessage.messageId];
                        cell.maskImage = [UIImage imageNamed:@"mask_img"];
                        cell.chatCellType=ChatCellTypeMyChatOther;
                        
                    }else{
                        
                        
                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                            NSURL *imageURL = [NSURL URLWithString:chatMessage.textMessage];
                            
                            NSData *thumbnailData = [NSData dataWithContentsOfURL:imageURL];
                            
                            cell.chatImage =[UIImage imageWithData:thumbnailData];
                            cell.maskImage = [UIImage imageNamed:@"mask_img"];
                            cell.chatCellType=ChatCellTypeMyChatOther;
                            [chatImagesDictionary setObject:cell.chatImage forKey:chatMessage.messageId];
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                NSLog(@"chatComposerTableView reloadInputViews before");
                                [cell layoutIfNeeded];
                                
                                // [chatComposerTableView reloadInputViews];
                                NSLog(@"chatComposerTableView reloadInputViews after");
                                
                            });
                        });
                        
                    }
                }
            }
            
            return cell;
            
            
        }else{
            
            NSLog(@"TYPE IS NOT IMAGE OR VIEDO");
        }
        
        
        
        
        
    }
    return cell;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    ChatMessage *chatMessage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"Video essage clicked=== %@",chatMessage.textMessage);
    
    NSString * url =@"http://54.198.191.57:8080/MumblerChatWeb/chatVideo/1410344099230.mp4";
    
    [self openRecievedMovieAndPlay: url];
    
    
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    
    NSLog(@"moviePlayBackDidFinish-------");
    
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    if ([player
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player.view removeFromSuperview];
    }
    
}



-(void)openRecievedMovieAndPlay:(NSString*) videoUrl {
    
    NSLog(@"videoUrl %@",videoUrl);
    
    NSURL *url = [NSURL URLWithString: videoUrl];
    
    
    /*playerController = [[MPMoviePlayerViewController alloc]initWithContentURL:url];
     [self presentMoviePlayerViewControllerAnimated:playerController];
     [self.view insertSubview:playerController.view atIndex:0];
     playerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
     playerController.moviePlayer.controlStyle = MPMovieControlStyleDefault;
     playerController.moviePlayer.scalingMode = MPMovieScalingModeNone;
     
     [playerController.moviePlayer play];*/
    
    
    
    moviePlayer=[[MPMoviePlayerController alloc] initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    
    moviePlayer.controlStyle = MPMovieControlStyleDefault;
    moviePlayer.shouldAutoplay = YES;
    [self.view addSubview:moviePlayer.view];
    [moviePlayer setFullscreen:YES animated:YES];
    
}





-(void)viewDidLayoutSubviews{
    
    NSLog(@"viewDidLayoutSubviews chat");
    
    NSInteger row=0;
    /*for (id  sectionInfo in [[self fetchedResultsController] sections] ) {
     
     row=[sectionInfo numberOfObjects];
     
     }*/
    
    //  NSLog(@"row---------%li",(long)row);
    
    //[self scrollToBottom:indexPath];
    NSIndexPath *indexPath=[NSIndexPath indexPathForItem:(row-1) inSection:([[_fetchedResultsController sections] count]-1)];
    //[self scrollToBottom:indexPath];
    if(row>1){
        [self.chatComposerTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    // [self.chatList setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    
}
- (void)scrollToBottom : (NSIndexPath *) indexPath
{
    NSLog(@"scrollToBottom------");
    
    [[self chatComposerTableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    CGPoint offset = CGPointMake(0, (floor));
    [self.chatComposerTableView setContentOffset:offset animated:NO];
    
}





- (NSFetchedResultsController *)fetchedResultsController
{
    NSLog(@"NSFetchedResultsController *)fetchedResultsController threadid %@",chatThreadId);
    
    if (_fetchedResultsController == nil)
    {
        
        NSLog(@"_fetchedResultsController  *) NILLL fetchedResultsController threadid %@",chatThreadId);
        
        
        NSManagedObjectContext *nsManagedObjectContext = [appDelegate managedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatMessage"
                                                  inManagedObjectContext:nsManagedObjectContext];
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(threadId = %@)", chatThreadId];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"messageDateTime" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setPredicate:predicate];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        [fetchRequest setReturnsObjectsAsFaults:NO];
        NSFetchedResultsController *theFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
         
                                            managedObjectContext:nsManagedObjectContext
                                              sectionNameKeyPath:@"messageDeliveredDateTime"
         
                                                       cacheName:nil];
        
        self.fetchedResultsController = theFetchedResultsController;
        _fetchedResultsController.delegate = self;
        
        return _fetchedResultsController;
    }
    
    return _fetchedResultsController;
    
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.chatComposerTableView beginUpdates];
    NSLog(@"NS controllerWillChangeContent");
}



- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.chatComposerTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.chatComposerTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.chatComposerTableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            
            NSLog(@"NSFetchedResultsChangeInsert");
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            insertedNewRecordFromFriend=YES;
            
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            
            NSLog(@"NSFetchedResultsChangeUpdate");
            
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            
            
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}




- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.chatComposerTableView endUpdates];
    
    NSLog(@"NS controllerDidChangeContent === =");
    [self.chatComposerTableView endUpdates];
    NSInteger row=0;
    for (id sectionInfo in [self.fetchedResultsController sections]) {
        row = [sectionInfo numberOfObjects];
    }
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForItem:(row-1) inSection:([[_fetchedResultsController sections] count]-1)];
    if(row>1){
        [self.chatComposerTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
