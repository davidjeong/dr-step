//
//  DSStatisticsViewController.m
//  DrStep
//
//  Created by Juhwan Jeong on 2015. 10. 31..
//
//

#import "DSStatisticsViewController.h"

#import "PNChart.h"

@interface DSStatisticsViewController ()

@property (nonatomic) PNCircleChart *circleChart;

@end

@implementation DSStatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.circleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(0,150.0, SCREEN_WIDTH, 100.0)
                                                      total:@100
                                                    current:@60
                                                  clockwise:YES];
    self.circleChart.backgroundColor = [UIColor clearColor];
    [self.circleChart setStrokeColor:PNGreen];
    [self.circleChart strokeChart];
    [self.view addSubview:self.circleChart];
    NSLog(@"First view loaded");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.circleChart updateChartByCurrent:@(arc4random() % 100)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
