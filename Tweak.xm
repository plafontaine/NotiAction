/*
* Special thanks to UnlockEvents, which basically gave me all of the Activator code
* The GitHub page can be found here: https://github.com/uroboro/UnlockEvents
*/

#define settingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.sunnybat.notiaction.plist"]
#import <libactivator/libactivator.h>

/***********************
*   CLASS VARIABLES   *
***********************/

static BOOL DEBUG = NO;
static BOOL SUPPRESS = NO;

static NSString* notificationID = @"com.sunnybat.notiaction.notification.match";
static NSString* WILDCARD = [NSString stringWithFormat:@"%@%@", @"%", @"%"]; // Hacked-together Strings, woohoo
static BOOL isEnabled = NO;
static BOOL caseSensitive = NO;
static NSString* notiString1;
static NSString* notiString2;
static NSString* notiString3;
static NSString* notiString4;
static NSString* notiString5;
static NSString* notiString6;
static NSString* notiString7;
static NSString* notiString8;
static NSString* notiString9;
static NSString* notiString10;
static NSString* notiString11;
static NSString* notiString12;
static NSString* notiString13;
static NSString* notiString14;
static NSString* notiString15;
static NSString* notiString16;
static NSString* notiString17;
static NSString* notiString18;
static NSString* notiString19;
static NSString* notiString20;
static NSString* notiString21;
static NSString* notiString22;
static NSString* notiString23;
static NSString* notiString24;
static NSString* notiString25;
static NSString* notiString26;
static NSString* notiString27;
static NSString* notiString28;
static NSString* notiString29;
static NSString* notiString30;
// Hacked-together workaround for ignoring BBBulletins created for Notification Center. It'll work!
static BOOL hasInit = NO;

// Hacked-together workaround for me being lazy and not wanting to create dynamic Preferences
// or learn new Objective-C stuff right now =/
static BOOL doSuppress = NO;

/*********************
*   CLASS METHODS   *
*********************/

static void debugMessage(NSString* msg) {
   if (DEBUG) {
       NSLog(@"NotiAction: %@", msg);
   }
}

static void loadPreferences() {
   debugMessage(@"Loading prefs");
   NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
   isEnabled = [[prefs objectForKey:@"enabled"] boolValue];
   caseSensitive = [[prefs objectForKey:@"casesensitive"] boolValue];
   notiString1 = [prefs objectForKey:@"notiString1"];
   notiString2 = [prefs objectForKey:@"notiString2"];
   notiString3 = [prefs objectForKey:@"notiString3"];
   notiString4 = [prefs objectForKey:@"notiString4"];
   notiString5 = [prefs objectForKey:@"notiString5"];
   notiString6 = [prefs objectForKey:@"notiString6"];
   notiString7 = [prefs objectForKey:@"notiString7"];
   notiString8 = [prefs objectForKey:@"notiString8"];
   notiString9 = [prefs objectForKey:@"notiString9"];
   notiString10 = [prefs objectForKey:@"notiString10"];
       notiString9 = [prefs objectForKey:@"notiString11"];
       notiString9 = [prefs objectForKey:@"notiString12"];
       notiString9 = [prefs objectForKey:@"notiString13"];
       notiString9 = [prefs objectForKey:@"notiString14"];
       notiString9 = [prefs objectForKey:@"notiString15"];
       notiString9 = [prefs objectForKey:@"notiString16"];
       notiString9 = [prefs objectForKey:@"notiString17"];
       notiString9 = [prefs objectForKey:@"notiString18"];
       notiString9 = [prefs objectForKey:@"notiString19"];
       notiString9 = [prefs objectForKey:@"notiString20"];
       notiString9 = [prefs objectForKey:@"notiString21"];
       notiString9 = [prefs objectForKey:@"notiString22"];
       notiString9 = [prefs objectForKey:@"notiString23"];
       notiString9 = [prefs objectForKey:@"notiString24"];
       notiString9 = [prefs objectForKey:@"notiString25"];
       notiString9 = [prefs objectForKey:@"notiString26"];
       notiString9 = [prefs objectForKey:@"notiString27"];
       notiString9 = [prefs objectForKey:@"notiString28"];
       notiString9 = [prefs objectForKey:@"notiString29"];
       notiString9 = [prefs objectForKey:@"notiString30"];
   DEBUG = [[prefs objectForKey:@"debugsyslog"] boolValue];
   SUPPRESS = [[prefs objectForKey:@"suppressnotifications"] boolValue];
}

