//
//  DSInformationDetailViewController.m
//  BioWear
//
//  Created by Juhwan Jeong on 2015. 7. 21..
//
//

#import "DSInformationDetailViewController.h"

#import "DSAppConstants.h"
#import "DSSymptom.h"

@interface DSInformationDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *scientificLabel;
@property (weak, nonatomic) IBOutlet UILabel *commonLabel;
@property (weak, nonatomic) IBOutlet UITextView *symptomDescriptionTextView;
@property (weak, nonatomic) IBOutlet UITextView *diagnosisTextView;

@end

@implementation DSInformationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.scientificLabel setText:[self.symptom scientificName]];
    [self.commonLabel setText:[self.symptom commonName]];
    [self.symptomDescriptionTextView setText:[self.symptom symptomDescription]];
    [self.diagnosisTextView setText:[self.symptom diagnosis]];
}

- (void)viewWillAppear:(BOOL)animated{
    DSAppConstants *constants = [DSAppConstants constants];
    [self.symptomDescriptionTextView setFont:[UIFont systemFontOfSize:[constants.infoFontSize integerValue]]];
    [self.diagnosisTextView setFont:[UIFont systemFontOfSize:[constants.infoFontSize integerValue]]];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
