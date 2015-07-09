//
//  SettingsTableViewController.m
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import "BWSettingsTableViewController.h"

@interface BWSettingsTableViewController ()

@end

@implementation BWSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && indexPath.section == 0) {
        [self performSegueWithIdentifier:@"showConnector" sender:self];
    }
}

@end
