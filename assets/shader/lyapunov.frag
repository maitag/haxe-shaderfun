/*
   ###############################################################################
   #    Author:   Sylvio Sell - maitag - Rostock 2013                            #
   #    Homepage: http://maitag.de                                               #
   #    License: GNU General Public License (GPL), Version 2.0                   #
   #                                                                             #
   #    more images about that lyapunov fractalcode at:                          #
   #    http://maitag.de/~semmi/                                                 #
   #                          (have fun!;)                                       #
   ############################################################################### */
   
varying vec2 vTexCoord;
uniform vec2 uMouse, uResolution, uScale, uPosition;
uniform vec2 uIteration, uParam;
uniform float uStart;
uniform float uBalance;
uniform vec3 uColpos;
uniform vec3 uColneg;
uniform vec3 uColmid;
uniform int uColtype;

float func(float x, float y, float a, float b)
{
    //return a*sin(x+y)*sin(x+y)+b;
    return #FORMULA;
}

float deriv(float x, float y, float a, float b)
{
    //return a*sin(2.0*(x+y));
    return #DERIVATE;
}

void pre_step(inout float x, vec2 p, float p1, float p2)
{
    x = func(x,p.x,p1,p2);
    x = func(x,p.y,p1,p2);
}

void main_step(inout float index, inout int iter, inout float x, vec2 p, float p1, float p2, float balance)
{
    x = func(x,p.x,p1,p2);
    index += (  log(abs(deriv(x,p.x,p1,p2)))*balance + deriv(x,p.x,p1,p2)*(1.0-balance)  ) / 2.0;
    x = func(x,p.y,p1,p2);
    index += (  log(abs(deriv(x,p.y,p1,p2)))*balance + deriv(x,p.y,p1,p2)*(1.0-balance)  ) / 2.0;
    iter = iter + 2;
}

void main( void ) {

	// Parameter
	float x = uStart;
	vec2 p = (vTexCoord - uPosition) / uScale;
	float p1 = uParam.x;
	float p2 = uParam.y;
	int iter_pre =  int(floor(uIteration.x));
	int iter_main = int(floor(uIteration.y));
	float nabla_pre = uIteration.x - float(iter_pre);
	float nabla_main = uIteration.y - float(iter_main);
	
	float index = 0.0;
	int iter = 0;
	
	// pre-iteration ##########################
	
	for (int i = 0; i < 21; i++) {
		if (i < iter_pre)
		{
			pre_step(x, p, p1, p2);
		}
	}
	if (nabla_pre != 0.0) {
		float x_pre = x;
		pre_step(x, p, p1, p2);
		x = x*nabla_pre + x_pre*(1.0-nabla_pre);
	}
		
	// main-iteration ########################
	
	for (int i = 0; i < 201; i++) {
		if (i < iter_main)
		{
			main_step(index, iter, x, p, p1, p2, uBalance);
		}
	}
	
	if (nabla_main == 0.0) {
		index = (iter != 0) ? index/float(iter) : 0.0;
	}
	else {
		float index_pre = (iter != 0) ? index/float(iter) : 0.0;

		main_step(index, iter, x, p, p1, p2, uBalance);

		index = (iter != 0) ? index/float(iter) : 0.0;
		index = index*nabla_main + index_pre*(1.0-nabla_main);
	}

	if (index > 0.0 && (uColtype==0 || uColtype==1)) {
		gl_FragColor = vec4(index*(uColpos-uColmid)+uColmid, 1.0);
	}
	else if (index < 0.0 && (uColtype==0 || uColtype==2)) {
		gl_FragColor = vec4(index*(uColmid-uColneg)+uColmid, 1.0);
	}
	else {
		gl_FragColor = vec4(uColmid, 1.0);
	}
}

