//
//  SettingsTableViewController.h
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import <UIKit/UIKit.h>
#import <PTDBean.h>

#import "BWBlueBeanConnector.h"
#import "BWBlueBeanTableViewController.h"

@interface BWSettingsTableViewController : UITableViewController <UIAlertViewDelegate,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *connectLabel;
@property (weak, nonatomic) IBOutlet UILabel *passcodeLabel;



@end
