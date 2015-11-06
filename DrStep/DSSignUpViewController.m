//
//  DSSignUpViewController.m
//  DrStep
//
//  Created by Juhwan Jeong on 2015. 11. 3..
//
//

#import "DSSignUpViewController.h"

#import <Parse/Parse.h>

#import "DSLoginViewController.h"

@interface DSSignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@end

@implementation DSSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set delegate to self.
    self.nameField.delegate = self;
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.confirmPasswordField.delegate = self;
    
    self.createButton.layer.cornerRadius = self.createButton.frame.size.height / 2;
    
    [self navigationItem].leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStylePlain target:self action:@selector(goToLogin:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Clear the fields.
    self.nameField.text = @"";
    self.emailField.text = @"";
    self.passwordField.text = @"";
    self.confirmPasswordField.text = @"";
    self.errorLabel.text = @"";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tap Gesture

- (IBAction)tapRecognized:(id)sender {
    [self.view endEditing:YES];
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
    if (![self.passwordField.text isEqualToString:self.confirmPasswordField.text]) {
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
            [currentUser setObject:self.nameField.text forKey:@"name"];
            [currentUser setObject:self.emailField.text forKey:@"username"];
            [currentUser setObject:self.emailField.text forKey:@"email"];
            [currentUser setObject:self.passwordField.text forKey:@"password"];
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

#pragma mark - Segue
- (IBAction)goToLogin:(id)sender {
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    
    [[self navigationController].view.layer addAnimation:transition forKey:kCATransition];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DSLoginViewController *destinationViewController = (DSLoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DSLoginViewController"];
    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    
    [viewControllers replaceObjectAtIndex:0 withObject:destinationViewController];
    [[self navigationController] setViewControllers:viewControllers];
}

@end
