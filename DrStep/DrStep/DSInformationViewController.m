//
//  InformationViewController.m
//  Dr. Step
//
//  Created by David Jeong on 2015. 6. 22..
//
//

#import "DSInformationViewController.h"

#import "DSAppConstants.h"
#import "DSInformationDetailViewController.h"
#import "DSSymptom.h"
#import "DSSymptomTableViewCell.h"

@interface DSInformationViewController ()

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray *searchResults;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DSInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    [self.searchController setSearchResultsUpdater:self];
    [self.searchController setDimsBackgroundDuringPresentation:NO];
    [[self.searchController searchBar] setDelegate:self];
    // Fit the search bar to view.
    [self.searchController.searchBar setPlaceholder:@"Enter symptom or diagnosis"];
    [[self.searchController searchBar] sizeToFit];
    
    [self.tableView setDelegate:self];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    //self.definesPresentationContext = YES;
    
    DSAppConstants *constants = [DSAppConstants constants];
    self.searchResults = constants.symptoms;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UISearchBarDelegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [searchController.searchBar text];
    if (searchString != nil && [searchString length] != 0) {
        [self filterContentForSearchText:searchString scope:nil];
    } else {
        DSAppConstants *constants = [DSAppConstants constants];
        self.searchResults = constants.symptoms;
    }
    [self.tableView reloadData];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Filter the results using a predicate.
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"scientificName contains[cd] %@ OR commonName contains[cd] %@ OR symptomDescription contains[cd] %@",
                                    searchText, searchText, searchText];
    DSAppConstants *constants = [DSAppConstants constants];
    self.searchResults = [constants.symptoms filteredArrayUsingPredicate:resultPredicate];
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
        DSAppConstants *constants = [DSAppConstants constants];
        return [constants.symptoms count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"symptomCell";
    DSSymptomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        // If cell is nil, create a new cell.
        cell = [[DSSymptomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    DSSymptom *symptom = [self.searchResults objectAtIndex:indexPath.row];
    [cell.scientificName setText:symptom.scientificName];
    [cell.commonName setText:symptom.commonName];
    
    return cell;
}

#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSymptomDetails"]) {
        [self.searchController setActive:NO];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DSSymptom *symptom = [self.searchResults objectAtIndex:indexPath.row];
        
        DSInformationDetailViewController *viewController = segue.destinationViewController;
        viewController.symptom = symptom;
    }
}

@end
