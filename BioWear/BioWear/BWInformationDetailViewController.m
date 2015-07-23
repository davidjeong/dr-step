//
//  BWInformationDetailViewController.m
//  BioWear
//
//  Created by Juhwan Jeong on 2015. 7. 21..
//
//

#import "BWInformationDetailViewController.h"

#import "BWAppConstants.h"
#import "BWSymptom.h"

@interface BWInformationDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *scientificLabel;
@property (weak, nonatomic) IBOutlet UILabel *commonLabel;
@property (weak, nonatomic) IBOutlet UITextView *symptomDescriptionTextView;
@property (weak, nonatomic) IBOutlet UITextView *diagnosisTextView;

@end

@implementation BWInformationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.scientificLabel setText:[self.symptom scientificName]];
    [self.commonLabel setText:[self.symptom commonName]];
    [self.symptomDescriptionTextView setText:[self.symptom symptomDescription]];
    [self.diagnosisTextView setText:[self.symptom diagnosis]];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    BWAppConstants *constants = [BWAppConstants constants];
    [self.symptomDescriptionTextView setFont:[UIFont systemFontOfSize:[constants.infoFontSize integerValue]]];
    [self.diagnosisTextView setFont:[UIFont systemFontOfSize:[constants.infoFontSize integerValue]]];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end