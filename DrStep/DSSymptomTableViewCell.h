//
//  DSSymptomTableViewCell.h
//  Dr. Step
//
//  Created by Juhwan Jeong on 2015. 7. 21..
//
//

#import <UIKit/UIKit.h>
#import "DSSymptom.h"

@interface DSSymptomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *scientificName;
@property (weak, nonatomic) IBOutlet UILabel *commonName;

@property (strong, nonatomic) DSSymptom *symptom;

@end
