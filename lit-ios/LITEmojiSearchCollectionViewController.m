//
//  LITEmojiSearchCollectionViewController.m
//  lit-ios
//
//  Created by Antonio Losada on 22/9/15.
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#import "LITEmojiSearchCollectionViewController.h"
#import "LITEmojiUtils.h"
#import "LITTagCollectionViewCell.h"

@interface LITEmojiSearchCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    float screenWidth;
    float marginSize;
    float topMargin;
    float bottomMargin;
    float cellSize;
}

@property (strong, nonatomic) NSArray *emojis;

@end

@implementation LITEmojiSearchCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.emojis = [LITEmojiUtils allEmojis];
    
    self.collectionView.allowsMultipleSelection = YES;
    self.emojiString = [NSString string];
    
    //
    
    screenWidth = [[UIScreen mainScreen] bounds].size.width;
    marginSize = 9.0f;
    topMargin = 80.0f;
    bottomMargin = 16.0f;
    cellSize = (screenWidth-marginSize*5)/4; // 4 cells per row, 5 spaces per row
    
    //
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = marginSize;
    layout.minimumLineSpacing = marginSize;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [layout setItemSize:CGSizeMake(cellSize, cellSize)];
    [self.collectionView setCollectionViewLayout:layout];
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 46, [[UIScreen mainScreen] bounds].size.width, 20)];
    [label setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0f]];
    label.text = @"Search by Emoji";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;

    [self.collectionView addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"iconClose"] forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(closeButtonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.collectionView addSubview:button];
    
    NSDictionary * buttonDic = NSDictionaryOfVariableBindings(button);
    button.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray * hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[button(30)]" options:0 metrics:nil views:buttonDic];
    [self.collectionView addConstraints:hConstraints];
    
    NSArray * vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[button(30)]" options:0 metrics:nil views:buttonDic];
    [self.collectionView addConstraints:vConstraints];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.emojis count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LITTagCollectionViewCell *tagCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kLITTagCollectionViewCellidentifier forIndexPath:indexPath];
    NSAssert([tagCell isKindOfClass:[LITTagCollectionViewCell class]], @"The cell must be of class LITTagCollectionViewCell");
    
    tagCell.emojiLabel.text = self.emojis[indexPath.row];
    tagCell.layer.borderWidth = 0.0f;
    return tagCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.emojiString = [self.emojiString stringByAppendingString:self.emojis[indexPath.row]];
    [self.delegate didTapCloseButton:self];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.emojiString = [self.emojiString stringByReplacingOccurrencesOfString:self.emojis[indexPath.row] withString:@""];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(topMargin,marginSize,bottomMargin,marginSize);
}

#pragma mark - Actions
- (void)closeButtonPressed:(UIButton *)button
{
    [self.delegate didTapCloseButton:self];
}

@end
