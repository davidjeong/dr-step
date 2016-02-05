//
//  RealtimeViewController.m
//  Dr. Step
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import "DSRealtimeViewController.h"

#import "DSAppConstants.h"
#import "DSHeatMap.h"
#import "PNChart.h"

@interface DSRealtimeViewController ()

@property (atomic) NSMutableArray *weights;
@property (nonatomic) PNLineChart *pressureLineChart;
@property (nonatomic) PNLineChart *accelerationLineChart;

@property (weak, nonatomic) IBOutlet UIView *uiView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIView *chartView;

@property (atomic) UIImage *heatMap;
@property (nonatomic) NSNumber *boost;

@property (nonatomic) PNLineChartData *pressureData;
@property (nonatomic) PNLineChartData *accelerationData;

@property (weak, nonatomic) IBOutlet UITextField *accelerationXField;
@property (weak, nonatomic) IBOutlet UITextField *accelerationYField;
@property (weak, nonatomic) IBOutlet UITextField *accelerationZField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation DSRealtimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DSAppConstants *constants = [DSAppConstants constants];
    float height = self.view.frame.size.height;
    float width = self.view.frame.size.width;
    
    self.weights = [[NSMutableArray alloc] initWithCapacity:[constants.coordinates count]];
    
    for (int i=0; i<[constants.coordinates count]; i++) {
        [self.weights addObject:[NSNumber numberWithFloat:0.0f]];
    }
    
    // Initialize the line chart.
    self.pressureLineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(20, height*0.05, width-20, height*0.3)];
    self.pressureLineChart.yLabelFormat = @"%1.1f";
    self.pressureLineChart.backgroundColor = [UIColor clearColor];
    [self.pressureLineChart setXLabels:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7", @"8", @"9", @"10", @"11", @"12"]];
    self.pressureLineChart.showCoordinateAxis = YES;
    
    [self.pressureLineChart setYLabels:@[@"0", @"0.5 V", @"1.0 V", @"1.5 V", @"2.0 V", @"2.5 V", @"3.0 V"]];
    
    // Line Chart for Pressure
    NSArray *pressureArray = @[@0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0];
    self.pressureData = [PNLineChartData new];
    self.pressureData.dataTitle = @"Pressure";
    self.pressureData.color = PNFreshGreen;
    self.pressureData.alpha = 1.0f;
    self.pressureData.inflexionPointStyle = PNLineChartPointStyleTriangle;
    self.pressureData.getData = ^(NSUInteger index) {
        CGFloat yValue = [pressureArray[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    self.pressureLineChart.chartData = @[self.pressureData];
    
    // Line Chart for Acceleration
    self.accelerationLineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(20, height*0.35, width-20, height*0.3)];
    self.pressureLineChart.yLabelFormat = @"%1.1f";
    self.accelerationLineChart.backgroundColor = [UIColor clearColor];
    self.accelerationLineChart.showCoordinateAxis = YES;
    [self.accelerationLineChart setYLabels:@[@"-20000", @"-10000", @"0", @"10000", @"20000"]];
    [self.accelerationLineChart setXLabels:@[@"X",@"Y",@"Z"]];
    
    NSArray *accelerationArray = @[@0.0, @0.0, @0.0];
    
    self.accelerationData = [PNLineChartData new];
    self.accelerationData.dataTitle = @"Pressure";
    self.accelerationData.color = PNFreshGreen;
    self.accelerationData.alpha = 1.0f;
    self.accelerationData.itemCount = accelerationArray.count;
    self.accelerationData.inflexionPointStyle = PNLineChartPointStyleTriangle;
    self.accelerationData.getData = ^(NSUInteger index) {
        CGFloat yValue = [accelerationArray[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    self.accelerationLineChart.chartData = @[self.accelerationData];
    [self.accelerationLineChart strokeChart];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifications:)
                                                 name:@"parsedData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifications:)
                                                 name:@"disconnectedFromBean"
                                               object:nil];
}

- (void)viewDidLayoutSubviews {
    UIImage *image = [UIImage imageNamed:@"foot_image.png"];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    [self.imageView setClipsToBounds:YES];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageView setFrame:self.uiView.bounds];
    
    self.chartView = [[UIView alloc] initWithFrame:self.uiView.bounds];
    [self.chartView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.chartView addSubview:self.pressureLineChart];
    [self.chartView addSubview:self.accelerationLineChart];

    [self.uiView addSubview:self.imageView];
    [self.uiView addSubview:self.chartView];
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self.chartView setHidden:YES];
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        [self.imageView setHidden:YES];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    NSLog(@"Touch x : %f y : %f", touchPoint.x, touchPoint.y);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DSAppConstants *constants = [DSAppConstants constants];
    NSDictionary *settings = constants.settings;
    self.boost = [NSNumber numberWithFloat:[settings[@"heatMapBoost"] floatValue]];
    self.heatMap = [DSHeatMap heatMapWithRect:self.view.frame boost:[self.boost floatValue] points:constants.coordinates weights:self.weights maxWeight:MAXIMUM_VOLTAGE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)controlChanged:(id)sender {
    NSInteger selectedSegment = self.segmentedControl.selectedSegmentIndex;
    if (selectedSegment == 0) {
        [self.imageView setHidden:NO];
        [self.chartView setHidden:YES];
    } else if (selectedSegment == 1) {
        [self.imageView setHidden:YES];
        [self.chartView setHidden:NO];
    }
}

- (void) handleNotifications:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"parsedData"]) {
        if ([self isViewLoaded] && self.view.window && !self.imageView.hidden) {
            NSLog(@"Spawning new serial thread for heatmap");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                [self processGraphics:[notification object]];
            });
        } else if ([self isViewLoaded] && self.view.window && !self.chartView.hidden) {
            NSLog(@"Spawning new serial thread for heatmap");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                [self processCharts:[notification object]];
            });
        }
    } else if ([notification.name isEqualToString:@"disconnectedFromBean"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self clearGraphics];
        });
    }
}

