//
//  RealtimeViewController.m
//  BioWear
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import "DSRealtimeViewController.h"

#import "DSAppConstants.h"
#import "LFHeatMap.h"

@interface DSRealtimeViewController ()

@property (nonatomic, strong) NSMutableArray *weights;
@property (nonatomic, strong) IBOutlet UIImageView *baseImage;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableDictionary *layers;
@property (nonatomic, strong) UIImage *heatMap;

@end

@implementation DSRealtimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"foot_image.png"];
    [self.baseImage setImage:image];
    self.baseImage.contentMode = UIViewContentModeScaleAspectFit;
    
    DSAppConstants *constants = [DSAppConstants constants];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.imageView setClipsToBounds:YES];
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self.view addSubview:self.imageView];
    
    self.weights = [[NSMutableArray alloc] initWithCapacity:[constants.coordinates count]];
    self.layers = [[NSMutableDictionary alloc] initWithCapacity:[constants.coordinates count]];
    
    for (int i=0; i<[constants.coordinates count]; i++) {
        CGPoint point = [[constants.coordinates objectAtIndex:i] CGPointValue];
        [self.weights addObject:[NSNumber numberWithFloat:0.0f]];
        
        CATextLayer *textLayer = [[CATextLayer alloc] init];
        [textLayer setName:[NSString stringWithFormat:@"textLayer_%d", i]];
        [textLayer setFont:@"Helvetica"];
        [textLayer setFontSize:9];
        [textLayer setFrame:CGRectMake(point.x - 20, point.y - 5, 40, 10)];
        [textLayer setString:@"0.00V"];
        [textLayer setAlignmentMode:kCAAlignmentCenter];
        [textLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
        [textLayer setContentsScale:[[UIScreen mainScreen] scale]];
        
        [self.layers setObject:textLayer forKey:[NSString stringWithFormat:@"textLayer_%d", i]];
        [self.view.layer addSublayer:textLayer];
    }
    
    self.heatMap = [LFHeatMap heatMapWithRect:self.view.frame boost:[constants.heatMapBoost floatValue] points:constants.coordinates weights:self.weights];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifications:)
                                                 name:@"finishedProcessingData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifications:)
                                                 name:@"disconnectedFromBean"
                                               object:nil];
    
    // Update graphics every 0.01
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateMapInBackground) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) handleNotifications:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"finishedProcessingData"]) {
        if ([self isViewLoaded] && self.view.window) {
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
            CATextLayer *textLayer = [self.layers objectForKey:[NSString stringWithFormat:@"textLayer_%d", i]];
            if (textLayer != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Dispatching main thread to update voltage.");
                    [textLayer setString:@"0.00V"];
                    [textLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
                    NSLog(@"Main thread finished updating voltage.");
                });
            }
        }
        self.heatMap = [LFHeatMap heatMapWithRect:self.view.frame boost:1.0f points:constants.coordinates weights:self.weights];
    }
}

- (void)processGraphics:(NSMutableArray*)array {
    @synchronized (self.weights) {
        NSLog(@"Processing graphics");
        DSAppConstants *constants = [DSAppConstants constants];
        for (int i=0; i<[constants.coordinates count]; i++) {
            float voltage = [[array objectAtIndex:i] floatValue];
            // To remove discrepencies
            if (voltage > 0.10) {
                [self.weights replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:voltage]];
            } else {
                [self.weights replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:0.0f]];
            }
            CATextLayer *textLayer = [self.layers objectForKey:[NSString stringWithFormat:@"textLayer_%d", i]];
            if (textLayer != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // NSLog(@"Dispatching main thread to update voltage.");
                    [textLayer setString:[NSString stringWithFormat:@"%.02fV", voltage]];
                    if (voltage > 1.00) {
                        [textLayer setForegroundColor:[[UIColor darkTextColor] CGColor]];
                    } else {
                        [textLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
                    }
                    [self.layers setObject:textLayer forKey:[NSString stringWithFormat:@"textLayer_%d", i]];
                    // NSLog(@"Main thread finished updating voltage.");
                });
            }
        }
        self.heatMap = [LFHeatMap heatMapWithRect:self.view.frame boost:[constants.heatMapBoost floatValue] points:constants.coordinates weights:self.weights weightsAdjustmentEnabled:NO groupingEnabled:YES];
        NSLog(@"Exiting processing graphics.");
    }
}

- (void) updateMapInBackground {
    if ([self isViewLoaded] && self.view.window) {
        [self.imageView setImage:self.heatMap];
    }
}

@end
