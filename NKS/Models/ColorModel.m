//
//  ColorModel.m
//  NKS
//
//  Created by Ryan Luce on 7/5/12.
//  Copyright (c) 2012 Ryan Luce. All rights reserved.
//

#import "ColorModel.h"

@implementation ColorModel
@synthesize red, green, blue, alpha;

- (float)hue
{
    float r,g,b;
        r = red;
        g = green;
        b = blue;
        
        
        float h,s, l, v, m, vm, r2, g2, b2;
        
        h = 0;
        s = 0;
        l = 0;
        
        v = MAX(r, g);
        v = MAX(v, b);
        m = MIN(r, g);
        m = MIN(m, b);
        
        l = (m+v)/2.0f;
        
        if (l <= 0.0){
            return h;
        }
        
        vm = v - m;
        s = vm;
        
        if (s > 0.0f){
            s/= (l <= 0.5f) ? (v + m) : (2.0 - v - m); 
        }else{
            
            return h;
        }
        
        r2 = (v - r)/vm;
        g2 = (v - g)/vm;
        b2 = (v - b)/vm;
        
        if (r == v){
            h = (g == m ? 5.0f + b2 : 1.0f - g2);
        }else if (g == v){
            h = (b == m ? 1.0f + r2 : 3.0 - b2);
        }else{
            h = (r == m ? 3.0f + g2 : 5.0f - r2);
        }
        
        h/=6.0f;
    return h;
    
}

@end
