//
//  HistoryViewController.h
//  SmartSole
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import <UIKit/UIKit.h>
#import "HistoryContentViewController.h"

@interface HistoryViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@end

