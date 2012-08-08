//
//  ColorModel.h
//  NKS
//
//  Created by Ryan Luce on 7/5/12.
//  Copyright (c) 2012 Ryan Luce. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ColorModel : NSObject
@property (nonatomic) float red;
@property (nonatomic) float green;
@property (nonatomic) float blue;
@property (nonatomic) float alpha;

- (float)hue;

@end
