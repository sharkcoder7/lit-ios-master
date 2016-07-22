//
//  LITGlobals.h
//  lit-ios
//
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef LITGlobals_h
#define LITGlobals_h

static NSInteger const kLITheightMainDifference                     = 65;
static NSInteger const kLITheightKeyboardDifference                 = 100;
static NSInteger const kLITheightCellDifference                     = 100;

static NSInteger const kLITheightContentFeedFooter                  = 45;

static NSString * const kLITnotificationTutorialDismissed           = @"LITnotificationTutorialDismissed";
static NSString * const kLITnotificationMainCoachDismissed          = @"LITnotificationMainCoachDismissed";
static NSString * const kLITnotificationKeyboardCoachDismissed      = @"LITnotificationKeyboardCoachDismissed";
static NSString * const kLITnotificationCellCoachDismissed          = @"LITnotificationCellCoachDismissed";
static NSString * const kLITnotificationSingleTapCoachDismissed     = @"LITnotificationSingleTapCoachDismissed";
static NSString * const kLITnotificationLongPressCoachDismissed     = @"LITnotificationLongPressCoachDismissed";
static NSString * const kLITnotificationNeedContentCoach            = @"LITnotificationNeedContentCoach";
static NSString * const kLITnotificationContentCoachDismissed       = @"LITnotificationContentCoachDismissed";


static NSString *const kLITAddedContentToKeyboardNotificationName   = @"LITAddedContentToKeyboardNotification";

typedef enum
{
    LITKeyboard_Lyric = 0,
    LITKeyboard_SoundBit,
    LITKeyboard_Dub,
    LITKeyboard_Emoji,
    LITKeyboard_Favorite,
    LITKeyboard_Installed,
    LITKeyboard_Search
} LITKeyboard_Type;

#endif /* LITGlobals_h */
