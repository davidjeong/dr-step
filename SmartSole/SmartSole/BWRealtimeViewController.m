//
//  RealtimeViewController.m
//  BioWear
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import "BWRealtimeViewController.h"

@interface BWRealtimeViewController ()

@end

@implementation BWRealtimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"demo_feet_image.png"];
    [self.baseImage setImage:image];
    
    self.currentGraphicsData = [[NSMutableArray alloc] init];
    BWAppConstants *constants = [BWAppConstants constants];
    NSLog(@"%lu", [constants.sensorCoordinates count]);
    for (int i = 0; i < constants.sensorCoordinates.count; i++) {
        BWCoordinate *coordinate = [constants.sensorCoordinates objectAtIndex:i];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        CGPoint point = CGPointMake(coordinate.x, coordinate.y);
        shapeLayer.path = [[self makeShape:point radius:circleRadius index:i] CGPath];
        shapeLayer.strokeColor = [[UIColor orangeColor] CGColor];
        shapeLayer.fillColor = [[UIColor orangeColor] CGColor];
        shapeLayer.lineWidth = 1.0;
        [shapeLayer setOpacity:0.0];
        
        [self.view.layer addSublayer:shapeLayer];
        [self.currentGraphicsData addObject:shapeLayer];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"finishedProcessingData"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        for (int i=0; i<self.currentGraphicsData.count; i++) {
            // Calculate new opacity
            float newOpacity = [[array objectAtIndex:i] floatValue] / maximumVoltage;
            
            // Remove old layer, and put new layer.
            dispatch_async(dispatch_get_main_queue(), ^ {
                NSLog(@"Dispatching concurrent thread to run animation.");
                CAShapeLayer *currentLayer = [self.currentGraphicsData objectAtIndex:i];
                
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                animation.duration = 0.01;
                animation.fromValue = [NSNumber numberWithFloat:[currentLayer opacity]];
                animation.toValue = [NSNumber numberWithFloat:newOpacity];
                
                [currentLayer addAnimation:animation forKey:@"animation"];
                [currentLayer setOpacity:newOpacity];
                NSLog(@"Concurrent thread finished animation.");
            });
        }
    NSLog(@"Exiting processing graphics.");
}

@end
