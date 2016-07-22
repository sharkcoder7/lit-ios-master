//
//  LITEmojiUtils.m
//  lit-ios
//
//  Copyright (c) 2015 Lit Inc. All rights reserved.
//

#import "LITEmojiUtils.h"

#import <NgEmojiMap/NgEmojiMap.h>

@implementation LITEmojiUtils

+ (NSArray *)allEmojis {
    
    NSMutableArray *emojiArray = [NSMutableArray array];
    
    
    // Page 1
    
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"princess"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"wine_glass"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"doughnut"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"innocent"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"fearful"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"confused"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"us"]];
    
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"speak_no_evil"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"see_no_evil"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"hear_no_evil"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"laughing"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"smiling_imp"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"blush"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"smirk"]];
    
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"sweat"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"relaxed"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"neutral_face"]];
    
    // Page 2
    
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"joy"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"heart"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"smile"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"shit"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"dancer"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"unamused"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"kissing_heart"]];
    
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"ok_hand"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"grin"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"information_desk_person"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"blush"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"sob"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"flushed"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"thumbsup"]];
    
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"thumbsdown"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"heart_eyes"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"wink"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"yum"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"sleeping"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"clap"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"rage"]];
    
    // Page 3
    
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"scream"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"wave"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"tada"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"mask"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"birthday"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"no_good"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"punch"]];
    
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"money_with_wings"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"dog"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"cat"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"camel"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"stuck_out_tongue"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"sunglasses"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"eyes"]];
    
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"books"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"cold_sweat"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"pizza"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"coffee"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"muscle"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"beers"]];
    [emojiArray addObject:[[NgEmojiMap sharedInstance] emojiForAlias:@"gun"]];

    
    return [NSArray arrayWithArray:emojiArray];
}

@end
