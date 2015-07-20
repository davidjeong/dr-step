//
//  SettingsTableViewController.m
//  BioWear
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import "BWSettingsTableViewController.h"

#import "BWBlueBean.h"
#import "BWBlueBeanConnector.h"
#import "BWBlueBeanTableViewController.h"

@interface BWSettingsTableViewController ()

@end

@implementation BWSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifications:)
                                                 name:@"connectedToBean"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifications:)
                                                 name:@"disconnectedFromBean"
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) handleNotifications:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"connectedToBean"]) {
        [self.tableView reloadData];
    } else if ([notification.name isEqualToString:@"disconnectedFromBean"]){
        [self.tableView reloadData];
    }
}

//- (void)changePasscode {
//    BWBlueBean *blueBean = [BWBlueBean bean];
//    if (blueBean.bean != nil && blueBean.bean.state == BeanState_ConnectedAndValidated) {
//        NSLog(@"Starting passcode changer");
//        UIAlertView *passcodeView = [[UIAlertView alloc] initWithTitle:@"Change Passcode" message:@"Enter the new passcode" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
//        passcodeView.alertViewStyle = UIAlertViewStylePlainTextInput;
//        UITextField *textField = [passcodeView textFieldAtIndex:0];
//        textField.keyboardType = UIKeyboardTypeNumberPad;
//        [passcodeView addButtonWithTitle:@"Ok"];
//        
//        [passcodeView show];
//    } else {
//        NSLog(@"Bean not connected, can't change passcode");
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Bean is not connected" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alertView show];
//    }
//}
//
//- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if ([alertView.title isEqual: @"Change Passcode"]) {
//        if (buttonIndex == 1) {
//            BWBlueBean *blueBean = [BWBlueBean bean];
//            NSUInteger *code = (NSUInteger *)[[alertView textFieldAtIndex:0].text integerValue];
//            BOOL success = [blueBean.bean setPairingPin:code];
//            NSLog(@"Changing the passcode: %d", success);
//        }
//    }
//}

#pragma mark - UITableViewDelegate

static NSString *cellIdentifier = @"settingsCell";

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        if(indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"connectivityCell"];
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"connectivityCell"];
            }
            [cell.textLabel setText:@"Connect to LightBlue bean"];
            BWBlueBean *blueBean = [BWBlueBean bean];
            if (blueBean.isConnected) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            } else {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
    }
    else if(indexPath.section == 1) {
        if (indexPath.row == 0) {
            //Just to demonstrate the tableview is returning the correct type of cell from the XIB
            cell = [tableView dequeueReusableCellWithIdentifier:@"configurationCell"];
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"configurationCell"];
            }
            [cell.textLabel setText:@"Change passcode"];
        }
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"showConnector" sender:self];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //[self changePasscode];
        }
    }
}

@end