// Ripped straight from UnlockEvents, no shame
static inline LAEvent *LASendEventWithName(NSString *eventName) {
   LAEvent *event = [LAEvent eventWithName:eventName mode:[LASharedActivator currentEventMode]];
   [LASharedActivator sendEventToListener:event];
   return event;
}

static BOOL hasKeyword(NSString* toCheck, NSString* keyword) {
   if (keyword != nil && [keyword length] > 0) {
       if (!caseSensitive) {
           toCheck = [toCheck lowercaseString];
           keyword = [keyword lowercaseString];
       }
       NSString* currentString = toCheck;
       NSArray* keywordArray = [keyword componentsSeparatedByString:WILDCARD]; // Split up keyword into array filtered by wildcard
       //NSLog(@"Array: %@", keywordArray);
       keywordArray = [keywordArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];

       // Check notification start/end text -- if keyword doesn't have wildcard at start/end, check the text
       if (![keyword hasPrefix:WILDCARD]) {
           debugMessage(@"Prefix: Notification doesn't have wildcard");
           if (![currentString hasPrefix:keywordArray[0]]) {
               debugMessage(@"Prefix: Doesn't start with first word");
               return NO;
           }
       }
       if (![keyword hasSuffix:WILDCARD]) {
           debugMessage(@"Suffix: Notification doesn't have wildcard");
           if (![currentString hasSuffix:keywordArray[[keywordArray count] - 1]]) {
               debugMessage(@"Suffix: Doesn't start with first word");
               return NO;
           }
       }

       // Check to make sure notification contains all keywords
       for (NSString* keywordSplit in keywordArray) {
           debugMessage([NSString stringWithFormat:@"Iteration: Word=%@, String=%@", keywordSplit, currentString]);
           if (keywordSplit == nil || [keywordSplit length] == 0) {
               debugMessage(@"Invalid keywordSplit -- ignoring");
               continue;
           } else if (![currentString containsString:keywordSplit]) {
               debugMessage(@"Iteration: Does not contain word!");
               return NO;
           }
           // Lop off the keyword found
           NSRange keywordLocation = [currentString rangeOfString:keywordSplit];
           NSRange numberRange = NSMakeRange(keywordLocation.location + [keywordSplit length], [currentString length] - keywordLocation.location - [keywordSplit length]);
           currentString = [currentString substringWithRange:numberRange];
       }
       if ([currentString length] != 0 && ![keyword hasSuffix:WILDCARD]) {
           debugMessage([NSString stringWithFormat:@"currentString != 0, no suffix wildcard! currentString: %@", currentString]);
           return NO;
       }
       return YES;
   }
   return NO;
}

// Loaded when phone first loads
%ctor {
   loadPreferences();
}

/**********************
*   HOOKED METHODS   *
**********************/

%hook BBBulletin

- (id)init {
   debugMessage(@"Init found.");
   hasInit = YES;
   doSuppress = NO;
   return %orig;
}

