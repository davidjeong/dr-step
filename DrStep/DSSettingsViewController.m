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
#import "DSBlueBeanConnector.h"
#import "DSBlueBeanTableViewController.h"
#import "DSLoginViewController.h"

@interface DSSettingsViewController ()

@property (nonatomic, strong) UISlider *boostSlider;
@property (nonatomic, strong) UISlider *fontSlider;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;

@end

@implementation DSSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view setBackgroundColor:[UIColor colorWithRed:255/255.0f green:246/255.0f blue:233/255.0f alpha:1.0f]];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:255/255.0f green:246/255.0f blue:233/255.0f alpha:1.0f]];
    
    self.boostSlider = [[UISlider alloc] init];
    [self.boostSlider setMinimumValue:0.0f];
    [self.boostSlider setMaximumValue:1.0f];
    
    DSAppConstants *constants = [DSAppConstants constants];
    [self.boostSlider setValue:[constants.heatMapBoost floatValue]];
    
    [self.boostSlider addTarget:self action:@selector(updateBoost:) forControlEvents:UIControlEventValueChanged];
    
    self.fontSlider = [[UISlider alloc] init];
    [self.fontSlider setMinimumValue:12.0f];
    [self.fontSlider setMaximumValue:18.0f];
    [self.fontSlider setValue:15.0f];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifications:)
                                                 name:@"connectedToBean"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotifications:)
                                                 name:@"disconnectedFromBean"
                                               object:nil];
    
    PFUser *currentUser = [PFUser currentUser];
    PFFile *file = currentUser[@"profilePhoto"];
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.layer.borderWidth = 5.0f;
    self.profileImageView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.profileImageView.layer.masksToBounds = YES;
    if (file == nil) {
        self.profileImageView.userInteractionEnabled = YES;
        self.profileImageView.image = [UIImage imageNamed:@"empty_profile_pic"];
    } else {
        [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            self.profileImageView.image = [UIImage imageWithData:imageData];

        }];
    }
    
    self.nameLabel.text = currentUser[@"name"];
    self.emailLabel.text = currentUser[@"email"];
    BOOL isMale = currentUser[@"isMale"];
    if (isMale) {
        self.genderLabel.text = @"Male";
    } else {
        self.genderLabel.text = @"Female";
    }
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
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:cellIdentifier];
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
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:cellIdentifier];
            }
            DSAppConstants *constants = [DSAppConstants constants];
            [self.boostSlider setValue:[constants.heatMapBoost floatValue]];
            [cell setAccessoryView:self.boostSlider];
            [cell.textLabel setText:[NSString stringWithFormat:@"Adjust Heatmap Boost - %.02f", [constants.heatMapBoost floatValue]]];
        }
    } else if (indexPath.section == 2) { // Application
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            [cell.textLabel setText:@"Log Out"];
            [cell.textLabel setTextColor:[UIColor redColor]];
        }
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
        [cell setUserInteractionEnabled:NO];
    }
    cell.backgroundColor = [UIColor colorWithRed:255/255.0f green:228/255.0f blue:188/255.0f alpha:1.0f];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Currently each setting has one row.
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure you want to sign out?" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [self _logout];
                DSLoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DSLoginViewController"];
                [self presentViewController:loginViewController animated:YES completion:nil];
            }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:confirmAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

#pragma mark - UI Events

- (IBAction)updateBoost:(UISlider *)sender{
    DSAppConstants *constants = [DSAppConstants constants];
    [constants setHeatMapBoost:[NSNumber numberWithFloat:sender.value]];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    
    // Get main thread to update the text.
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.textLabel setText:[NSString stringWithFormat:@"Adjust Heatmap Boost - %.02f", [constants.heatMapBoost floatValue]]];
    });
}

- (IBAction)profilePhotoTapped:(id)sender {
    NSLog(@"Photo touched");
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData* imageData = UIImageJPEGRepresentation(image, 1.0f);
    PFFile *imageFile = [PFFile fileWithName:@"profile_image.png" data:imageData];
    self.profileImageView.image = image;
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:imageFile forKey:@"profilePhoto"];
    [currentUser saveInBackground];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Logout

- (void) _logout {
    // Sign out of Parse.
    [PFUser logOut];
}

#pragma mark - Segue

- (IBAction)unwindToSettingsController:(UIStoryboardSegue *)segue {
}

@end
