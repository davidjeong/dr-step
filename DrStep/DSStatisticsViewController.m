//
//  DSStatisticsViewController.m
//  DrStep
//
//  Created by Juhwan Jeong on 2015. 10. 31..
//
//

#import "DSStatisticsViewController.h"

#import "PNChart.h"

#define ARC4RANDOM_MAX 0x100000000

@interface DSStatisticsViewController ()


@property (weak, nonatomic) IBOutlet UIView *uiView;
@property (nonatomic) UIView *analyticsView;
@property (nonatomic) UIView *scatterView;

@property (nonatomic) PNCircleChart *circleChartTopLeft;
@property (nonatomic) PNCircleChart *circleChartTopRight;
@property (nonatomic) PNCircleChart *circleChartBottomLeft;
@property (nonatomic) PNCircleChart *circleChartBottomRight;

@property (nonatomic) PNScatterChart *scatterChart;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

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
    self.circleChartTopLeft = [[PNCircleChart alloc] initWithFrame:CGRectMake(0,height*0.05, width*0.5f, 100.0)
                                                             total:@100
                                                           current:@0
                                                         clockwise:YES];
    self.circleChartTopRight = [[PNCircleChart alloc] initWithFrame:CGRectMake(0,height*0.05, width*1.5f, 100.0)
                                                              total:@100
                                                            current:@0
                                                          clockwise:YES];
    self.circleChartBottomLeft = [[PNCircleChart alloc] initWithFrame:CGRectMake(0,height*0.4, width*0.5f, 100.0)
                                                                total:@100
                                                              current:@0
                                                            clockwise:YES];
    self.circleChartBottomRight = [[PNCircleChart alloc] initWithFrame:CGRectMake(0,height*0.4, width*1.5f, 100.0)
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
    
    self.analyticsView = [[UIView alloc] initWithFrame:self.uiView.bounds];
    
    [self.analyticsView addSubview:self.circleChartTopLeft];
    [self.analyticsView addSubview:self.circleChartTopRight];
    [self.analyticsView addSubview:self.circleChartBottomLeft];
    [self.analyticsView addSubview:self.circleChartBottomRight];
    
    [self.circleChartTopLeft updateChartByCurrent:@(arc4random() % 100)];
    [self.circleChartTopRight updateChartByCurrent:@(arc4random() % 100)];
    [self.circleChartBottomLeft updateChartByCurrent:@(arc4random() % 100)];
    [self.circleChartBottomRight updateChartByCurrent:@(arc4random() % 100)];
    
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
    
    [self.uiView addSubview:self.analyticsView];
    [self.uiView addSubview:self.scatterView];
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self.scatterView setAlpha:0.0];
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        [self.analyticsView setAlpha:0.0];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            [self.analyticsView setAlpha:1.0];
        }];
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        [UIView animateWithDuration:0.2 animations:^() {
            [self.scatterView setAlpha:1.0];
            [self.analyticsView setAlpha:0.0];
        }];
    }
}

@end
