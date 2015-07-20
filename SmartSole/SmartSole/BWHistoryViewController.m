//
//  HistoryViewController.m
//  BioWear
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import "BWHistoryViewController.h"

#import "BWHistoryGraphViewController.h"
#import "BWHistoryTableViewController.h"
#import "BWInformationViewController.h"

@interface BWHistoryViewController ()

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *instances;
@property (assign, nonatomic) NSUInteger index;

@end

@implementation BWHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create the necessary arrays.
    self.instances = @[@"HistoryTableViewController", @"HistoryGraphViewController"];
    
    // Create HistoryGraphViewController.
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    BWHistoryTableViewController *tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.instances[0]];
    BWHistoryGraphViewController *graphViewController;
    NSArray *viewControllers = [NSArray arrayWithObjects:tableViewController, graphViewController, nil];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controlller.
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 40);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPageViewControllerDataSource

// Return the controller at previous index.
- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[BWHistoryGraphViewController class]]) {
        BWHistoryTableViewController *tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.instances[0]];
        return tableViewController;
    } else return nil;
}


// Return the controller at next index.
- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[BWHistoryTableViewController class]]) {
        BWHistoryGraphViewController *graphViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.instances[1]];
        return graphViewController;
    } else return nil;
}

- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.instances count];
}

- (NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end
