//
//  InformationViewController.m
//  BioWear
//
//  Created by David Jeong on 2015. 6. 22..
//
//

#import "BWInformationViewController.h"

#import "BWAppConstants.h"
#import "BWInformationDetailViewController.h"
#import "BWSymptom.h"
#import "BWSymptomTableViewCell.h"

@interface BWInformationViewController ()

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray *searchResults;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BWInformationViewController

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
    self.definesPresentationContext = YES;
    
    BWAppConstants *constants = [BWAppConstants constants];
    self.searchResults = constants.symptoms;
}

- (void) viewWillAppear:(BOOL)animated {
    [self.searchController.searchBar setText:@""];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
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
        BWAppConstants *constants = [BWAppConstants constants];
        self.searchResults = constants.symptoms;
    }
    [self.tableView reloadData];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Filter the results using a predicate.
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"scientificName contains[cd] %@ OR commonName contains[cd] %@ OR symptomDescription contains[cd] %@",
                                    searchText, searchText, searchText];
    BWAppConstants *constants = [BWAppConstants constants];
    self.searchResults = [constants.symptoms filteredArrayUsingPredicate:resultPredicate];
}

- (void) searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active) {
        return [self.searchResults count];
    } else {
        BWAppConstants *constants = [BWAppConstants constants];
        return [constants.symptoms count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"symptomCell";
    BWSymptomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        // If cell is nil, create a new cell.
        cell = [[BWSymptomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    BWSymptom *symptom = [self.searchResults objectAtIndex:indexPath.row];
    [cell.scientificName setText:symptom.scientificName];
    [cell.commonName setText:symptom.commonName];
    
    return cell;
}

#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSymptomDetails"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BWSymptom *symptom = [self.searchResults objectAtIndex:indexPath.row];
        
        BWInformationDetailViewController *viewController = segue.destinationViewController;
        viewController.symptom = symptom;
    }
}

- (IBAction)unwindToInformationController:(UIStoryboardSegue *)segue {
}

@end
