//
//  AKTagsLookup.m
//
//  Created by Andrey Kadochnikov on 30.05.14.
//  Copyright (c) 2014 Andrey Kadochnikov. All rights reserved.
//

#import "AKTagsLookup.h"

@interface AKTagsLookup () <AKTagsListViewDelegate, UITextFieldDelegate>
{
	NSMutableArray *_tagsBase;
}

@end

@implementation AKTagsLookup

-(id)initWithTags:(NSArray *)tags
{
    self = [super initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) * 1 / 5 + 25, 0, CGRectGetWidth([UIScreen mainScreen].bounds) * 5 / 7, 44)];
    if (self) {
		_tagsBase = [NSMutableArray arrayWithArray:tags];
		_tagsView = [[AKTagsListView alloc] initWithFrame:self.bounds];
		_tagsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_tagsView.selectedTags = [NSMutableArray arrayWithArray:tags];
		_tagsView.backgroundColor = [UIColor clearColor];
		_tagsView.collectionView.backgroundColor = [UIColor clearColor];
		_tagsView.delegate = self;
        
        //[_tagsView.collectionView registerClass:[UITextField class] forCellWithReuseIdentifier:@"textFieldCell"];

		self.backgroundColor = [UIColor clearColor];
		[self addSubview:_tagsView];
    }
    return self;
}

- (void)updateTags:(NSArray*)tags
{
    [_tagsBase removeAllObjects];
    [_tagsView.selectedTags removeAllObjects];
    
    _tagsBase = [NSMutableArray arrayWithArray:tags];
    _tagsView.selectedTags = [NSMutableArray arrayWithArray:tags];
    [_tagsView.collectionView reloadData];
}

-(NSPredicate*)predicateExcludingTags:(NSArray*)tagsToExclude andFilterByString:(NSString*)string
{
    return [NSCompoundPredicate andPredicateWithSubpredicates:@[[self predicateExcludingTags:tagsToExclude], [NSPredicate predicateWithFormat:@"self.tagName BEGINSWITH[cd] %@", string]]];
}

-(NSPredicate*)predicateExcludingTags:(NSArray*)tagsToExclude
{
    return [NSPredicate predicateWithFormat:@"NOT(self.tagName IN %@)", tagsToExclude];
}


-(void)filterLookupWithPredicate:(NSPredicate *)predicate
{
    
	[_tagsView.collectionView performBatchUpdates:^{
		NSMutableArray *filteredTags = [[_tagsBase filteredArrayUsingPredicate:predicate] mutableCopy];
		_tagsView.selectedTags = filteredTags;
		[_tagsView.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];

	} completion:^(BOOL finished) {
		
	}];
}

-(void)tagsListView:(AKTagsListView*)tagsView didSelectTag:(AKTagCell*)tag atIndexPath:(NSIndexPath*)indexPath{
    
    if ([self.delegate respondsToSelector:@selector(tagsLookup:didSelectTag:)]){
        
        [self.delegate tagsLookup:(AKTagsLookup*)self didSelectTag:tag];
    }
    
}
@end
