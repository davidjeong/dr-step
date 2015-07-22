//
//  BWInformationDetailViewController.m
//  BioWear
//
//  Created by Juhwan Jeong on 2015. 7. 21..
//
//

#import "BWInformationDetailViewController.h"

#import "BWSymptom.h"

@interface BWInformationDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *scientificLabel;
@property (weak, nonatomic) IBOutlet UILabel *commonLabel;
@property (weak, nonatomic) IBOutlet UITextView *symptomDescriptionTextView;

@end

@implementation BWInformationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.scientificLabel setText:[self.symptom scientificName]];
    [self.commonLabel setText:[self.symptom commonName]];
    [self.symptomDescriptionTextView setText:[self.symptom symptomDescription]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
