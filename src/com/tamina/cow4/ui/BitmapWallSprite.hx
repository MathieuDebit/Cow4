package com.tamina.cow4.ui;
import js.html.Event;
import org.tamina.events.html.ImageEvent;
import js.html.Image;

class BitmapWallSprite extends WallSprite {

    private var _backgroundImage:Image;
    private var _isLoaded:Bool = false;

    public function new( bitmapPath:String ) {
        super(null);
        _backgroundImage = new Image();
        _backgroundImage.addEventListener(ImageEvent.LOAD, backgroundLoadHandler);
        _backgroundImage.src = bitmapPath;
    }

    private function backgroundLoadHandler( evt:Event ):Void {
        _isLoaded = true;
        drawWall("");
    }

    override private function set_display(value:Bool):Bool{
        _display = value;
        this.visible = _display;
        return _display;
    }

    override private function drawWall( color:String = "" ):Void {
        if ( _isLoaded ) {
            _backgroundShape.graphics.clear();
            _backgroundShape.graphics.beginBitmapFill(_backgroundImage,"no-repeat");
            _backgroundShape.graphics.drawRect(0, 0, _backgroundImage.width, _backgroundImage.height);
            _backgroundShape.graphics.endFill();
        }
    }
}
