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
@property (nonatomic) PNLineChart *lineChart;

@property (weak, nonatomic) IBOutlet UIView *uiView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIView *chartView;

@property (atomic) UIImage *heatMap;
@property (nonatomic) NSNumber *boost;

@property (weak, nonatomic) IBOutlet UITextField *accelerationXField;
@property (weak, nonatomic) IBOutlet UITextField *accelerationYField;
@property (weak, nonatomic) IBOutlet UITextField *accelerationZField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation DSRealtimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DSAppConstants *constants = [DSAppConstants constants];
    
    self.weights = [[NSMutableArray alloc] initWithCapacity:[constants.coordinates count]];
    
    for (int i=0; i<[constants.coordinates count]; i++) {
        [self.weights addObject:[NSNumber numberWithFloat:0.0f]];
    }
    
    // Initialize the line chart.
    self.lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 135.0, SCREEN_WIDTH, 200.0)];
    self.lineChart.yLabelFormat = @"%1.1f";
    self.lineChart.backgroundColor = [UIColor clearColor];
    [self.lineChart setXLabels:@[@"SEP 1",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 6",@"SEP 7"]];
    self.lineChart.showCoordinateAxis = YES;
    
    [self.lineChart setYLabels:@[
                                 @"0 min",
                                 @"50 min",
                                 @"100 min",
                                 @"150 min",
                                 @"200 min",
                                 @"250 min",
                                 @"300 min",
                                 ]
     ];
    
    // Line Chart #1
    NSArray * data01Array = @[@60.1, @160.1, @126.4, @0.0, @186.2, @127.2, @176.2];
    PNLineChartData *data01 = [PNLineChartData new];
    data01.dataTitle = @"Alpha";
    data01.color = PNFreshGreen;
    data01.alpha = 0.3f;
    data01.itemCount = data01Array.count;
    data01.inflexionPointStyle = PNLineChartPointStyleTriangle;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    [self.lineChart setXLabels:@[@"DEC 1",@"DEC 2",@"DEC 3",@"DEC 4",@"DEC 5",@"DEC 6",@"DEC 7"]];
    self.lineChart.chartData = @[data01];
    [self.lineChart strokeChart];
    
    [self.chartView addSubview:self.lineChart];
    
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
    [self.chartView addSubview:self.lineChart];

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
            NSLog(@"Spawning new serial thread");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                [self processGraphics:[notification object]];
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
