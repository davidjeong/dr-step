//
//  BWBlueBeanTableViewController.m
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import "BWBlueBeanTableViewController.h"

@interface BWBlueBeanTableViewController ()

@end

@implementation BWBlueBeanTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    connector.beanManager.delegate = self;
    
    // Create a pull-down refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor orangeColor];
    [self.refreshControl addTarget:self action:@selector(refreshAllData) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void) refreshAllData {
    [self.tableView reloadData];
    NSLog(@"Table data refreshed.");
    if (self.refreshControl) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm:ss a"];
        NSString *title = [NSString stringWithFormat:@"Last refresh at %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[UIColor orangeColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:dictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

- (PTDBean *)beanForRow:(NSInteger)row {
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    return [connector.beans.allValues objectAtIndex:row];
}

#pragma mark - PTDBeanManagerDelegate

- (void)beanManagerDidUpdateState:(PTDBeanManager *)beanManager {
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    if (connector.beanManager.state == BeanManagerState_PoweredOn) {
        [connector.beanManager startScanningForBeans_error:nil];
    } else if (connector.beanManager.state == BeanManagerState_PoweredOff) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The application requires bluetooth permissions." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
}

- (void)beanManager:(PTDBeanManager *)beanManager didDiscoverBean:(PTDBean *)bean error:(NSError *)error {
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];

    NSUUID *key = bean.identifier;
    if (![connector.beans objectForKey:key]) {
        // This means new bean.
        NSLog(@"Adding new bean to dictionary %@", bean);
        [connector.beans setObject:bean forKey:key];
    }
    [self.tableView reloadData];
}

- (void)beanManager:(PTDBeanManager *)beanManager didConnectBean:(PTDBean *)bean error:(NSError *)error {
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
    
    [connector.beanManager stopScanningForBeans_error:&error];
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
    [self.tableView reloadData];
    // Bean has been connected, go back to previous.
}

- (void)beanManager:(PTDBeanManager *)beanManager didDisconnectBean:(PTDBean *)bean error:(NSError *)error {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

static NSString *cellIdentifier = @"beanCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    PTDBean *bean = [connector.beans.allValues objectAtIndex:indexPath.row];
    BWBlueBeanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.bean = bean;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    return connector.beans.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    PTDBean *bean = [connector.beans.allValues objectAtIndex:indexPath.row];
    if (bean.state == BeanState_Discovered) {
        // If state is discovered, try to establish connection.
        [connector.beanManager connectToBean:bean error:nil];
        BWBlueBean *blueBean = [BWBlueBean bean];
        blueBean.bean = bean;
        blueBean.beanName = bean.name;
        blueBean.bean.delegate = connector;
    } else {
        // Else, try to disconnect.
        
    }
    [self.tableView reloadData];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    PTDBean *bean = [connector.beans.allValues objectAtIndex:indexPath.row];
    // Only allow left to disconnect on connected beans.
    if (bean.state == BeanState_ConnectedAndValidated) {
        UITableViewRowAction *disconnectAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Disconnect" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [connector.beanManager disconnectBean:bean error:nil];
            BWBlueBean *blueBean = [BWBlueBean bean];
            blueBean.bean = nil;
            blueBean.beanName = @"";
        }];
        return @[disconnectAction];
    }
    return nil;
}

@end
