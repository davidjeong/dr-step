//
//  BWBlueBeanTableViewController.h
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import <UIKit/UIKit.h>

#import "BWBlueBeanConnector.h"
#import "BWBlueBeanTableViewCell.h"

@interface BWBlueBeanTableViewController : UITableViewController <PTDBeanManagerDelegate, PTDBeanDelegate, UITableViewDataSource, UITableViewDelegate>

@end
