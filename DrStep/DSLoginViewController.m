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
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UIButton *fbLoginButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@end

@implementation DSLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    self.companyLabel.text = [NSString stringWithFormat:@"\u00A9Dr. Step %@", yearString];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Clear the fields.
    self.errorLabel.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Tap Gesture

- (IBAction)tapRecognized:(id)sender {
    [self.view endEditing:YES];
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

@end
