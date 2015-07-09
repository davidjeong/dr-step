//
//  BWBlueBeanTableViewController.h
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import <UIKit/UIKit.h>

#import "BWBlueBean.h"
#import "BWBlueBeanConnector.h"
#import "BWBlueBeanTableViewCell.h"

@interface BWBlueBeanTableViewController : UITableViewController <PTDBeanDelegate, PTDBeanManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) NSUInteger counter;

@end
