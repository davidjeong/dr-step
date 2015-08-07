//
//  HistoryTimeViewController.m
//  Dr. Step
//
//  Created by David Jeong on 2015. 6. 21..
//
//

#import "DSHistoryTimeViewController.h"
#import "DSHistoryTimePickerViewController.h"

@interface DSHistoryTimeViewController ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation DSHistoryTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.endDate = [NSDate date];
    // Default start date is 24 hours of previous date
    self.startDate = [self.endDate dateByAddingTimeInterval:-24*60*60];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    NSMutableString *titleString = [[NSMutableString alloc] init];
    NSString *startString = [self.dateFormatter stringFromDate:self.startDate];
    NSString *endString = [self.dateFormatter stringFromDate:self.endDate];
    
    [titleString appendString:startString];
    [titleString appendString:@" - "];
    [titleString appendString:endString];
    [self.timeLabel setText:titleString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDatePicker"]) {
        DSHistoryTimePickerViewController *viewController = segue.destinationViewController;
        
        viewController.startDate = self.startDate;
        viewController.endDate = self.endDate;
    }
}

@end
