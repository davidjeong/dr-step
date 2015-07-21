//
//  RealtimeViewController.m
//  BioWear
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import "BWRealtimeViewController.h"

#import "BWAppConstants.h"
#import "LFHeatMap.h"

@interface BWRealtimeViewController ()

@property (nonatomic, strong) NSMutableArray *weights;
@property (nonatomic, strong) IBOutlet UIImageView *baseImage;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation BWRealtimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"foot_image.png"];
    [self.baseImage setImage:image];
    self.baseImage.contentMode = UIViewContentModeScaleAspectFit;
    
    BWAppConstants *constants = [BWAppConstants constants];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.imageView.clipsToBounds = YES;
    self.imageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:self.imageView];
    
    self.weights = [[NSMutableArray alloc] initWithCapacity:constants.coordinates.count];
    for (int i=0; i<constants.coordinates.count; i++) {
        [self.weights addObject:[NSNumber numberWithFloat:0.0f]];
    }
    
    UIImage *heatMap = [LFHeatMap heatMapWithRect:self.view.frame boost:0.75f points:constants.coordinates weights:self.weights];
    self.imageView.image = heatMap;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifications:)
                                                 name:@"finishedProcessingData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifications:)
                                                 name:@"disconnectedFromBean"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) handleNotifications:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"finishedProcessingData"]) {
        NSLog(@"Spawning new serial thread");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            if ([[notification name] isEqualToString:@"finishedProcessingData"]) {
                [self processGraphics:[notification object]];
            }
        });
    } else if ([notification.name isEqualToString:@"disconnectedFromBean"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self clearGraphics];
        });
    }
}

- (void)clearGraphics {
    @synchronized (self.weights) {
        NSLog(@"Clearing graphics.");
        BWAppConstants *constants = [BWAppConstants constants];
        for (int i=0; constants.coordinates.count; i++) {
            [self.weights replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:0.0f]];
        }
        dispatch_async(dispatch_get_main_queue(), ^ {
            NSLog(@"Dispatching main thread to run heatmap.");
            UIImage *heatMap = [LFHeatMap heatMapWithRect:self.view.frame boost:1.0f points:constants.coordinates weights:self.weights];
            self.imageView.image = heatMap;
            NSLog(@"Main thread finished heatmap.");
        });
    }
}

- (void)processGraphics:(NSMutableArray*)array {
    @synchronized (self.weights) {
        NSLog(@"Processing graphics");
        BWAppConstants *constants = [BWAppConstants constants];
        for (int i=0; i<constants.coordinates.count; i++) {
            float voltage = [[array objectAtIndex:i] floatValue];
            float intensity = voltage / maximumVoltage;
            [self.weights replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:intensity]];
        }
        dispatch_async(dispatch_get_main_queue(), ^ {
            NSLog(@"Dispatching main thread to run heatmap.");
            UIImage *heatMap = [LFHeatMap heatMapWithRect:self.view.frame boost:1.0f points:constants.coordinates weights:self.weights];
            self.imageView.image = heatMap;
            NSLog(@"Main thread finished heatmap.");
        });
        NSLog(@"Exiting processing graphics.");
    }
}

@end
