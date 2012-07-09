//
//  NKSModel.h
//  NKS - An implemenation of Stephen Wolfram's Cellular Automata based on his book, A New Kind of Science
//
//  Created by Ryan Luce on 7/2/12.
//  Copyright (c) 2012 Ryan Luce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ColorModel.h"


@interface NKSModel : NSObject
{
    //Johns number of rules is 3, represented by white, gray, and black
    int _numberOfRules;
    //Traditional NKS is 1 neighbor on each side
    int _totalNeighborCount;
    //Array of rules 
    int *_rules;
    NSMutableDictionary *_dRules;
    //Array of rows of data 0 through (numberOfRules-1)
    int *_data;
    //How big each pixel is to be drawn
    int _pixelSize;
    //How many rows to show based on pixel
    int _rows;
    int _columns;
    
    
    
    
}

@property (nonatomic) int numberOfRules;
@property (nonatomic) int totalNeighborCount;
@property (nonatomic) int pixelSize;
@property (nonatomic, readonly) int rows;
@property (nonatomic, readonly) int columns;
@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic) BOOL isReady;

//- (void)generateRandomData;
- (void)reloadData;
//Get an existing rule at the particular row/column
- (int)getRuleAtRow:(int)row andColumn:(int)column;
//Get a color for a pixel based on it's rule
- (ColorModel *)getColorAtRow:(int)row andColumn:(int)column;

+ (NKSModel *)sharedInstance;
@end
