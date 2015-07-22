//
//  InformationViewController.h
//  BioWear
//
//  Created by David Jeong on 2015. 6. 22..
//
//

#import <UIKit/UIKit.h>

@interface BWInformationViewController : UIViewController <UISearchBarDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>

- (IBAction)unwindToInformationController:(UIStoryboardSegue *)segue;

@end
