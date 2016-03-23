//
//  RealtimeViewController.m
//  Dr. Step
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import "DSRealtimeViewController.h"

#import <PTDBeanManager.h>

#import "DSAppConstants.h"
#import "DSHeatMap.h"
#import "PNChart.h"

@interface DSRealtimeViewController ()

@property (weak, nonatomic) IBOutlet UIVisualEffectView *effectView;

@property (atomic) NSMutableArray *weights;
@property (nonatomic) PNLineChart *pressureLineChart;
@property (nonatomic) PNLineChart *accelerationLineChart;

@property (weak, nonatomic) IBOutlet UIView *uiView;
@property (nonatomic) UIImageView *baseImageView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIView *chartView;

@property (atomic) UIImage *heatMap;
@property (nonatomic) NSNumber *boost;
@property (nonatomic) CATransition *transition;

@property (atomic) PNLineChartData *pressureData;
@property (atomic) PNLineChartData *accelerationData;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation DSRealtimeViewController

#pragma mark - Lifecycle

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
    self.pressureLineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(5, height*0.05, width-5, height*0.3)];
    self.pressureLineChart.yLabelFormat = @"%1.1f";
    self.pressureLineChart.backgroundColor = [UIColor clearColor];
    self.pressureLineChart.showCoordinateAxis = YES;
    self.pressureLineChart.xLabelFont = [UIFont systemFontOfSize:8.0f];
    self.pressureLineChart.yLabelFont = [UIFont systemFontOfSize:8.0f];
    [self.pressureLineChart setXLabels:@[@"A0Y0",@"A0Y1",@"A0Y2",@"A0Y3",@"A0Y4",@"A0Y5",@"A1Y0", @"A1Y1", @"A1Y2", @"A1Y3", @"A1Y4", @"A1Y5"]];
    [self.pressureLineChart setYLabels:@[@"0", @"50", @"100", @"150", @"200"]];
    self.pressureLineChart.yFixedValueMax = 200;
    self.pressureLineChart.yFixedValueMin = 0.0;
    
    // Line Chart for Pressure
    NSArray *pressureArray = @[@0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0];
    self.pressureData = [PNLineChartData new];
    self.pressureData.dataTitle = @"Pressure";
    self.pressureData.color = PNFreshGreen;
    self.pressureData.alpha = 1.0f;
    self.pressureData.itemCount = pressureArray.count;
    self.pressureData.inflexionPointStyle = PNLineChartPointStyleCircle;
    self.pressureData.getData = ^(NSUInteger index) {
        CGFloat yValue = [pressureArray[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };

    
    self.pressureLineChart.chartData = @[self.pressureData];
    [self.pressureLineChart strokeChart];
    
    // Line Chart for Acceleration
    self.accelerationLineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(5, height*0.35, width-5, height*0.3)];
    self.pressureLineChart.yLabelFormat = @"%1.1f";
    self.accelerationLineChart.backgroundColor = [UIColor clearColor];
    self.accelerationLineChart.showCoordinateAxis = YES;
    self.accelerationLineChart.xLabelFont = [UIFont systemFontOfSize:8.0f];
    self.accelerationLineChart.yLabelFont = [UIFont systemFontOfSize:8.0f];
    [self.accelerationLineChart setYLabels:@[@"0", @"200", @"400", @"600"]];
    [self.accelerationLineChart setXLabels:@[@"X",@"Y",@"Z"]];
    self.accelerationLineChart.yFixedValueMax = 600;
    self.accelerationLineChart.yFixedValueMin = 0;
    
    NSArray *accelerationArray = @[@0.0, @0.0, @0.0];
    
    self.accelerationData = [PNLineChartData new];
    self.accelerationData.dataTitle = @"Acceleration";
    self.accelerationData.color = PNFreshGreen;
    self.accelerationData.alpha = 1.0f;
    self.accelerationData.itemCount = accelerationArray.count;
    self.accelerationData.inflexionPointStyle = PNLineChartPointStyleCircle;
    self.accelerationData.getData = ^(NSUInteger index) {
        CGFloat yValue = [accelerationArray[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    self.accelerationLineChart.chartData = @[self.accelerationData];
    [self.accelerationLineChart strokeChart];
    
    self.transition = [CATransition animation];
    self.transition.duration = 0.5f;
    self.transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    self.transition.type = kCATransitionFade;
    
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
    self.baseImageView = [[UIImageView alloc] initWithImage:image];
    [self.baseImageView setClipsToBounds:YES];
    [self.baseImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.baseImageView setFrame:self.uiView.bounds];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.baseImageView.bounds];
    [self.imageView setClipsToBounds:YES];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageView setFrame:self.uiView.bounds];
    
    self.chartView = [[UIView alloc] initWithFrame:self.uiView.bounds];
    [self.chartView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.chartView addSubview:self.pressureLineChart];
    [self.chartView addSubview:self.accelerationLineChart];

    [self.uiView addSubview:self.baseImageView];
    [self.uiView addSubview:self.imageView];
    [self.uiView addSubview:self.chartView];
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self.chartView setAlpha:0.0];
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        [self.imageView setAlpha:0.0];
        [self.baseImageView setAlpha:0.0];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DSAppConstants *constants = [DSAppConstants constants];
    NSDictionary *settings = constants.settings;
    self.boost = [NSNumber numberWithFloat:[settings[@"heatMapBoost"] floatValue]];
    
    if (constants.bean != nil) {
        self.effectView.hidden = YES;
    } else {
        self.effectView.hidden = NO;
    }
}

