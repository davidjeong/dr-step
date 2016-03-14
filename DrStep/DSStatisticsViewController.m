//
//  DSStatisticsViewController.m
//  DrStep
//
//  Created by Juhwan Jeong on 2015. 10. 31..
//
//

#import "DSStatisticsViewController.h"

#import <Parse/Parse.h>

#import "DSInformationDetailViewController.h"
#import "DSSymptom.h"
#import "PNChart.h"

#define ARC4RANDOM_MAX 0x100000000

@interface DSStatisticsViewController ()


@property (weak, nonatomic) IBOutlet UIView *uiView;
@property (nonatomic) UIView *scatterView;

@property (nonatomic) PNCircleChart *circleChartTopLeft;
@property (nonatomic) PNCircleChart *circleChartTopRight;
@property (nonatomic) PNCircleChart *circleChartBottomLeft;
@property (nonatomic) PNCircleChart *circleChartBottomRight;

@property (weak, nonatomic) IBOutlet UIView *topLeftView;
@property (weak, nonatomic) IBOutlet UIView *topRightView;
@property (weak, nonatomic) IBOutlet UIView *bottomLeftView;
@property (weak, nonatomic) IBOutlet UIView *bottomRightView;

@property (nonatomic) PNScatterChart *scatterChart;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic) DSSymptom *primarySymptom;
@property (nonatomic) DSSymptom *secondarySymptom;
@property (nonatomic) DSSymptom *tertiarySymptom;
@property (nonatomic) NSDate *lastUpdatedDate;
@property (weak, nonatomic) IBOutlet UILabel *primarySymptomLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondarySymptomLabel;
@property (weak, nonatomic) IBOutlet UILabel *tertiarySymptomLabel;


@end

@implementation DSStatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
     Initialize all four circle charts, one on each corner of the screen
     Set the color to green
    */
    float height = self.view.frame.size.height;
    float width = self.view.frame.size.width;
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
    self.circleChartBottomRight = [[PNCircleChart alloc] initWithFrame:CGRectMake(0, 0, 80, 80)
                                                                 total:@100
                                                               current:@0
                                                             clockwise:YES];
    
    self.circleChartTopLeft.backgroundColor = [UIColor clearColor];
    self.circleChartTopRight.backgroundColor = [UIColor clearColor];
    self.circleChartBottomLeft.backgroundColor = [UIColor clearColor];
    self.circleChartBottomRight.backgroundColor = [UIColor clearColor];
    
    [self.circleChartTopLeft setStrokeColor:PNGreen];
    [self.circleChartTopRight setStrokeColor:PNGreen];
    [self.circleChartBottomLeft setStrokeColor:PNGreen];
    [self.circleChartBottomRight setStrokeColor:PNGreen];
    
    [self.circleChartTopLeft strokeChart];
    [self.circleChartTopRight strokeChart];
    [self.circleChartBottomLeft strokeChart];
    [self.circleChartBottomRight strokeChart];
    
    [self.topLeftView addSubview:self.circleChartTopLeft];
    [self.topRightView addSubview:self.circleChartTopRight];
    [self.bottomLeftView addSubview:self.circleChartBottomLeft];
    [self.bottomRightView addSubview:self.circleChartBottomRight];
    
    /*
     Initialize scatter plot
    */
    self.scatterChart = [[PNScatterChart alloc] initWithFrame:CGRectMake(20, height * 0.05, width - 30, height * 0.6)];
    [self.scatterChart setAxisXWithMinimumValue:1 andMaxValue:12 toTicks:12];
    [self.scatterChart setAxisYWithMinimumValue:1 andMaxValue:12 toTicks:12];
    
    NSArray * scatterArray = [self generateRandomArray];
    PNScatterChartData *scatterData = [PNScatterChartData new];
    scatterData.strokeColor = PNGreen;
    scatterData.fillColor = PNFreshGreen;
    scatterData.size = 2;
    scatterData.itemCount = [[scatterArray objectAtIndex:0] count];
    scatterData.inflexionPointStyle = PNScatterChartPointStyleCircle;
    NSMutableArray *x = [NSMutableArray arrayWithArray:[scatterArray objectAtIndex:0]];
    NSMutableArray *y = [NSMutableArray arrayWithArray:[scatterArray objectAtIndex:1]];
    scatterData.getData = ^(NSUInteger index) {
        CGFloat xValue = [[x objectAtIndex:index] floatValue];
        CGFloat yValue = [[y objectAtIndex:index] floatValue];
        return [PNScatterChartDataItem dataItemWithX:xValue AndWithY:yValue];
    };
    
    [self.scatterChart setup];
    self.scatterChart.chartData = @[scatterData];
    
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
    self.circleChartTopLeft.center = CGPointMake(self.topLeftView.bounds.size.width/2, self.topLeftView.bounds.size.height/2);
    self.circleChartTopRight.center = CGPointMake(self.topRightView.bounds.size.width/2, self.topRightView.bounds.size.height/2);
    self.circleChartBottomLeft.center = CGPointMake(self.bottomLeftView.bounds.size.width/2, self.bottomLeftView.bounds.size.height/2);
    self.circleChartBottomRight.center = CGPointMake(self.bottomRightView.bounds.size.width/2, self.bottomRightView.bounds.size.height/2);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // We fetch the data here for the pie charts.

    PFQuery *query = [PFQuery queryWithClassName:@"Similarity"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    //[query whereKey:@"symptom" matchesQuery:innerQuery];
    [self.circleChartBottomRight updateChartByCurrent:@(arc4random() % 100)];
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
    
    PFQuery *overallQuery = [PFQuery queryWithClassName:@"SearchSpace"];
    [overallQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [overallQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 1) {
                PFObject *searchSpace = objects[0];
                float health = [searchSpace[@"overall"] floatValue];
                [self.circleChartBottomLeft updateChartByCurrent:[NSNumber numberWithFloat:health] byTotal:[NSNumber numberWithFloat:1.0f]];
                if (health >= 0.0 && health < 0.5) {
                    [self.circleChartBottomLeft setStrokeColor:PNGreen];
                } else if (health >= 0.5 && health < 0.8) {
                    [self.circleChartBottomLeft setStrokeColor:PNYellow];
                } else {
                    [self.circleChartBottomLeft setStrokeColor:PNRed];
                }
                [self.circleChartBottomLeft strokeChart];
            }
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
