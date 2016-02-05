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

@property (nonatomic) PNCircleChart *circleChartTopLeft;
@property (nonatomic) PNCircleChart *circleChartTopRight;
@property (nonatomic) PNCircleChart *circleChartBottomLeft;
@property (nonatomic) PNCircleChart *circleChartBottomRight;

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
    self.circleChartTopLeft = [[PNCircleChart alloc] initWithFrame:CGRectMake(0,height*0.25, width*0.5f, 100.0)
                                                             total:@100
                                                           current:@0
                                                         clockwise:YES];
    self.circleChartTopRight = [[PNCircleChart alloc] initWithFrame:CGRectMake(0,height*0.25, width*1.5f, 100.0)
                                                              total:@100
                                                            current:@0
                                                          clockwise:YES];
    self.circleChartBottomLeft = [[PNCircleChart alloc] initWithFrame:CGRectMake(0,height*0.6, width*0.5f, 100.0)
                                                                total:@100
                                                              current:@0
                                                            clockwise:YES];
    self.circleChartBottomRight = [[PNCircleChart alloc] initWithFrame:CGRectMake(0,height*0.6, width*1.5f, 100.0)
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
    
    [self.view addSubview:self.circleChartTopLeft];
    [self.view addSubview:self.circleChartTopRight];
    [self.view addSubview:self.circleChartBottomLeft];
    [self.view addSubview:self.circleChartBottomRight];
    
    [self.circleChartTopLeft updateChartByCurrent:@(arc4random() % 100)];
    [self.circleChartTopRight updateChartByCurrent:@(arc4random() % 100)];
    [self.circleChartBottomLeft updateChartByCurrent:@(arc4random() % 100)];
    [self.circleChartBottomRight updateChartByCurrent:@(arc4random() % 100)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
