//
//  SettingsTableViewController.h
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import <UIKit/UIKit.h>

#import "BWBlueBeanConnector.h"
#import "BWBlueBeanTableViewController.h"

@interface BWSettingsTableViewController : UITableViewController <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *connectLabel;

@end
