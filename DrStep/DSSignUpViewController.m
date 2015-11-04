//
//  DSSignUpViewController.m
//  DrStep
//
//  Created by Juhwan Jeong on 2015. 11. 3..
//
//

#import "DSSignUpViewController.h"

#import <Parse/Parse.h>

@interface DSSignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderControl;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation DSSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Programatically set the background color.
    [self.view setBackgroundColor:[UIColor colorWithRed:255/255.0f green:246/255.0f blue:233/255.0f alpha:1.0f]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Clear the fields.
    self.nameField.text = @"";
    self.emailField.text = @"";
    self.passwordField.text = @"";
    self.confirmPasswordField.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tap Gesture

- (IBAction)tapRecognized:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - Button Actions
- (IBAction)goBackToLoginScreen:(id)sender {
}

- (IBAction)createAccount:(id)sender {
    // Validate textfields first.
    if (!self.nameField.text || self.nameField.text.length == 0) {
        self.errorLabel.text = @"Please enter a valid name";
        return;
    }
    if (!self.emailField.text || self.emailField.text.length == 0) {
        self.errorLabel.text = @"Please enter a valid email address";
        return;
    }
    NSRange range = [self.emailField.text rangeOfString:@"@"];
    if (range.length == 0) {
        self.errorLabel.text = @"Please enter a valid email address";
        return;
    }
    if (!self.passwordField.text || !self.confirmPasswordField.text || self.passwordField.text.length == 0 || self.confirmPasswordField.text.length == 0) {
        self.errorLabel.text = @"Please enter a valid password";
        return;
    }
    if (self.passwordField.text != self.confirmPasswordField.text) {
        self.errorLabel.text = @"Passwords do not match";
        return;
    }
    // Check if user exists in database already.
    PFQuery *query = [PFUser query];
    [query whereKey:@"email" equalTo:self.emailField.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error in checking if existing user or not");
        }
        if (objects.count == 0) {
            // Create the new user.
            PFUser *currentUser = [PFUser user];
            BOOL isMale = self.genderControl.selectedSegmentIndex == 0;
            [currentUser setObject:self.nameField.text forKey:@"name"];
            [currentUser setObject:self.emailField.text forKey:@"username"];
            [currentUser setObject:self.emailField.text forKey:@"email"];
            [currentUser setObject:self.passwordField.text forKey:@"password"];
            [currentUser setObject:[NSNumber numberWithBool:isMale] forKey:@"isMale"];
            [currentUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"Error while trying to save new data");
                }
                if (succeeded) {
                    [self performSegueWithIdentifier:@"signUpSegue" sender:self];
                }
            }];
            
            NSLog(@"New user created with name:%@, email:%@", self.nameField.text, self.emailField.text);
        } else {
            self.errorLabel.text = @"User with email already exists";
        }
    }];
}

@end
