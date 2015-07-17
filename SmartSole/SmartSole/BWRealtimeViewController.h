//
//  RealtimeViewController.h
//  BioWear
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import <UIKit/UIKit.h>

#import "BWAppConstants.h"
#import "BWCoordinate.h"

@interface BWRealtimeViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *currentGraphicsData;

@property (strong, nonatomic) IBOutlet UIImageView *baseImage;

@end

