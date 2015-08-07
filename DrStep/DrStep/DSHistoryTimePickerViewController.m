//
//  DSHistoryTimePickerViewController.m
//  DrStep
//
//  Created by Juhwan Jeong on 2015. 8. 6..
//
//

#import "DSHistoryTimePickerViewController.h"
#import "DSHistoryTimeViewController.h"

@interface DSHistoryTimePickerViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;

@end

@implementation DSHistoryTimePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.startDatePicker setDate:self.startDate];
    [self.endDatePicker setDate:self.endDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    NSInteger index = [self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController];
    
    DSHistoryTimeViewController *viewController = (DSHistoryTimeViewController *)[self.navigationController.viewControllers objectAtIndex:index];
    viewController.startDate = [self.startDatePicker date];
    viewController.endDate = [self.endDatePicker date];
}

@end
