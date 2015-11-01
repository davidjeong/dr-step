//
//  DSLoginViewController.m
//  DrStep
//
//  Created by Juhwan Jeong on 2015. 10. 31..
//
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>

#import <QuartzCore/QuartzCore.h>
#import "DSLoginViewController.h"

@interface DSLoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *fbLoginButton;
@end

@implementation DSLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Programatically set background button color to facebook color.
    [self.fbLoginButton.layer setBackgroundColor:[UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1.0].CGColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Facebook Login

- (IBAction)login:(id)sender {
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
            [self _loadData];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}

#pragma mark - Facebook Data

- (void)_loadData {
    
    // Create parameters
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,email" forKey:@"fields"];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *email = userData[@"email"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            // Now add the data to the UI elements
            PFUser *currentUser = [PFUser currentUser];
            [currentUser setObject:facebookID forKey:@"facebookId"];
            [currentUser setObject:name forKey:@"name"];
            [currentUser setObject:email forKey:@"email"];
            
            [currentUser saveInBackground];
        }
    }];
}

@end
