//
//  FragmentShader.glsl
//  GLKSample
//
//  Created by xiss burg on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

precision mediump float;

varying vec4 v_color;

void main()
{
    gl_FragColor = v_color;
}
