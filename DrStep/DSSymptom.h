//
//  DSSymptom.h
//  Dr. Step
//
//  Created by Juhwan Jeong on 2015. 7. 21..
//
//

#import <Foundation/Foundation.h>

@interface DSSymptom : NSObject

@property (strong, nonatomic) NSString *scientificName;
@property (strong, nonatomic) NSString *commonName;
@property (strong, nonatomic) NSString *symptomDescription;
@property (strong, nonatomic) NSString *diagnosis;

@end
