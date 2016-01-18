//
//  RealtimeViewController.m
//  Dr. Step
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
@property (nonatomic, strong) UIImage *heatMap;
@property (nonatomic, strong) NSNumber *boost;
@property (weak, nonatomic) IBOutlet UITextField *accelerationXField;
@property (weak, nonatomic) IBOutlet UITextField *accelerationYField;
@property (weak, nonatomic) IBOutlet UITextField *accelerationZField;

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
    
    for (int i=0; i<[constants.coordinates count]; i++) {
        [self.weights addObject:[NSNumber numberWithFloat:0.0f]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifications:)
                                                 name:@"parsedData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifications:)
                                                 name:@"disconnectedFromBean"
                                               object:nil];
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
    self.heatMap = [LFHeatMap heatMapWithRect:self.view.frame boost:[self.boost floatValue] points:constants.coordinates weights:self.weights];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) handleNotifications:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"parsedData"]) {
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
        }
        self.heatMap = [LFHeatMap heatMapWithRect:self.view.frame boost:1.0f points:constants.coordinates weights:self.weights];
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
            if (voltage > 0.10) {
                [self.weights replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:voltage]];
            } else {
                [self.weights replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:0.0f]];
            }
        }
        self.heatMap = [LFHeatMap heatMapWithRect:self.view.frame boost:[self.boost floatValue] points:constants.coordinates weights:self.weights weightsAdjustmentEnabled:NO groupingEnabled:YES];
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