#pragma mark - IBAction

- (IBAction)controlChanged:(id)sender {
    NSInteger selectedSegment = self.segmentedControl.selectedSegmentIndex;
    if (selectedSegment == 0) {
        [UIView animateWithDuration:0.2 animations:^() {
            [self.imageView setAlpha:1.0];
            [self.baseImageView setAlpha:1.0];
            [self.chartView setAlpha:0.0];
        }];
    } else if (selectedSegment == 1) {
        [UIView animateWithDuration:0.2 animations:^() {
            [self.imageView setAlpha:0.0];
            [self.baseImageView setAlpha:0.0];
            [self.chartView setAlpha:1.0];
        }];
    }
}

#pragma mark - Local Notifications

- (void) handleNotifications:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"parsedData"]) {
        if ([self isViewLoaded] && self.view.window && self.imageView.alpha != 0.0) {
            //NSLog(@"Spawning new serial thread for heatmap");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                [self _processGraphics:[notification object]];
            });
        } else if ([self isViewLoaded] && self.view.window && self.chartView.alpha != 0.0) {
            //NSLog(@"Spawning new serial thread for chart");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                [self _processCharts:[notification object]];
            });
        }
    } else if ([notification.name isEqualToString:@"disconnectedFromBean"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self _clearGraphics];
        });
    }
}

#pragma mark - Private

- (void)_clearGraphics {
    @synchronized (self.weights) {
        NSLog(@"Clearing graphics.");
        DSAppConstants *constants = [DSAppConstants constants];
        for (int i=0; i<[constants.coordinates count]; i++) {
            [self.weights replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:0.0f]];
        }
        self.heatMap = [DSHeatMap heatMapWithRect:self.view.frame boost:1.0f points:constants.coordinates weights:self.weights maxWeight:0];
        [self.imageView setImage:self.heatMap];
    }
    
    @synchronized(self.pressureData) {
        NSArray *pressureArray = @[@0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0, @0.0];
        self.pressureData.getData = ^(NSUInteger index) {
            CGFloat yValue = [pressureArray[index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.pressureLineChart updateChartData:@[self.pressureData]];
        });
    }
    
    @synchronized(self.accelerationData) {
        NSArray *accelerationArray = @[@0.0, @0.0, @0.0];
        self.accelerationData.getData = ^(NSUInteger index) {
            CGFloat yValue = [accelerationArray[index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.accelerationLineChart updateChartData:@[self.accelerationData]];
        });
    }
}

- (void)_processCharts:(NSDictionary *)dict {
    @synchronized(self.pressureData) {
        NSArray *pressureArray = [dict objectForKey:@"data"];
        
        NSMutableArray *modifiedArray = [[NSMutableArray alloc] initWithArray:pressureArray];
        int count = 0;
        for (int i=0; i<6; i++) {
            [modifiedArray replaceObjectAtIndex:i withObject:pressureArray[count]];
            [modifiedArray replaceObjectAtIndex:(i+6) withObject:pressureArray[count+1]];
            count+=2;
        }
        
        DSAppConstants *constants = [DSAppConstants constants];
        NSNumber *batteryVoltage = constants.bean.batteryVoltage;
        
        for (int i=0; i <modifiedArray.count; i++) {
            double force = [[modifiedArray objectAtIndex:i] doubleValue];
            force = 7.25*100000/(10000*([batteryVoltage doubleValue] - force)/force);
            
            if (force > 200) {
                double force = [[modifiedArray objectAtIndex:i] doubleValue];
                force = 1.45*1000000/(10000*([batteryVoltage doubleValue] - force)/force) - 215.743;
            }
            force = force/11.41232;
            [modifiedArray replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:force]];
        }
        
        self.pressureData.getData = ^(NSUInteger index) {
            CGFloat yValue = [modifiedArray[index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.pressureLineChart updateChartData:@[self.pressureData]];
        });
    }
    
    @synchronized(self.accelerationData) {
        NSNumber *x = [dict objectForKey:@"accelerationX"];
        NSNumber *y = [dict objectForKey:@"accelerationY"];
        NSNumber *z = [dict objectForKey:@"accelerationZ"];
        
        NSArray *accelerationArray = @[x, y, z];
        self.accelerationData.getData = ^(NSUInteger index) {
            CGFloat yValue = fabs([accelerationArray[index] floatValue]);
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.accelerationLineChart updateChartData:@[self.accelerationData]];
        });
        
        NSLog(@"%f, %f, %f", x.floatValue, y.floatValue, z.floatValue);
        NSLog(@"Updated chart");
    }
}

- (void)_processGraphics:(NSDictionary *)dict {
    @synchronized (self.weights) {
        NSLog(@"Processing graphics");
        DSAppConstants *constants = [DSAppConstants constants];
        for (int i=0; i<[constants.coordinates count]; i++) {
            NSArray *array = [dict objectForKey:@"data"];
            float voltage = [[array objectAtIndex:i] floatValue];
            // To remove discrepencies
            [self.weights replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:voltage]];
        }
        self.heatMap = [DSHeatMap heatMapWithRect:self.imageView.frame boost:[self.boost floatValue] points:constants.coordinates weights:self.weights maxWeight:[constants.bean.batteryVoltage floatValue] weightsAdjustmentEnabled:NO groupingEnabled:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView.layer removeAnimationForKey:@"animate"];
            [self.imageView setImage:self.heatMap];
            [self.imageView.layer addAnimation:self.transition forKey:@"animate"];
        });
        NSLog(@"Exiting processing graphics.");
    }
}

@end
