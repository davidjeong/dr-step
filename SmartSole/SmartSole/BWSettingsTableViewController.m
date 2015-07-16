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
    
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

#pragma mark - UITableViewDataSource

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
