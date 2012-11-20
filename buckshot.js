var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.delay(2);

window.tapWithOptions( { x:160.0, y:370.0 } );

target.delay(5);

for(i=0;i<=100000;i++)
{
	xPoint = Math.floor(Math.random()*319+1)
	yPoint = Math.floor(Math.random()*479+1)
	window.tapWithOptions( { x:xPoint, y:yPoint } );
}
