//
//  ContactsViewController.h
//  MumblerChat
//


#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABPerson.h>
#import <AddressBookUI/AddressBookUI.h>



@interface ContactsViewController : UIViewController < ABPeoplePickerNavigationControllerDelegate,ABPersonViewControllerDelegate,ABNewPersonViewControllerDelegate,ABUnknownPersonViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate, UISearchDisplayDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong)NSMutableArray*sections;
@property(nonatomic,strong)NSMutableDictionary*sectionWiseData;

@property (strong, nonatomic) IBOutlet UISearchBar *searchAddressBook;
@property (strong, nonatomic) IBOutlet UITableView *addressBookTableView;

@property (weak, nonatomic) IBOutlet UIView *addedFriendsBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *addedFriendsLabel;
@end
