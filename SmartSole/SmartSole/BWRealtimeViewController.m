//
//  RealtimeViewController.m
//  BioWear
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import "BWRealtimeViewController.h"

#import "BWAppConstants.h"
#import "BWCoordinate.h"

@interface BWRealtimeViewController ()

@property (nonatomic, strong) NSMutableArray *currentGraphicsData;
@property (strong, nonatomic) IBOutlet UIImageView *baseImage;

@end

@implementation BWRealtimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"foot_image.png"];
    [self.baseImage setImage:image];
    
    self.currentGraphicsData = [[NSMutableArray alloc] init];
    BWAppConstants *constants = [BWAppConstants constants];
    for (int i = 0; i < constants.sensorCoordinates.count; i++) {
        BWCoordinate *coordinate = [constants.sensorCoordinates objectAtIndex:i];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        CGPoint point = CGPointMake(coordinate.x, coordinate.y);
        shapeLayer.path = [[self makeShape:point radius:circleRadius index:i] CGPath];
        shapeLayer.strokeColor = [[UIColor orangeColor] CGColor];
        shapeLayer.fillColor = [[UIColor yellowColor] CGColor];
        shapeLayer.lineWidth = 1.0;

        
        CATextLayer *textLayer = [[CATextLayer alloc] init];
        [textLayer setName:@"textLayer"];
        [textLayer setFont:@"Helvetica-Bold"];
        [textLayer setFontSize:10];
        [textLayer setFrame:CGRectMake(point.x - 20, point.y - 5, 40, 10)];
        [textLayer setString:@"0.00V"];
        [textLayer setAlignmentMode:kCAAlignmentCenter];
        [textLayer setForegroundColor:[[UIColor darkTextColor] CGColor]];
        [textLayer setContentsScale:[[UIScreen mainScreen] scale]];
        [shapeLayer addSublayer:textLayer];
        
        [self.currentGraphicsData addObject:shapeLayer];
        
        if (coordinate.x == 0 && coordinate.y == 0) continue;
        [self.view.layer addSublayer:shapeLayer];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"finishedProcessingData"
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIBezierPath *)makeShape:(CGPoint)location radius:(CGFloat)radius index:(NSUInteger)index
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:location
                    radius:radius
                startAngle:0.0
                  endAngle:M_PI * 2.0
                 clockwise:YES];
    
    return path;
}

- (void) receivedNotification:(NSNotification *)notification {
    NSLog(@"Spawning new serial thread");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        if ([[notification name] isEqualToString:@"finishedProcessingData"]) {
            [self processGraphics:[notification object]];
        }
    });
}

- (void)processGraphics:(NSMutableArray*)array {
    NSLog(@"Processing graphics");
    BWAppConstants *constants = [BWAppConstants constants];
    float diff = 255;
    for (int i=0; i<constants.sensorCoordinates.count; i++) {
        BWCoordinate *coordinate = [constants.sensorCoordinates objectAtIndex:i];
        if (coordinate.x == 0 && coordinate.y == 0) continue;
        // Calculate new opacity
        float voltage = [[array objectAtIndex:i] floatValue];
        float intensity = voltage / maximumVoltage;
        // Remove old layer, and put new layer.
        dispatch_async(dispatch_get_main_queue(), ^ {
            NSLog(@"Dispatching concurrent thread to run animation.");
            CAShapeLayer *currentLayer = [self.currentGraphicsData objectAtIndex:i];
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
            animation.duration = 0.01;
            UIColor *toColor = [UIColor colorWithRed:1.0 green:(255-diff*intensity)/255 blue:0.0 alpha:1.0];
            animation.fromValue = (id) [currentLayer fillColor];
            animation.toValue = (id) toColor.CGColor;
            
            // Set the text in textLayer
            // TODO Need to test
            CATextLayer *textLayer = nil;
            for (CATextLayer *layer in [currentLayer sublayers]) {
                if ([[layer name] isEqualToString:@"textLayer"]) {
                    textLayer = layer;
                }
            }
            if (textLayer != nil) {
                [textLayer setString:[NSString stringWithFormat:@"%.02fV", voltage]];
            }
            [currentLayer addAnimation:animation forKey:@"animation"];
            [currentLayer setFillColor:toColor.CGColor];
            NSLog(@"Concurrent thread finished animation.");
        });
    }
    NSLog(@"Exiting processing graphics.");
}

@end
