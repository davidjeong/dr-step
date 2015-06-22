//
//  HistoryTableViewController.h
//  SmartSole
//
//  Created by David Jeong on 2015. 6. 21..
//
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewController : UIViewController

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (assign, nonatomic) NSUInteger toolbarHeight;
@property (assign, nonatomic) NSUInteger datePickerHeight;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *endButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)setStartTime:(id)sender;
- (IBAction)setEndTime:(id)sender;

@end
