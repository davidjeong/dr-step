//
//  DSDataParser.h
//  Dr. Step
//
//  Created by David Jeong on 2015. 7. 8..
//
//  This is a singleton class to parse data into dictionary.
//

#import <Foundation/Foundation.h>
#import <PTDBean.h>
#import <PTDBeanManager.h>

@interface DSDataParser : NSObject

- (void) processJSONIntoDictionary:(NSString *) jsonString;

@end
