//
//  BWAppConstants.h
//  BioWear
//
//  Created by Juhwan Jeong on 2015. 7. 16..
//
//  Global constants file.

#ifndef BioWear_BWAppConstants_h

// static const.
static const NSUInteger circleRadius = 30;
static NSString* const commaDelim = @",";
static NSString* const EOM = @"EOM";
static const float maximumVoltage = 2.8;
static const NSUInteger numberOfSensors = 12;
static NSString* const separatorDelim = @":";
static NSString* const statusBattery = @"battery_";

// static mutable.
static BOOL notifiedLowBattery = NO;
static NSArray* sensorPositions;

#define BioWear_BWAppConstants_h
#endif
