//
//  DSInformationDetailViewController.m
//  Dr. Step
//
//  Created by Juhwan Jeong on 2015. 7. 21..
//
//

#import "DSInformationDetailViewController.h"

#import "DSAppConstants.h"
#import "DSSymptom.h"

@interface DSInformationDetailViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *scientificLabel;
@property (weak, nonatomic) IBOutlet UILabel *commonLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *diagnosisLabel;
@property (strong, nonatomic) UIView *contentView;

@end

@implementation DSInformationDetailViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load the nib into scroll view.
    NSArray *views = [[NSBundle bundleForClass:[self class]] loadNibNamed:@"DSInformationDetailContentView" owner:self options:nil];
    self.contentView = [views firstObject];
    
    //[self.view addSubview:self.contentView];
    [self.scientificLabel setText:[self.symptom scientificName]];
    [self.commonLabel setText:[self.symptom commonName]];
    [self.descriptionLabel setText:[self.symptom symptomDescription]];
    [self.diagnosisLabel setText:[self.symptom diagnosis]];
    
    [self.scrollView addSubview:self.contentView];

}

- (void)viewDidLayoutSubviews {
    CGSize size = self.contentView.bounds.size;
    self.contentView.frame = CGRectMake(0, 0, size.width, size.height);
    self.scrollView.contentSize = size;
}

#pragma mark - IBAction

- (IBAction)touched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
