//
//  ChatThreadViewController.h
//  MumblerChat
//
//  Created by Ransika De Silva on 8/29/14.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ASAppDelegate.h"


@interface ChatThreadViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate,UINavigationControllerDelegate,NSFetchedResultsControllerDelegate>{
    
     ASAppDelegate *appDelegate;
}

@property (weak, nonatomic) IBOutlet UITableView *chatThreadUITableView;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property BOOL isFromSplash;

@end
