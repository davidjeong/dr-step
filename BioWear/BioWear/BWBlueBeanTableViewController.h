//
//  BWBlueBeanTableViewController.h
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import <UIKit/UIKit.h>
#import <PTDBeanManager.h>

@interface BWBlueBeanTableViewController : UITableViewController <PTDBeanManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@end