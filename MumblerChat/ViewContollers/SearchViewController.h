//
//  SearchViewController.h
//  MumblerChat
//


#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchFriendsSearchBar;
@property (strong, nonatomic) IBOutlet UITableView *findFriendTableView;

- (IBAction)didTapOnSearchButton:(id)sender;

@property(nonatomic,strong)NSMutableArray*sections;
@property(nonatomic,strong)NSMutableDictionary*sectionWiseData;
@property(nonatomic,strong)NSMutableArray* allData;
@property (weak, nonatomic) IBOutlet UIView *addedFriendsBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *addedFriendsLabel;


@end
