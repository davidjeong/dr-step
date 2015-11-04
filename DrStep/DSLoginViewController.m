//
//  DSLoginViewController.m
//  DrStep
//
//  Created by Juhwan Jeong on 2015. 10. 31..
//
//

#import "DSLoginViewController.h"

#import <Bolts/Bolts.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

@interface DSLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *fbLoginButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@end

@implementation DSLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Programatically set the background color.
    [self.view setBackgroundColor:[UIColor colorWithRed:255/255.0f green:246/255.0f blue:233/255.0f alpha:1.0f]];
    
    // Programatically set icon and background button color to facebook.
    [self.fbLoginButton.layer setBackgroundColor:[UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1.0].CGColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Clear the fields.
    self.usernameField.text = @"";
    self.passwordField.text = @"";
    self.errorLabel.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Tap Gesture

- (IBAction)tapRecognized:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - Normal Login

- (IBAction)loginApplication:(id)sender {
    [self _loginWithApplication];
}

- (void)_loginWithApplication {
    if (self.usernameField.text && self.passwordField.text && self.usernameField.text.length != 0 && self.passwordField.text.length != 0) {
        // Check if username/password combination is correct.
        [PFUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
            if (error) {
                self.errorLabel.text = @"Invalid credentials";
                NSLog(@"Error while trying to log in.");
                return;
            }
            if (user) {
                [self performSegueWithIdentifier:@"loginSegue" sender:self];
            }
        }];
    } else {
        self.errorLabel.text = @"Username or password is empty";
        NSLog(@"Username or password is empty.");
    }
}

#pragma mark - Facebook Login

- (IBAction)loginFacebook:(id)sender {
    [self _loginWithFacebook];
}

- (void)_loginWithFacebook {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[@"user_about_me", @"user_location", @"email"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else {
            NSLog(@"User logged in through Facebook!");
            [self _loadDataFromFacebook];
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
        }
    }];
}

#pragma mark - Facebook Data

- (void)_loadDataFromFacebook {
    
    // Create parameters
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,email,gender" forKey:@"fields"];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookId = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *email = userData[@"email"];
            
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookId]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            
            PFFile *imageFile = [PFFile fileWithName:@"profile_image.png" data:imageData];
            
            // Now add the data to the UI elements
            PFUser *currentUser = [PFUser currentUser];
            [currentUser setObject:facebookId forKey:@"facebookId"];
            [currentUser setObject:name forKey:@"name"];
            [currentUser setObject:email forKey:@"email"];
            [currentUser setObject:imageFile forKey:@"profilePhoto"];
            [currentUser saveInBackground];
        }
    }];
}

#pragma mark - Segue
- (IBAction)unwindToLoginViewController:(UIStoryboardSegue *)segue {
}

@end
