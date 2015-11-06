//
//  DSBlueBeanTableViewController.m
//  Dr. Step
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import "DSBlueBeanTableViewController.h"

#import "DSAppConstants.h"
#import "DSBlueBeanConnector.h"
#import "DSBlueBeanTableViewCell.h"

@interface DSBlueBeanTableViewController ()

@end

@implementation DSBlueBeanTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DSBlueBeanConnector *connector = [DSBlueBeanConnector connector];
    connector.beanManager.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DSBlueBeanConnector *connector = [DSBlueBeanConnector connector];
    [connector.beans removeAllObjects];
    [connector.beanManager startScanningForBeans_error:nil];
    [self.tableView reloadData];
}

#pragma mark - PTDBeanManagerDelegate

- (void)beanManagerDidUpdateState:(PTDBeanManager *)beanManager {
    DSBlueBeanConnector *connector = [DSBlueBeanConnector connector];
    if (connector.beanManager.state == BeanManagerState_PoweredOn) {
        [connector.beans removeAllObjects];
        [connector.beanManager startScanningForBeans_error:nil];
    } else if (connector.beanManager.state == BeanManagerState_PoweredOff) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"The application requires bluetooth permissions." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:alertAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
}

- (void)beanManager:(PTDBeanManager *)beanManager didDiscoverBean:(PTDBean *)bean error:(NSError *)error {
    DSBlueBeanConnector *connector = [DSBlueBeanConnector connector];
    NSUUID *key = bean.identifier;
    if (![connector.beans objectForKey:key]) {
        // This means new bean.
        NSLog(@"Adding new bean to dictionary %@", bean);
        [connector.beans setObject:bean forKey:key];
    }
    [self.tableView reloadData];
}

- (void)beanManager:(PTDBeanManager *)beanManager didConnectBean:(PTDBean *)bean error:(NSError *)error {
    DSBlueBeanConnector *connector = [DSBlueBeanConnector connector];
    if (error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Error" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:alertAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    [connector.beanManager stopScanningForBeans_error:&error];
    if (error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Error" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:alertAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    // Set the bean variable to this bean.
    DSAppConstants *constants = [DSAppConstants constants];
    [constants setBean:bean];
    [[constants bean] setDelegate:connector];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectedToBean" object:nil];
    // Bean has been connected, go back to previous.
    [self performSegueWithIdentifier:@"unwindToSettingsController" sender:self];
}

- (void)beanManager:(PTDBeanManager *)beanManager didDisconnectBean:(PTDBean *)bean error:(NSError *)error {
    // Fire a notification to alert user.
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate date];
    localNotification.alertBody = @"The shoe has been disconnected.";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    DSAppConstants *constants = [DSAppConstants constants];
    constants.bean = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectedFromBean" object:nil];
    
    // Remove all objects from dict and re-scan.
    DSBlueBeanConnector *connector = [DSBlueBeanConnector connector];
    [connector.beans removeAllObjects];
    [connector.beanManager startScanningForBeans_error:nil];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DSBlueBeanConnector *connector = [DSBlueBeanConnector connector];
    PTDBean *bean = [connector.beans.allValues objectAtIndex:indexPath.row];
    DSBlueBeanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"beanCell"];
    cell.bean = bean;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DSBlueBeanConnector *connector = [DSBlueBeanConnector connector];
    return [connector.beans count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DSBlueBeanConnector *connector = [DSBlueBeanConnector connector];
    PTDBean *bean = [connector.beans.allValues objectAtIndex:indexPath.row];
    if (bean.state == BeanState_Discovered) {
        // If state is discovered, try to establish connection.
        [connector.beanManager connectToBean:bean error:nil];
    }
    [self.tableView reloadData];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    DSBlueBeanConnector *connector = [DSBlueBeanConnector connector];
    PTDBean *bean = [connector.beans.allValues objectAtIndex:indexPath.row];
    // Only allow left to disconnect on connected beans.
    if (bean.state == BeanState_ConnectedAndValidated) {
        UITableViewRowAction *disconnectAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Disconnect" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [connector.beanManager disconnectBean:bean error:nil];
        }];
        return @[disconnectAction];
    }
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    DSBlueBeanConnector *connector = [DSBlueBeanConnector connector];
    PTDBean *bean = nil;
    if ([connector.beans count] != 0) {
        bean = [connector.beans.allValues objectAtIndex:indexPath.row];
    }
    // Only allow left to disconnect on connected beans.
    if (bean != nil && bean.state == BeanState_ConnectedAndValidated) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
