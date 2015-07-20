//
//  HistoryTableViewController.m
//  BioWear
//
//  Created by David Jeong on 2015. 6. 21..
//
//

#import "BWHistoryTableViewController.h"

@interface BWHistoryTableViewController ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (assign, nonatomic) NSUInteger toolbarHeight;
@property (assign, nonatomic) NSUInteger datePickerHeight;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *endButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BWHistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.toolbarHeight = 44;
    self.datePickerHeight = 216;
    
    self.endDate = [NSDate date];
    // Default start date is 24 hours of previous date
    self.startDate = [self.endDate dateByAddingTimeInterval:-24*60*60];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *startTimeString = [self.dateFormatter stringFromDate:self.startDate];
    NSString *endTimeString = [self.dateFormatter stringFromDate:self.endDate];
    [self.startButton setTitle:startTimeString forState:UIControlStateNormal];
    [self.endButton setTitle:endTimeString forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)changeStartDate:(UIDatePicker *)sender {
    self.startDate = sender.date;
    NSString *startTimeString = [self.dateFormatter stringFromDate:sender.date];
    [self.startButton setTitle:startTimeString forState:UIControlStateNormal];
    NSLog(@"Start date changed to %@", startTimeString);
}

- (void)changeEndDate:(UIDatePicker *)sender {
    self.endDate = sender.date;
    NSString *endTimeString = [self.dateFormatter stringFromDate:sender.date];
    [self.endButton setTitle:endTimeString forState:UIControlStateNormal];
    NSLog(@"End date changed to %@", endTimeString);
}

- (void)removeAllViews:(id)object {
    // Remove all objects from view.
    [[self.view viewWithTag:1] removeFromSuperview];
    [[self.view viewWithTag:2] removeFromSuperview];
    [[self.view viewWithTag:3] removeFromSuperview];
}

- (void)dismiss:(id)sender {
    // Dismiss the date picker.
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.toolbarHeight);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height + self.toolbarHeight, self.view.bounds.size.width, self.datePickerHeight);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:1].alpha = 0;
    [self.view viewWithTag:2].frame = datePickerTargetFrame;
    [self.view viewWithTag:3].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeAllViews:)];
    [UIView commitAnimations];
}

- (IBAction)setStartTime:(id)sender {
    if ([self.view viewWithTag:1]) {
        return;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.tag = 1;
    UITapGestureRecognizer *dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [view addGestureRecognizer:dismissGesture];
    [self.view addSubview:view];
    
    // Create a temporary toolbar to contain done button.
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.toolbarHeight)];
    toolbar.tag = 2;
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
    [toolbar setItems:[NSArray arrayWithObjects:space, doneButton, nil]];
    [self.view addSubview:toolbar];
    
    // Configure the date picker.
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height + self.toolbarHeight, self.view.bounds.size.width, self.datePickerHeight)];
    datePicker.tag = 3;
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    [datePicker setDate:self.startDate];
    [datePicker addTarget:self action:@selector(changeStartDate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height - self.datePickerHeight - self.toolbarHeight, self.view.bounds.size.width, self.toolbarHeight);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height - self.datePickerHeight, self.view.bounds.size.width, self.datePickerHeight);
    
    // Set frames and commit animations.
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolbar.frame = toolbarTargetFrame;
    datePicker.frame = datePickerTargetFrame;
    [UIView commitAnimations];
}

- (IBAction)setEndTime:(id)sender {
    if ([self.view viewWithTag:1]) {
        return;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.tag = 1;
    UITapGestureRecognizer *dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [view addGestureRecognizer:dismissGesture];
    [self.view addSubview:view];
    
    // Create a temporary toolbar to contain done button.
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.toolbarHeight)];
    toolbar.tag = 2;
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
    [toolbar setItems:[NSArray arrayWithObjects:space, doneButton, nil]];
    [self.view addSubview:toolbar];
    
    // Configure the date picker.
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height + self.toolbarHeight, self.view.bounds.size.width, self.datePickerHeight)];
    datePicker.tag = 3;
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    [datePicker setDate:self.endDate];
    [datePicker addTarget:self action:@selector(changeEndDate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height - self.datePickerHeight - self.toolbarHeight, self.view.bounds.size.width, self.toolbarHeight);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height - self.datePickerHeight, self.view.bounds.size.width, self.datePickerHeight);
    
    // Set frames and commit animations.
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolbar.frame = toolbarTargetFrame;
    datePicker.frame = datePickerTargetFrame;
    [UIView commitAnimations];
}

@end
