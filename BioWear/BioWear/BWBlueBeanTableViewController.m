//
//  BWBlueBeanTableViewController.m
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import "BWBlueBeanTableViewController.h"

#import "BWBlueBean.h"
#import "BWBlueBeanConnector.h"
#import "BWBlueBeanTableViewCell.h"

@interface BWBlueBeanTableViewController ()

@end

@implementation BWBlueBeanTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    connector.beanManager.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    [connector.beans removeAllObjects];
    [connector.beanManager startScanningForBeans_error:nil];
    [self.tableView reloadData];
}

#pragma mark - PTDBeanManagerDelegate

- (void)beanManagerDidUpdateState:(PTDBeanManager *)beanManager {
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    if (connector.beanManager.state == BeanManagerState_PoweredOn) {
        [connector.beans removeAllObjects];
        [connector.beanManager startScanningForBeans_error:nil];
    } else if (connector.beanManager.state == BeanManagerState_PoweredOff) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate date];
        localNotification.alertBody = @"The application requires bluetooth permissions.";
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
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
    
    // Set the bean variable to this bean.
    BWBlueBean *blueBean = [BWBlueBean bean];
    blueBean.bean = bean;
    blueBean.beanName = bean.name;
    blueBean.bean.delegate = connector;
    
    [blueBean.bean readArduinoSketchInfo];
    if ([blueBean.bean sketchName] == nil) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate date];
        localNotification.alertBody = @"The bean has no program.";
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectedToBean" object:nil];
    // Bean has been connected, go back to previous.
    [self performSegueWithIdentifier:@"unwindToSettingsController" sender:self];
}

- (void)beanManager:(PTDBeanManager *)beanManager didDisconnectBean:(PTDBean *)bean error:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectedFromBean" object:nil];
    
    // Fire a notification to alert user.
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate date];
    localNotification.alertBody = @"The shoe has been disconnected.";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    // Remove all objects from dict and re-scan.
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    [connector.beans removeAllObjects];
    [connector.beanManager startScanningForBeans_error:nil];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    PTDBean *bean = [connector.beans.allValues objectAtIndex:indexPath.row];
    BWBlueBeanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"beanCell"];
    cell.bean = bean;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    return [connector.beans count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    PTDBean *bean = [connector.beans.allValues objectAtIndex:indexPath.row];
    if (bean.state == BeanState_Discovered) {
        // If state is discovered, try to establish connection.
        [connector.beanManager connectToBean:bean error:nil];
    }
    [self.tableView reloadData];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    PTDBean *bean = [connector.beans.allValues objectAtIndex:indexPath.row];
    // Only allow left to disconnect on connected beans.
    if (bean.state == BeanState_ConnectedAndValidated) {
        UITableViewRowAction *disconnectAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Disconnect" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [connector.beanManager disconnectBean:bean error:nil];
            BWBlueBean *blueBean = [BWBlueBean bean];
            blueBean.bean = nil;
            blueBean.beanName = @"";
        }];
        return @[disconnectAction];
    }
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BWBlueBeanConnector *connector = [BWBlueBeanConnector connector];
    PTDBean *bean = [connector.beans.allValues objectAtIndex:indexPath.row];
    // Only allow left to disconnect on connected beans.
    if (bean.state == BeanState_ConnectedAndValidated) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