- (id)message {
   id msg = %orig;
   if (isEnabled && hasInit) {
       NSString* desc = [msg description];
       debugMessage([NSString stringWithFormat:@"Notification Received: %@", desc]);
       if (hasKeyword(desc, notiString1)) {
           LASendEventWithName([NSString stringWithFormat:@"%@1", notificationID]);
           doSuppress = YES;
       }
       if (hasKeyword(desc, notiString2)) {
           LASendEventWithName([NSString stringWithFormat:@"%@2", notificationID]);
           doSuppress = YES;
       }
       if (hasKeyword(desc, notiString3)) {
           LASendEventWithName([NSString stringWithFormat:@"%@3", notificationID]);
           doSuppress = YES;
       }
       if (hasKeyword(desc, notiString4)) {
           LASendEventWithName([NSString stringWithFormat:@"%@4", notificationID]);
           doSuppress = YES;
       }
       if (hasKeyword(desc, notiString5)) {
           LASendEventWithName([NSString stringWithFormat:@"%@5", notificationID]);
           doSuppress = YES;
       }
       if (hasKeyword(desc, notiString6)) {
           LASendEventWithName([NSString stringWithFormat:@"%@6", notificationID]);
           doSuppress = YES;
       }
       if (hasKeyword(desc, notiString7)) {
           LASendEventWithName([NSString stringWithFormat:@"%@7", notificationID]);
           doSuppress = YES;
       }
       if (hasKeyword(desc, notiString8)) {
           LASendEventWithName([NSString stringWithFormat:@"%@8", notificationID]);
           doSuppress = YES;
       }
       if (hasKeyword(desc, notiString9)) {
           LASendEventWithName([NSString stringWithFormat:@"%@9", notificationID]);
           doSuppress = YES;
       }
       if (hasKeyword(desc, notiString10)) {
           LASendEventWithName([NSString stringWithFormat:@"%@10", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString11)) {
           LASendEventWithName([NSString stringWithFormat:@"%@11", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString12)) {
           LASendEventWithName([NSString stringWithFormat:@"%@12", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString13)) {
           LASendEventWithName([NSString stringWithFormat:@"%@13", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString14)) {
           LASendEventWithName([NSString stringWithFormat:@"%@14", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString15)) {
           LASendEventWithName([NSString stringWithFormat:@"%@15", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString16)) {
           LASendEventWithName([NSString stringWithFormat:@"%@16", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString17)) {
           LASendEventWithName([NSString stringWithFormat:@"%@17", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString18)) {
           LASendEventWithName([NSString stringWithFormat:@"%@18", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString19)) {
           LASendEventWithName([NSString stringWithFormat:@"%@19", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString20)) {
           LASendEventWithName([NSString stringWithFormat:@"%@20", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString21)) {
           LASendEventWithName([NSString stringWithFormat:@"%@21", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString22)) {
           LASendEventWithName([NSString stringWithFormat:@"%@22", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString23)) {
           LASendEventWithName([NSString stringWithFormat:@"%@23", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString24)) {
           LASendEventWithName([NSString stringWithFormat:@"%@24", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString25)) {
           LASendEventWithName([NSString stringWithFormat:@"%@25", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString26)) {
           LASendEventWithName([NSString stringWithFormat:@"%@26", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString27)) {
           LASendEventWithName([NSString stringWithFormat:@"%@27", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString28)) {
           LASendEventWithName([NSString stringWithFormat:@"%@28", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString29)) {
           LASendEventWithName([NSString stringWithFormat:@"%@29", notificationID]);
           doSuppress = YES;
       }
               if (hasKeyword(desc, notiString30)) {
           LASendEventWithName([NSString stringWithFormat:@"%@30", notificationID]);
           doSuppress = YES;
       }
   } else {
       debugMessage([NSString stringWithFormat:@"Not ready to process notification (%d, %d)", isEnabled, hasInit]);
   }
   hasInit = NO;
   return msg;
}

%end

%hook BBBehaviorOverride

- (BOOL)isActiveForDate:(id)arg1 {
   if (!doSuppress) {
       return NO;
   } else {
       return %orig;
   }
}

%end

/*****************
*   ACTIVATOR   *
*****************/

@interface NotiActionDataSource: NSObject <LAEventDataSource> {
}

@end

@implementation NotiActionDataSource
+ (id)sharedInstance {
   static id sharedInstance = nil;
   static dispatch_once_t token = 0;
   dispatch_once(&token, ^{
       sharedInstance = [self new];
   });
   return sharedInstance;
}

+ (void)load {
   [self sharedInstance];
}


- (id)init {
   if ((self = [super init]) && [LASharedActivator isRunningInsideSpringBoard]) {
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@1", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@2", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@3", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@4", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@5", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@6", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@7", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@8", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@9", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@10", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@11", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@12", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@13", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@14", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@15", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@16", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@17", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@18", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@19", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@20", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@21", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@22", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@23", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@24", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@25", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@26", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@27", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@28", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@29", notificationID]];
       [LASharedActivator registerEventDataSource:self forEventName:[NSString stringWithFormat:@"%@30", notificationID]];
   }
   return self;
}

- (void)dealloc {
   [LASharedActivator unregisterEventDataSourceWithEventName:notificationID];
   [super dealloc];
}

// Event Name
- (NSString *)localizedTitleForEventName:(NSString *)eventName {
   if ([eventName hasSuffix:@"30"]) {
          return [NSString stringWithFormat:@"NotiAction Match 30"]; // Such hacked-together
   } else {
       return [NSString stringWithFormat:@"NotiAction Match %c", [eventName characterAtIndex:[eventName length] - 1]];
   }
}

// Group Name
- (NSString *)localizedGroupForEventName:(NSString *)eventName {
   return @"NotiAction Events";
}

// Event Description
- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
   return @"Notification with specified keyword(s) found";
}

- (BOOL)eventWithNameIsHidden:(NSString *)eventName {
   if ([eventName hasSuffix:@"1"]) {
       return [notiString1 length] == 0;
   } else if ([eventName hasSuffix:@"2"]) {
       return [notiString2 length] == 0;
   } else if ([eventName hasSuffix:@"3"]) {
       return [notiString3 length] == 0;
   } else if ([eventName hasSuffix:@"4"]) {
       return [notiString4 length] == 0;
   } else if ([eventName hasSuffix:@"5"]) {
       return [notiString5 length] == 0;
   } else if ([eventName hasSuffix:@"6"]) {
       return [notiString6 length] == 0;
   } else if ([eventName hasSuffix:@"7"]) {
       return [notiString7 length] == 0;
   } else if ([eventName hasSuffix:@"8"]) {
       return [notiString8 length] == 0;
   } else if ([eventName hasSuffix:@"9"]) {
       return [notiString9 length] == 0;
   } else if ([eventName hasSuffix:@"10"]) {
       return [notiString10 length] == 0;
   } else if ([eventName hasSuffix:@"11"]) {
       return [notiString11 length] == 0;
   } else if ([eventName hasSuffix:@"12"]) {
       return [notiString12 length] == 0;
   } else if ([eventName hasSuffix:@"13"]) {
       return [notiString13 length] == 0;
   } else if ([eventName hasSuffix:@"14"]) {
       return [notiString14 length] == 0;
   } else if ([eventName hasSuffix:@"15"]) {
       return [notiString15 length] == 0;
   } else if ([eventName hasSuffix:@"16"]) {
       return [notiString16 length] == 0;
   } else if ([eventName hasSuffix:@"17"]) {
       return [notiString17 length] == 0;
   } else if ([eventName hasSuffix:@"18"]) {
       return [notiString18 length] == 0;
   } else if ([eventName hasSuffix:@"19"]) {
       return [notiString19 length] == 0;
   } else if ([eventName hasSuffix:@"20"]) {
       return [notiString20 length] == 0;
   } else if ([eventName hasSuffix:@"21"]) {
       return [notiString21 length] == 0;
   } else if ([eventName hasSuffix:@"22"]) {
       return [notiString22 length] == 0;
   } else if ([eventName hasSuffix:@"23"]) {
       return [notiString23 length] == 0;
   } else if ([eventName hasSuffix:@"24"]) {
       return [notiString24 length] == 0;
   } else if ([eventName hasSuffix:@"25"]) {
       return [notiString25 length] == 0;
   } else if ([eventName hasSuffix:@"26"]) {
       return [notiString26 length] == 0;
   } else if ([eventName hasSuffix:@"27"]) {
       return [notiString27 length] == 0;
   } else if ([eventName hasSuffix:@"28"]) {
       return [notiString28 length] == 0;
   } else if ([eventName hasSuffix:@"29"]) {
       return [notiString29 length] == 0;
   } else if ([eventName hasSuffix:@"30"]) {
       return [notiString30 length] == 0;
   }
   return NO;
}

- (BOOL)eventWithNameRequiresAssignment:(NSString *)eventName {
   return NO;
}
@end
