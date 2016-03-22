//
//  DSAboutViewController.m
//  DrStep
//
//  Created by Juhwan Jeong on 3/21/16.
//
//

#import "DSAboutViewController.h"

@interface DSAboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation DSAboutViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"txt"];
    NSString *description = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    self.descriptionLabel.text = description;
}

@end
