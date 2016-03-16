//
//  DSStatisticsViewController.m
//  DrStep
//
//  Created by Juhwan Jeong on 2015. 10. 31..
//
//

#import "DSStatisticsViewController.h"

#import <Parse/Parse.h>

#import "DSAppConstants.h"
#import "DSInformationDetailViewController.h"
#import "DSSymptom.h"
#import "NSDate+TimeAgo.h"
#import "PNChart.h"

#define ARC4RANDOM_MAX 0x100000000

@interface DSStatisticsViewController ()


@property (weak, nonatomic) IBOutlet UIView *uiView;
@property (nonatomic) UIView *scatterView;

@property (nonatomic) PNCircleChart *circleChartTopLeft;
@property (nonatomic) PNCircleChart *circleChartTopRight;
@property (nonatomic) PNCircleChart *circleChartBottomLeft;

@property (weak, nonatomic) IBOutlet UIView *topLeftView;
@property (weak, nonatomic) IBOutlet UIView *topRightView;
@property (weak, nonatomic) IBOutlet UIView *bottomLeftView;
@property (weak, nonatomic) IBOutlet UIView *bottomRightView;

@property (nonatomic) PNScatterChart *scatterChart;
@property (atomic) PNScatterChartData *scatterData;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic) DSSymptom *primarySymptom;
@property (nonatomic) DSSymptom *secondarySymptom;
@property (nonatomic) DSSymptom *tertiarySymptom;
@property (nonatomic) NSDate *lastUpdatedDate;
@property (weak, nonatomic) IBOutlet UILabel *primarySymptomLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondarySymptomLabel;
@property (weak, nonatomic) IBOutlet UILabel *tertiarySymptomLabel;

@property (weak, nonatomic) IBOutlet UILabel *dataSetLabel;
@property (weak, nonatomic) IBOutlet UILabel *updatedDateLabel;

@end

@implementation DSStatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
     Initialize all four circle charts, one on each corner of the screen
     Set the color to green
    */
    self.circleChartTopLeft = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, 80, 80)
                                                             total:@100
                                                           current:@0
                                                         clockwise:YES];
    self.circleChartTopRight = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, 80, 80)
                                                              total:@100
                                                            current:@0
                                                          clockwise:YES];
    self.circleChartBottomLeft = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, 80, 80)
                                                                total:@100
                                                              current:@0
                                                            clockwise:YES];
    
    self.circleChartTopLeft.backgroundColor = [UIColor clearColor];
    self.circleChartTopRight.backgroundColor = [UIColor clearColor];
    self.circleChartBottomLeft.backgroundColor = [UIColor clearColor];
    
    [self.circleChartTopLeft setStrokeColor:PNGreen];
    [self.circleChartTopRight setStrokeColor:PNGreen];
    [self.circleChartBottomLeft setStrokeColor:PNGreen];
    
    [self.circleChartTopLeft strokeChart];
    [self.circleChartTopRight strokeChart];
    [self.circleChartBottomLeft strokeChart];
    
    [self.topLeftView addSubview:self.circleChartTopLeft];
    [self.topRightView addSubview:self.circleChartTopRight];
    [self.bottomLeftView addSubview:self.circleChartBottomLeft];
    
    [self.dataSetLabel setTextColor:PNGreen];
    
    /*
     Initialize scatter plot
    */
    self.scatterChart = [[PNScatterChart alloc] initWithFrame:CGRectMake(SCREEN_WIDTH /6.0 - 30, 0, SCREEN_WIDTH - 40, self.uiView.bounds.size.height - 60)];
    [self.scatterChart setAxisXWithMinimumValue:1 andMaxValue:12 toTicks:12];
    [self.scatterChart setAxisYWithMinimumValue:1 andMaxValue:12 toTicks:12];
    
    //NSArray * scatterArray = [self generateRandomArray];
    self.scatterData = [PNScatterChartData new];
    self.scatterData.strokeColor = PNGreen;
    self.scatterData.fillColor = PNFreshGreen;
    self.scatterData.size = 2;
    self.scatterData.itemCount = 0;
    self.scatterData.inflexionPointStyle = PNScatterChartPointStyleCircle;
    //NSMutableArray *x = [NSMutableArray arrayWithArray:[scatterArray objectAtIndex:0]];
    //NSMutableArray *y = [NSMutableArray arrayWithArray:[scatterArray objectAtIndex:1]];
    /*scatterData.getData = ^(NSUInteger index) {
    CGFloat xValue = [[x objectAtIndex:index] floatValue];
        CGFloat yValue = [[y objectAtIndex:index] floatValue];
        return [PNScatterChartDataItem dataItemWithX:xValue AndWithY:yValue];
    };*/
    
    [self.scatterChart setup];
    self.scatterChart.chartData = @[self.scatterData];
    
    self.scatterView = [[UIView alloc] initWithFrame:self.uiView.bounds];
    [self.scatterView addSubview:self.scatterChart];
    [self.uiView addSubview:self.scatterView];
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self.scatterView setAlpha:0.0];
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        [self.topLeftView setAlpha:0.0];
        [self.topRightView setAlpha:0.0];
        [self.bottomLeftView setAlpha:0.0];
        [self.bottomRightView setAlpha:0.0];
    }
}

