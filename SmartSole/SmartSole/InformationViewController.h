//
//  InformationViewController.h
//  SmartSole
//
//  Created by David Jeong on 2015. 6. 22..
//
//

#import <UIKit/UIKit.h>

@interface InformationViewController : UIViewController <UISearchBarDelegate, UISearchResultsUpdating, UITableViewDataSource>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray *tableData;
@property (strong, nonatomic) NSArray *searchResults;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
