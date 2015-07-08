//
//  HistoryViewController.h
//  BioWear
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import <UIKit/UIKit.h>
#import "BWHistoryGraphViewController.h"
#import "BWHistoryTableViewController.h"
#import "BWInformationViewController.h"

@interface BWHistoryViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *instances;
@property (assign, nonatomic) NSUInteger index;

@end