- (void)viewDidLayoutSubviews{
    self.circleChartTopLeft.center = CGPointMake(self.topLeftView.bounds.size.width/2, self.topLeftView.bounds.size.height/2 + 10);
    self.circleChartTopRight.center = CGPointMake(self.topRightView.bounds.size.width/2, self.topRightView.bounds.size.height/2 + 10);
    self.circleChartBottomLeft.center = CGPointMake(self.bottomLeftView.bounds.size.width/2, self.bottomLeftView.bounds.size.height/2 + 10);
    self.scatterChart.center = CGPointMake(self.uiView.bounds.size.width/2, self.uiView.bounds.size.height/2 - 30);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // We fetch the data here for the pie charts.

    PFQuery *query = [PFQuery queryWithClassName:@"Similarity"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Retrieved similiarities");
            if (objects.count == 0) return;
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"similarity" ascending:NO];
            NSArray *descriptors = [NSArray arrayWithObject:descriptor];
            NSArray *sorted = [objects sortedArrayUsingDescriptors:descriptors];
            if (sorted.count > 0) {
                PFObject *object = sorted[0][@"symptom"];
                [object fetchIfNeededInBackgroundWithBlock:^(PFObject *symptom, NSError *error) {
                    float majorSimilarity = [sorted[0][@"similarity"] floatValue];
                    if (majorSimilarity >= 0.0 && majorSimilarity < 0.5) {
                        [self.circleChartTopLeft setStrokeColor:PNGreen];
                    } else if (majorSimilarity >= 0.5 && majorSimilarity < 0.8) {
                        [self.circleChartTopLeft setStrokeColor:PNYellow];
                    } else {
                        [self.circleChartTopLeft setStrokeColor:PNRed];
                    }
                    NSLog(@"Major symptom is %@", symptom[@"scientificName"]);
                    self.primarySymptom = [[DSSymptom alloc] init];
                    self.primarySymptom.commonName = symptom[@"commonName"];
                    self.primarySymptom.scientificName = symptom[@"scientificName"];
                    self.primarySymptom.diagnosis = symptom[@"diagnosis"];
                    self.primarySymptom.symptomDescription = symptom[@"symptomDescription"];
                    [self.circleChartTopLeft updateChartByCurrent:[NSNumber numberWithFloat:majorSimilarity] byTotal:[NSNumber numberWithFloat:1.0f]];
                    self.primarySymptomLabel.text = self.primarySymptom.scientificName;
                    [self.circleChartTopLeft strokeChart];
                }];
            }
            if (sorted.count > 1) {
                PFObject *object = sorted[1][@"symptom"];
                [object fetchIfNeededInBackgroundWithBlock:^(PFObject *symptom, NSError *error) {
                    float minorSimiliarity = [sorted[1][@"similarity"] floatValue];
                    if (minorSimiliarity >= 0.0 && minorSimiliarity < 0.5) {
                        [self.circleChartTopRight setStrokeColor:PNGreen];
                    } else if (minorSimiliarity >= 0.5 && minorSimiliarity < 0.8) {
                        [self.circleChartTopRight setStrokeColor:PNYellow];
                    } else {
                        [self.circleChartTopRight setStrokeColor:PNRed];
                    }
                    NSLog(@"Minor symptom is %@", symptom[@"scientificName"]);
                    self.secondarySymptom = [[DSSymptom alloc] init];
                    self.secondarySymptom.commonName = symptom[@"commonName"];
                    self.secondarySymptom.scientificName = symptom[@"scientificName"];
                    self.secondarySymptom.diagnosis = symptom[@"diagnosis"];
                    self.secondarySymptom.symptomDescription = symptom[@"symptomDescription"];
                    [self.circleChartTopRight updateChartByCurrent:[NSNumber numberWithFloat:minorSimiliarity] byTotal:[NSNumber numberWithFloat:1.0f]];
                    self.secondarySymptomLabel.text = self.secondarySymptom.scientificName;
                    [self.circleChartTopRight strokeChart];
                }];
            }
            if (sorted.count > 2) {
                PFObject *object = sorted[3][@"symptom"];
                [object fetchIfNeededInBackgroundWithBlock:^(PFObject *symptom, NSError *error) {
                    float minorSimiliarity = [sorted[2][@"similarity"] floatValue];
                    if (minorSimiliarity >= 0.0 && minorSimiliarity < 0.5) {
                        [self.circleChartBottomLeft setStrokeColor:PNGreen];
                    } else if (minorSimiliarity >= 0.5 && minorSimiliarity < 0.8) {
                        [self.circleChartBottomLeft setStrokeColor:PNYellow];
                    } else {
                        [self.circleChartBottomLeft setStrokeColor:PNRed];
                    }
                    NSLog(@"Minor symptom is %@", symptom[@"scientificName"]);
                    self.tertiarySymptom = [[DSSymptom alloc] init];
                    self.tertiarySymptom.commonName = symptom[@"commonName"];
                    self.tertiarySymptom.scientificName = symptom[@"scientificName"];
                    self.tertiarySymptom.diagnosis = symptom[@"diagnosis"];
                    self.tertiarySymptom.symptomDescription = symptom[@"symptomDescription"];
                    [self.circleChartBottomLeft updateChartByCurrent:[NSNumber numberWithFloat:minorSimiliarity] byTotal:[NSNumber numberWithFloat:1.0f]];
                    self.tertiarySymptomLabel.text = self.tertiarySymptom.scientificName;
                    [self.circleChartBottomLeft strokeChart];
                }];
            }
        }
    }];
    
    PFQuery *numQuery = [PFQuery queryWithClassName:@"SearchSpace"];
    [numQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [numQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 1) {
                PFObject *object = objects[0];
                NSUInteger numProcessed = [[object objectForKey:@"numProcessed"] integerValue];
                if (numProcessed >= 1000) {
                    numProcessed /= 1000;
                    [self.dataSetLabel setText:[NSString stringWithFormat:@"~%dK", (int)numProcessed]];
                } else if (numProcessed > 0 && numProcessed < 1000) {
                    [self.dataSetLabel setText:[NSString stringWithFormat:@"<1K"]];
                }
                
                NSDate *updatedDate = object.updatedAt;
                NSString *dateString = [updatedDate timeAgo];
                [self.updatedDateLabel setText:[NSString stringWithFormat:@"Last Analyzed %@", dateString]];
                
                // Grab the pressure vector and populate the data.
                NSArray *pressureArray = [object objectForKey:@"pressureVector"];
                NSMutableArray *x = [[NSMutableArray alloc] init];
                NSMutableArray *y = [[NSMutableArray alloc] init];
                for (int i=0; i < pressureArray.count; i++) {
                    NSArray *innerArray = pressureArray[i];
                    for (int j=0; j < innerArray.count; j++) {
                        NSNumber *innerNumber = @([innerArray[j] integerValue]);
                        if (![innerNumber isEqualToNumber:[NSNumber numberWithInt:0]]) {
                            [x addObject:[NSNumber numberWithInt:i+1]];
                            [y addObject:[NSNumber numberWithInt:12-j]];
                        }
                    }
                }
                self.scatterData.getData = ^(NSUInteger index) {
                    CGFloat xValue = [[x objectAtIndex:index] floatValue];
                    CGFloat yValue = [[y objectAtIndex:index] floatValue];
                    return [PNScatterChartDataItem dataItemWithX:xValue AndWithY:yValue];
                };
                self.scatterData.itemCount = x.count;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.scatterChart updateChartData:@[self.scatterData]];
                });
            }
        }
    }];
    
    PFQuery *similarityQuery = [PFQuery queryWithClassName:@"Similarity"];
    [similarityQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [similarityQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableDictionary *mutableSymptomToSimilarity = [[NSMutableDictionary alloc] initWithCapacity:objects.count];
            for (PFObject *object in objects) {
                PFObject *symptom = object[@"symptom"];
                [symptom fetchIfNeeded];
                NSNumber *similarity = object[@"similarity"];
                NSString *scientificName = symptom[@"scientificName"];
                [mutableSymptomToSimilarity setObject:similarity forKey:scientificName];
            }
            DSAppConstants *constants = [DSAppConstants constants];
            constants.symptomToSimilarity = [[NSDictionary alloc] initWithDictionary:mutableSymptomToSimilarity];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)primaryTouched:(id)sender {
    if (self.primarySymptom != nil) {
        [self performSegueWithIdentifier:@"showPossibleSymptom" sender:@"primarySender"];
    }
}

- (IBAction)secondaryTouched:(id)sender {
    if (self.secondarySymptom != nil) {
        [self performSegueWithIdentifier:@"showPossibleSymptom" sender:@"secondarySender"];
    }
}

- (IBAction)tertiaryTouched:(id)sender {
    if (self.tertiarySymptom != nil) {
        [self performSegueWithIdentifier:@"showPossibleSymptom" sender:@"tertiarySender"];
    }
}

- (NSArray*) generateRandomArray{
    NSMutableArray *array = [NSMutableArray array];
    NSString *LabelFormat = @"%1.f";
    NSMutableArray *x = [NSMutableArray array];
    NSMutableArray *y = [NSMutableArray array];
    for (int i = 0; i < 25 ; i++) {
        [x addObject:[NSString stringWithFormat:LabelFormat,(((double)arc4random() / ARC4RANDOM_MAX) * (self.scatterChart.AxisX_maxValue - self.scatterChart.AxisX_minValue) + self.scatterChart.AxisX_minValue)]];
        [y addObject:[NSString stringWithFormat:LabelFormat,(((double)arc4random() / ARC4RANDOM_MAX) * (self.scatterChart.AxisY_maxValue - self.scatterChart.AxisY_minValue) + self.scatterChart.AxisY_minValue)]];
    }
    [array addObject:x];
    [array addObject:y];
    return (NSArray*) array;
}

- (IBAction)controlChanged:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [UIView animateWithDuration:0.2 animations:^() {
            [self.scatterView setAlpha:0.0];
            [self.topLeftView setAlpha:1.0];
            [self.topRightView setAlpha:1.0];
            [self.bottomLeftView setAlpha:1.0];
            [self.bottomRightView setAlpha:1.0];
        }];
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        [UIView animateWithDuration:0.2 animations:^() {
            [self.scatterView setAlpha:1.0];
            [self.topLeftView setAlpha:0.0];
            [self.topRightView setAlpha:0.0];
            [self.bottomLeftView setAlpha:0.0];
            [self.bottomRightView setAlpha:0.0];
        }];
    }
}

#pragma mark - Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isEqualToString:@"primarySender"]) {
        DSInformationDetailViewController *viewController = segue.destinationViewController;
        viewController.tapGestureRecognizer.enabled = YES;
        viewController.symptom = self.primarySymptom;
    } else if ([sender isEqualToString:@"secondarySender"]) {
        DSInformationDetailViewController *viewController = segue.destinationViewController;
        viewController.tapGestureRecognizer.enabled = YES;
        viewController.symptom = self.secondarySymptom;
    } else if ([sender isEqualToString:@"tertiarySender"]) {
        DSInformationDetailViewController *viewController = segue.destinationViewController;
        viewController.symptom = self.tertiarySymptom;
    }
}


@end
