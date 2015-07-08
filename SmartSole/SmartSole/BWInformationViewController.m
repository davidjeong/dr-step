//
//  InformationViewController.m
//  BioWear
//
//  Created by David Jeong on 2015. 6. 22..
//
//

#import "BWInformationViewController.h"

@interface BWInformationViewController ()

@end

@implementation BWInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    // Fit the search bar to view.
    [self.searchController.searchBar sizeToFit];
    
    // Create a dummy array.
    self.tableData = [NSArray arrayWithObjects:@"Lorem", @"Ipsum", @"Dolor", @"Sit Amet", nil];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    if (searchString != nil && [searchString length] != 0) {
        [self filterContentForSearchText:searchString scope:nil];
    } else {
        self.searchResults = self.tableData;
    }
    [self.tableView reloadData];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Filter the results using a predicate.
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
    
    self.searchResults = [self.tableData filteredArrayUsingPredicate:resultPredicate];
}

- (void) searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active) {
        return [self.searchResults count];
    } else {
        return [self.tableData count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        // If cell is nil, create a new cell.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if (self.searchController.active) {
        cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row];
        return cell;
    } else {
        cell.textLabel.text = [self.tableData objectAtIndex:indexPath.row];
        return cell;
    }
}

@end
