//
//  AKTagsLookup.h
//
//  Created by Andrey Kadochnikov on 30.05.14.
//  Copyright (c) 2014 Andrey Kadochnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKTagCell.h"
#import "AKTagsListView.h"

@class AKTagsLookup;
@protocol AKTagsLookupDelegate <NSObject>
-(void)tagsLookup:(AKTagsLookup*)lookup didSelectTag:(AKTagCell*)tag;
@end

@interface AKTagsLookup : UIView

@property (nonatomic, weak) id<AKTagsLookupDelegate, UITextFieldDelegate> delegate;
@property (nonatomic, strong) AKTagsListView *tagsView;

-(id)initWithTags:(NSArray*)tags;
-(void)updateTags:(NSArray*)tags;
-(void)filterLookupWithPredicate:(NSPredicate*)predicate;
-(NSPredicate*)predicateExcludingTags:(NSArray*)tagsToExclude andFilterByString:(NSString*)string;
-(NSPredicate*)predicateExcludingTags:(NSArray*)tagsToExclude;

@end
