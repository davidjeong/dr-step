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
@property (retain, nonatomic) NSArray *positive;
@property (retain, nonatomic) NSArray *negative;

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Positive";
    } else if (section == 1) {
        return @"Negative";
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

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
    symptom.url = [object objectForKey:@"webUrl"];
    
    cell.symptom = symptom;
    
    DSAppConstants *constants = [DSAppConstants constants];
    if ([constants.symptomToSimilarity objectForKey:symptom.scientificName]) {
        float similarity = [constants.symptomToSimilarity[symptom.scientificName] floatValue];
        NSNumber *healthy = [object objectForKey:@"healthy"];
        bool isHealthy = [healthy isEqualToNumber:[NSNumber numberWithInt:0]];
        [cell.similarity setTextColor:[self _colorForTable:isHealthy similarity:similarity]];
        cell.similarity.text = [NSString stringWithFormat:@"%d%%", (int)(similarity*100)];
    }
    
    cell.scientificName.text = symptom.scientificName;
    cell.commonName.text = symptom.commonName;
    return cell;
}

#pragma mark - Private

#pragma mark - Private

- (UIColor *) _colorForTable:(bool)healthy similarity:(float)similarity {
    if (healthy) {
        if (similarity >= 0.0 && similarity < 0.5) {
            return PNRed;
        } else if (similarity >= 0.5 && similarity < 0.8) {
            return PNYellow;
        } else {
            return PNGreen;
        }
    } else {
        if (similarity >= 0.0 && similarity < 0.5) {
            return PNGreen;
        } else if (similarity >= 0.5 && similarity < 0.8) {
            return PNYellow;
        } else {
            return PNRed;
        }
    }
    return PNRed;
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
    
    NSMutableArray *tempPositive = [[NSMutableArray alloc] init];
    NSMutableArray *tempNegative = [[NSMutableArray alloc] init];
    
    for (PFObject *object in self.objects) {
        NSNumber *healthy = [object objectForKey:@"healthy"];
        if ([healthy isEqualToNumber:[NSNumber numberWithInt:0]]) {
            [tempPositive addObject:object];
        } else {
            [tempNegative addObject:object];
        }
    }
    
    self.positive = [NSArray arrayWithArray:tempPositive];
    self.negative = [NSArray arrayWithArray:tempNegative];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
}

- (PFObject *) objectAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self.positive objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        return [self.negative objectAtIndex:indexPath.row];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.positive.count;
    } else if (section == 1) {
        return self.negative.count;
    }
    return 0;
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
