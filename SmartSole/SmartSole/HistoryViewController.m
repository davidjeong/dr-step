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
    _pageTitles = @[@"Tabular Format", @"Chart Format", @"Detailed Information"];
    _pageImages = @[@"page1.png", @"page2.png", @"page3.png"];
    
    // Create historyContentViewController.
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    HistoryContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
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

- (HistoryContentViewController*) viewControllerAtIndex:(NSUInteger) index {
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Initialize the HistoryContentViewController at index and return.
    HistoryContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.labelText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

#pragma mark - History Content View Controller

// Return the controller at previous index.
- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((HistoryContentViewController*) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
        
    index--;
    return [self viewControllerAtIndex:index];
}


// Return the controller at next index.
- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((HistoryContentViewController*) viewController).pageIndex;
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

@end
