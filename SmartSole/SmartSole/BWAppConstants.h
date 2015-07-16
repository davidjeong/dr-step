//
//  BWAppConstants.h
//  BioWear
//
//  Created by Juhwan Jeong on 2015. 7. 16..
//
//  Global constants file.

#ifndef BioWear_BWAppConstants_h

// static const.
static NSString* const commaDelim = @",";
static NSString* const EOM = @"EOM";
static const NSUInteger numberOfSensors = 12;
static NSString* const separatorDelim = @":";
static NSString* const statusBattery = @"battery_";

// static mutable.
static BOOL notifiedLowBattery = NO;
static NSArray* currentDataList;

#define BioWear_BWAppConstants_h
#endif
