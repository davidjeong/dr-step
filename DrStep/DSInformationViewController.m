//
//  InformationViewController.m
//  Dr. Step
//
//  Created by David Jeong on 2015. 6. 22..
//
//

#import "DSInformationViewController.h"

#import <Parse/Parse.h>
#import <PNColor.h>

#import "DSAppConstants.h"
#import "DSInformationDetailViewController.h"
#import "DSSymptom.h"
#import "DSSymptomTableViewCell.h"

@interface DSInformationViewController ()

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray *searchResults;

@end

@implementation DSInformationViewController

#pragma mark - Lifecycle

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = @"Symptom";
        self.paginationEnabled = YES;
        self.pullToRefreshEnabled = NO;
        self.objectsPerPage = 20;
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
        [self loadObjects];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *cellIdentifier = @"symptomCell";
    DSSymptomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        // If cell is nil, create a new cell.
        cell = [[DSSymptomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    DSSymptom *symptom = [[DSSymptom alloc] init];
    symptom.scientificName = [object objectForKey:@"scientificName"];
    symptom.commonName = [object objectForKey:@"commonName"];
    symptom.symptomDescription = [object objectForKey:@"symptomDescription"];
    symptom.diagnosis = [object objectForKey:@"diagnosis"];
    
    cell.symptom = symptom;
    
    DSAppConstants *constants = [DSAppConstants constants];
    if ([constants.symptomToSimilarity objectForKey:symptom.scientificName]) {
        float similarity = [constants.symptomToSimilarity[symptom.scientificName] floatValue];
        if (similarity > 0 && similarity < 0.5) {
            cell.similarity.textColor = PNGreen;
        } else if (similarity >= 0.5 && similarity < 0.8) {
            cell.similarity.textColor = PNYellow;
        } else if (similarity >= 0.8) {
            cell.similarity.textColor = PNRed;
        }

        cell.similarity.text = [NSString stringWithFormat:@"%d%%", (int)(similarity*100)];
    }
    
    cell.scientificName.text = symptom.scientificName;
    cell.commonName.text = symptom.commonName;
    return cell;
}

#pragma mark - Parse

- (PFQuery *) queryForTable {
    // Query for information from Parse.
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query addAscendingOrder:@"healthy"];
    [query addAscendingOrder:@"scientificName"];
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
}

#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSymptomDetails"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        DSSymptomTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        DSInformationDetailViewController *viewController = segue.destinationViewController;
        viewController.tapGestureRecognizer.enabled = NO;
        viewController.symptom = cell.symptom;
    }
}

@end
