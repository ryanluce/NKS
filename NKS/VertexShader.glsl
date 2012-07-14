//
//  VertexShader.glsl
//  GLKSample
//
//  Created by xiss burg on 1/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

uniform mat4 u_matrix;
uniform float u_pixelSize;


attribute vec4 a_position;
attribute vec4 a_color;

varying vec4 v_color;

void main()
{
    gl_PointSize = u_pixelSize;
    gl_Position = u_matrix * a_position;
    v_color = a_color;
    
}
