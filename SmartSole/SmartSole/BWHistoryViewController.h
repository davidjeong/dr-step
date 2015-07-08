//
//  HistoryViewController.h
//  SmartSole
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import <UIKit/UIKit.h>
#import "HistoryGraphViewController.h"
#import "HistoryTableViewController.h"
#import "InformationViewController.h"

@interface HistoryViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *instances;
@property (assign, nonatomic) NSUInteger index;

@end

