//
//  SettingsTableViewController.m
//  Dr. Step
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import "DSSettingsTableViewController.h"
#import "DSAppConstants.h"
#import "DSBlueBeanConnector.h"
#import "DSBlueBeanTableViewController.h"

@interface DSSettingsTableViewController ()

@property (nonatomic, strong) UISlider *boostSlider;
@property (nonatomic, strong) UISlider *fontSlider;

@end

@implementation DSSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    
    self.boostSlider = [[UISlider alloc] init];
    [self.boostSlider setMinimumValue:0.0f];
    [self.boostSlider setMaximumValue:1.0f];
    
    DSAppConstants *constants = [DSAppConstants constants];
    [self.boostSlider setValue:[constants.heatMapBoost floatValue]];
    
    [self.boostSlider addTarget:self action:@selector(updateBoost:) forControlEvents:UIControlEventValueChanged];
    
    self.fontSlider = [[UISlider alloc] init];
    [self.fontSlider setMinimumValue:12.0f];
    [self.fontSlider setMaximumValue:18.0f];
    [self.fontSlider setValue:[constants.infoFontSize floatValue]];
    
    [self.fontSlider addTarget:self action:@selector(updateFont:) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifications:)
                                                 name:@"connectedToBean"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifications:)
                                                 name:@"disconnectedFromBean"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
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

#pragma mark - UITableViewDelegate

static NSString *cellIdentifier = @"settingsCell";

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) { // Connectivity
        if(indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"connectivityCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"connectivityCell"];
            }
            [cell.textLabel setText:@"Connect To The Shoe"];
            DSAppConstants *constants = [DSAppConstants constants];
            if (constants.bean != nil) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            } else {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
    }
    else if(indexPath.section == 1) { // Configuration
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"configurationCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"configurationCell"];
            }
            DSAppConstants *constants = [DSAppConstants constants];
            [self.boostSlider setValue:[constants.heatMapBoost floatValue]];
            [cell setAccessoryView:self.boostSlider];
            [cell.textLabel setText:[NSString stringWithFormat:@"Adjust Heatmap Boost - %.02f", [constants.heatMapBoost floatValue]]];
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"configurationCell"];
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"configurationCell"];
            }
            DSAppConstants *constants = [DSAppConstants constants];
            [self.fontSlider setValue:[constants.infoFontSize floatValue]];
            [cell setAccessoryView:self.fontSlider];
            [cell.textLabel setText:[NSString stringWithFormat:@"Adjust Font Size - %d", [constants.infoFontSize intValue]]];

        }
    } else if (indexPath.section == 2) { // Application
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"applicationCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"applicationCell"];
            }
            [cell.textLabel setText:@"Logout from Facebook"];
            [cell.textLabel setTextColor:[UIColor redColor]];
        }
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
        [cell setUserInteractionEnabled:NO];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    else if (section == 1) return 2;
    else return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"showConnector" sender:self];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //[self changePasscode];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Account Logout" message:@"Are you sure you want to logout?" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self _logoutFacebook];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
            
            [alertController addAction:confirmAction];
            [alertController addAction:cancelAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (IBAction)updateBoost:(UISlider *)sender{
    DSAppConstants *constants = [DSAppConstants constants];
    [constants setHeatMapBoost:[NSNumber numberWithFloat:sender.value]];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    
    // Get main thread to update the text.
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.textLabel setText:[NSString stringWithFormat:@"Adjust Heatmap Boost - %.02f", [constants.heatMapBoost floatValue]]];
    });
}

- (IBAction)updateFont:(UISlider *)sender{
    DSAppConstants *constants = [DSAppConstants constants];
    [constants setInfoFontSize:[NSNumber numberWithInt:round(sender.value)]];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    
    // Get main thread to update the text.
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.textLabel setText:[NSString stringWithFormat:@"Adjust Font Size - %d", [constants.infoFontSize intValue]]];
    });
}

#pragma mark - Facebook Logout

- (void) _logoutFacebook {
    [PFUser logOut];
    // Load Login/Signup View Controller
    UIViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DSLoginViewController"];
    [loginViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    
    // For some reason, this has to be done in a separate queue.
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self presentViewController:loginViewController animated:YES completion:nil];
    });
}

#pragma mark - Unwind Segue

- (IBAction)unwindToSettingsController:(UIStoryboardSegue *)segue {
}

@end
