//
//  HistoryGraphViewController.h
//  BioWear
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface BWHistoryGraphViewController : UIViewController <CPTPlotDataSource>

@property (strong, nonatomic) CPTGraphHostingView *hostView;
@property (assign, nonatomic) NSUInteger numberOfPoints;

@end