- (void)clearGraphics {
    @synchronized (self.weights) {
        NSLog(@"Clearing graphics.");
        DSAppConstants *constants = [DSAppConstants constants];
        for (int i=0; i<[constants.coordinates count]; i++) {
            [self.weights replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:0.0f]];
        }
        self.heatMap = [DSHeatMap heatMapWithRect:self.view.frame boost:1.0f points:constants.coordinates weights:self.weights maxWeight:MAXIMUM_VOLTAGE];
        [self.imageView setImage:self.heatMap];
    }
}

- (void)processCharts:(NSDictionary *)dict {
    @synchronized(self.pressureData) {
        NSArray *pressureArray = [dict objectForKey:@"data"];
        self.pressureData.getData = ^(NSUInteger index) {
            CGFloat yValue = [pressureArray[index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        NSNumber *x = [dict objectForKey:@"accelerationX"];
        NSNumber *y = [dict objectForKey:@"accelerationY"];
        NSNumber *z = [dict objectForKey:@"accelerationZ"];
        
        NSArray *accelerationArray = @[x, y, z];
        self.accelerationData.getData = ^(NSUInteger index) {
            CGFloat yValue = [accelerationArray[index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        [self.pressureLineChart updateChartData:@[self.pressureData]];
        [self.accelerationLineChart updateChartData:@[self.accelerationData]];
    }
}

- (void)processGraphics:(NSDictionary *)dict {
    @synchronized (self.weights) {
        NSLog(@"Processing graphics");
        DSAppConstants *constants = [DSAppConstants constants];
        NSNumber *accelerationX = [dict objectForKey:@"accelerationX"];
        NSNumber *accelerationY = [dict objectForKey:@"accelerationY"];
        NSNumber *accelerationZ = [dict objectForKey:@"accelerationZ"];
        for (int i=0; i<[constants.coordinates count]; i++) {
            NSArray *array = [dict objectForKey:@"data"];
            float voltage = [[array objectAtIndex:i] floatValue];
            // To remove discrepencies
            voltage = voltage/(3-voltage);
            if (voltage > 0.10) {
                [self.weights replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:voltage]];
            } else {
                [self.weights replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:0.0f]];
            }
        }
        self.heatMap = [DSHeatMap heatMapWithRect:self.view.frame boost:[self.boost floatValue] points:constants.coordinates weights:self.weights maxWeight:MAXIMUM_VOLTAGE weightsAdjustmentEnabled:NO groupingEnabled:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.accelerationXField setText:[NSString stringWithFormat:@"X: %@", [accelerationX stringValue]]];
            [self.accelerationYField setText:[NSString stringWithFormat:@"Y: %@", [accelerationY stringValue]]];
            [self.accelerationZField setText:[NSString stringWithFormat:@"Z: %@", [accelerationZ stringValue]]];
            [self.imageView setImage:self.heatMap];
        });
        NSLog(@"Exiting processing graphics.");
    }
}

@end
