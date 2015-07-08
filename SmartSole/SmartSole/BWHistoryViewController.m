//
//  HistoryViewController.m
//  SmartSole
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import "HistoryViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create the necessary arrays.
    self.instances = @[@"HistoryTableViewController", @"HistoryGraphViewController", @"InformationViewController"];
    
    // Create HistoryGraphViewController.
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    HistoryTableViewController *tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.instances[0]];
    HistoryGraphViewController *graphViewController;
    InformationViewController *informationViewController;
    NSArray *viewControllers = [NSArray arrayWithObjects:tableViewController, graphViewController, informationViewController, nil];
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

#pragma mark - History View Controller
// Return the controller at previous index.
- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[InformationViewController class]]) {
        HistoryGraphViewController *graphViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.instances[1]];
        return graphViewController;
    } else if ([viewController isKindOfClass:[HistoryGraphViewController class]]) {
        HistoryTableViewController *tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.instances[0]];
        return tableViewController;
    } else return nil;
}


// Return the controller at next index.
- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[HistoryTableViewController class]]) {
        HistoryGraphViewController *graphViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.instances[1]];
        return graphViewController;
    } else if ([viewController isKindOfClass:[HistoryGraphViewController class]]) {
        InformationViewController *informationViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.instances[2]];
        return informationViewController;
    } else return nil;
}

- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.instances count];
}

- (NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end
