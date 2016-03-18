//
//  SettingsTableViewController.m
//  Dr. Step
//
//  Created by David Jeong on 2015. 7. 8..
//
//

#import "DSSettingsViewController.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <QuartzCore/QuartzCore.h>

#import "DSAppConstants.h"
#import "DSBlueBeanTableViewController.h"
#import "DSLoginViewController.h"
#import "DSProfileCell.h"

@interface DSSettingsViewController ()

@property (nonatomic, strong) UISlider *boostSlider;

@end

@implementation DSSettingsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.boostSlider = [[UISlider alloc] init];
    [self.boostSlider setMinimumValue:0.0f];
    [self.boostSlider setMaximumValue:1.0f];
    
    [self.boostSlider addTarget:self action:@selector(updateBoost:) forControlEvents:UIControlEventValueChanged];
    
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Save settings for later
    PFQuery *query = [PFQuery queryWithClassName:@"Setting"];
    [query fromLocalDatastore];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *setting, NSError *error) {
        if (error) {
            NSLog(@"Error while trying to get settings.");
        } else {
            setting[@"heatMapBoost"] = [NSNumber numberWithFloat:self.boostSlider.value];
            [setting pinInBackground];
        }
    }];
    DSAppConstants *constants = [DSAppConstants constants];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:constants.settings];
    dict[@"heatMapBoost"] = [NSNumber numberWithFloat:self.boostSlider.value];
    constants.settings = [NSDictionary dictionaryWithDictionary:dict];
}

#pragma mark - UITableViewDelegate

static NSString *profileCellIdentifier = @"profileCell";
static NSString *settingCellIdentifier = @"settingCell";

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"Connectivity";
    } else if (section == 2) {
        return @"Application";
    } else if (section == 3) {
        return @"Other";
    }
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *settingCell = nil;
    if (indexPath.section == 0) { // Profile
        DSProfileCell *profileCell = nil;
        if (indexPath.row == 0) {
            profileCell = [tableView dequeueReusableCellWithIdentifier:profileCellIdentifier];
            if (profileCell == nil) {
                profileCell = [[DSProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:profileCellIdentifier];
            }
            PFUser *currentUser = [PFUser currentUser];
            profileCell.name = currentUser[@"name"];
            profileCell.email = currentUser[@"email"];
            DSAppConstants *constants = [DSAppConstants constants];
            profileCell.profileImage = constants.profileImage;
        }
        profileCell.userInteractionEnabled = NO;
        return profileCell;
    }
    else if (indexPath.section == 1) { // Connectivity
        if(indexPath.row == 0) {
            settingCell = [tableView dequeueReusableCellWithIdentifier:settingCellIdentifier];
            if (settingCell == nil) {
                settingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:settingCellIdentifier];
            }
            [settingCell.textLabel setText:@"Connect To The Shoe"];
            DSAppConstants *constants = [DSAppConstants constants];
            if (constants.bean != nil) {
                [settingCell setAccessoryType:UITableViewCellAccessoryCheckmark];
            } else {
                [settingCell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
    }
    else if(indexPath.section == 2) { // Configuration
        if (indexPath.row == 0) {
            settingCell = [tableView dequeueReusableCellWithIdentifier:settingCellIdentifier];
            if (settingCell == nil) {
                settingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:settingCellIdentifier];
            }
            [settingCell setAccessoryView:self.boostSlider];
            DSAppConstants *constants = [DSAppConstants constants];
            NSDictionary *settings = constants.settings;
            self.boostSlider.value = [settings[@"heatMapBoost"] floatValue];
            [settingCell.textLabel setText:[NSString stringWithFormat:@"Adjust Heatmap Boost - %.02f", self.boostSlider.value]];
        }
    } else if (indexPath.section == 3) { // Application
        if (indexPath.row == 0) {
            settingCell = [tableView dequeueReusableCellWithIdentifier:settingCellIdentifier];
            if (settingCell == nil) {
                settingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:settingCellIdentifier];
            }
            [settingCell.textLabel setText:@"About Us"];
            [settingCell.textLabel setTextColor:[UIColor colorWithRed:76/255.0f green:190/255.0f blue:160/255.0f alpha:1.0f]];
        }
        else if (indexPath.row == 1) {
            settingCell = [tableView dequeueReusableCellWithIdentifier:settingCellIdentifier];
            if (settingCell == nil) {
                settingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:settingCellIdentifier];
            }
            [settingCell.textLabel setText:@"Third Party Libraries"];
            [settingCell.textLabel setTextColor:[UIColor colorWithRed:76/255.0f green:190/255.0f blue:160/255.0f alpha:1.0f]];
        }
        else if (indexPath.row == 2) {
            settingCell = [tableView dequeueReusableCellWithIdentifier:settingCellIdentifier];
            if (settingCell == nil) {
                settingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:settingCellIdentifier];
            }
            [settingCell.textLabel setText:@"Log Out"];
            [settingCell.textLabel setTextColor:[UIColor redColor]];
        }
    }
    if (settingCell == nil) {
        settingCell = [[UITableViewCell alloc] init];
        [settingCell setUserInteractionEnabled:NO];
    }
    return settingCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Currently each setting has one row.
    if (section == 3) return 3;
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"showConnector" sender:self];
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            // Show about
        }
        else if (indexPath.row == 1) {
            // Show copyright
            [self performSegueWithIdentifier:@"showCopyright" sender:self];
        }
        else if (indexPath.row == 2) {
            DSAppConstants *constants = [DSAppConstants constants];
            if (constants.bean != nil) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Please disconnect the bean before logging out." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:alertAction];
                [self presentViewController:alertController animated:YES completion:nil];
                return;
            }
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure you want to sign out?" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [self _logout];
                [self performSegueWithIdentifier:@"logoutSegue" sender:self];
            }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:confirmAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 200;
    }
    return [self.tableView rowHeight];
}

#pragma mark - IBAction

- (IBAction)updateBoost:(UISlider *)sender{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    
    // Get main thread to update the text.
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.textLabel setText:[NSString stringWithFormat:@"Adjust Heatmap Boost - %.02f", sender.value]];
    });
}

- (IBAction)unwindToSettingsController:(UIStoryboardSegue *)segue {
    [self.tableView reloadData];
}

#pragma mark - Local Notifications

- (void) handleNotifications:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"connectedToBean"]) {
        [self.tableView reloadData];
    } else if ([notification.name isEqualToString:@"disconnectedFromBean"]){
        
        [self.tableView reloadData];
    }
}

#pragma mark - Private

- (void) _logout {
    // Sign out of Parse.
    [PFUser logOut];
}

@end
