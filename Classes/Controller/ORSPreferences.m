//
//  ORSPreferences.m
//  Canary
//
//  Created by Νικόλαος Τουμπέλης on 08/06/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ORSPreferences.h"

@implementation ORSPreferences

@synthesize defaults, twitterEngine, cacheManager;

- (id) init {
	self = [super init];
	if (self != nil) {
		defaults = [NSUserDefaults standardUserDefaults];
		twitterEngine = [ORSTwitterEngine sharedTwitterEngine];
		cacheManager = [[ORSTimelineCacheManager alloc] init];
	}
	return self;
}


// Returns the id of the last received direct message since last execution
- (NSString *) receivedDMIDSinceLastExecution {
	NSDictionary *lastReceivedDMIDs;
	if (lastReceivedDMIDs = 
		[defaults dictionaryForKey:@"CanaryLastReceivedDMID"]) {
		NSString *messageID;
		if (messageID = [lastReceivedDMIDs 
						 valueForKey:twitterEngine.sessionUserID]) {
			return messageID;
		} else {
			return NULL;
		}
	} else {
		return NULL;
	}
}

// Returns the last status id shown
- (NSString *) statusIDSinceLastExecution {
	NSDictionary *lastFollowingStatusIDs;
	if (lastFollowingStatusIDs = 
		[defaults dictionaryForKey:@"CanaryLastFollowingStatusID"]) {
		NSString *statusID;
		if (statusID = [lastFollowingStatusIDs 
						valueForKey:twitterEngine.sessionUserID]) {
			return statusID;
		} else {
			return NULL;
		}
	} else {
		return NULL;
	}
}

// Returns whether Canary is set to retrieve all updates since last execution
- (BOOL) willRetrieveAllUpdates {
	return [defaults boolForKey:@"CanaryWillRetrieveAllUpdates"];
}

// Returns the selected URL shortener
- (int) selectedURLShortener {
	NSString *selectedURLShortener = (NSString *)[defaults 
												  objectForKey:@"CanarySelectedURLShortener"];
	if ([selectedURLShortener isEqualToString:@"Adjix"])
		return ORSAdjixShortenerType;
	else if ([selectedURLShortener isEqualToString:@"Bit.ly"])
		return ORSBitlyShortenerType;
	else if ([selectedURLShortener isEqualToString:@"Cli.gs"])
		return ORSCligsShortenerType;
	else if ([selectedURLShortener isEqualToString:@"Is.gd"])
		return ORSIsgdShortenerType;
	else if ([selectedURLShortener isEqualToString:@"SnipURL"])
		return ORSSnipURLShortenerType;
	else if ([selectedURLShortener isEqualToString:@"TinyURL"])
		return ORSTinyURLShortenerType;
	else if ([selectedURLShortener isEqualToString:@"tr.im"])
		return ORSTrimShortenerType;
	else
		return ORSUrlborgShortenerType;
}

// Returns the number of number of updates kept in the timeline
- (NSUInteger) maxShownUpdates {
	NSString *maxShownUpdatesString = (NSString *)[defaults 
												   objectForKey:@"CanaryMaxShownUpdates"];
	// code to compensate for old preferences
	if (maxShownUpdatesString.integerValue != 40 &&
		maxShownUpdatesString.integerValue != 80 &&
		maxShownUpdatesString.integerValue != 120 &&
		maxShownUpdatesString.integerValue != 160) {
		return 80;
	} else {
		return maxShownUpdatesString.integerValue;
	}
}

// Returns the refresh rate selected by the user.
- (float) timelineRefreshPeriod {
	NSString *timelineRefreshPeriodString = (NSString *)[defaults 
														 objectForKey:@"CanaryRefreshPeriod"];
	if ([timelineRefreshPeriodString isEqualToString:@"Manually"] ||
		[timelineRefreshPeriodString isEqualToString:@"Manuell"])
		return -1.0;
	else if ([timelineRefreshPeriodString isEqualToString:@"Every minute"] ||
			 [timelineRefreshPeriodString isEqualToString:@"Minütlich"])
		return 60.0;
	else if ([timelineRefreshPeriodString isEqualToString:@"Every two minutes"] ||
			 [timelineRefreshPeriodString isEqualToString:@"Alle zwei Minuten"])
		return 120.0;
	else if ([timelineRefreshPeriodString isEqualToString:@"Every three minutes"] ||
			 [timelineRefreshPeriodString isEqualToString:@"Alle drei Minuten"])
		return 180.0;
	else if ([timelineRefreshPeriodString isEqualToString:@"Every five minutes"] ||
			 [timelineRefreshPeriodString isEqualToString:@"Alle fünf Minuten"])
		return 300.0;
	else if ([timelineRefreshPeriodString isEqualToString:@"Every ten minutes"] ||
			 [timelineRefreshPeriodString isEqualToString:@"Alle zehn Minuten"])
		return 600.0;
	else
		return -1.0;
}

// Saves the last IDs in the user preferences when called
- (void) saveLastIDs {
	NSMutableDictionary *followingStatusIDs, *lastReceivedDMIDs;
	if (cacheManager.lastFollowingStatusID != NULL &&
		cacheManager.lastFollowingStatusID != @"" &&
		cacheManager.lastFollowingStatusID != nil) {
		if (followingStatusIDs = [NSMutableDictionary dictionaryWithDictionary:
								  [defaults dictionaryForKey:@"CanaryLastFollowingStatusID"]]) {
			if (twitterEngine.sessionUserID != nil) {
				[followingStatusIDs setValue:cacheManager.lastFollowingStatusID 
									  forKey:twitterEngine.sessionUserID];
				[defaults setObject:followingStatusIDs 
							 forKey:@"CanaryLastFollowingStatusID"];
			}
		} else {
			followingStatusIDs = [NSMutableDictionary dictionaryWithCapacity:1];
			[followingStatusIDs setValue:cacheManager.lastFollowingStatusID 
								  forKey:twitterEngine.sessionUserID];
			[defaults setObject:followingStatusIDs 
						 forKey:@"CanaryLastFollowingStatusID"];
		}
	}
	if (cacheManager.lastReceivedMessageID != NULL &&
		cacheManager.lastReceivedMessageID != @"" &&
		cacheManager.lastReceivedMessageID != @" " &&
		cacheManager.lastReceivedMessageID != nil) {
		if (lastReceivedDMIDs = [NSMutableDictionary dictionaryWithDictionary:
								 [defaults dictionaryForKey:@"CanaryLastReceivedDMID"]]) {
			if (twitterEngine.sessionUserID != nil) {
				[lastReceivedDMIDs setValue:cacheManager.lastReceivedMessageID 
									 forKey:twitterEngine.sessionUserID];
				[defaults setObject:lastReceivedDMIDs 
							 forKey:@"CanaryLastReceivedDMID"];
			}
		} else {
			lastReceivedDMIDs = [NSMutableDictionary dictionaryWithCapacity:1];
			[lastReceivedDMIDs setValue:cacheManager.lastReceivedMessageID 
								 forKey:twitterEngine.sessionUserID];
			[defaults setObject:lastReceivedDMIDs 
						 forKey:@"CanaryLastReceivedDMID"];
		}
	}
}

@end
