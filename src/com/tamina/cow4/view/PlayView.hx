package com.tamina.cow4.view;

import com.tamina.cow4.view.component.IAInfoComponent;
import js.html.ImageElement;
import js.html.Element;
import haxe.Timer;
import com.tamina.cow4.socket.message.UpdateRender;
import com.tamina.cow4.model.GameMap;
import com.tamina.cow4.socket.message.Render;
import com.tamina.cow4.socket.message.GameServerMessage;
import com.tamina.cow4.socket.PlayerServerProxy;
import org.tamina.net.URL;
import com.tamina.cow4.socket.message.StartBattle;
import com.tamina.cow4.config.Config;
import com.tamina.cow4.events.WebSocketEvent;
import com.tamina.cow4.net.request.PlayRequestParam;
import js.html.Event;
import js.html.WebSocket;
import com.tamina.cow4.ui.PlayerMapUI;
import com.tamina.cow4.ui.CellSprite;
import com.tamina.cow4.data.Mock;
import com.tamina.cow4.ui.MapUI;
import org.tamina.log.QuickLogger;
import js.html.CanvasElement;
import js.html.DivElement;
import js.Browser;
import org.tamina.html.HTMLComponent;
@view('com/tamina/cow4/view/PlayView.html')
class PlayView extends HTMLComponent {

    private static inline var APPLICATION_WIDTH:Int = 864;
    private static inline var APPLICATION_HEIGHT:Int = 864;

    private var _gameContainer:DivElement;
    private var _applicationCanvas:CanvasElement;
    private var _stage:PlayerMapUI;
    private var _socket:WebSocket;
    private var _proxy:PlayerServerProxy;
    private var _updatePool:Array<UpdateRender>;
    private var _map:GameMap;

    private var _ia1Info:IAInfoComponent;
    private var _ia2Info:IAInfoComponent;

    public function new(containerId:String = "") {
        super(Browser.document.getElementById(containerId));
        _updatePool = new Array<UpdateRender>();
        _gameContainer = cast Browser.document.getElementById(PlayViewElementId.GAME_CONTAINER);

        _ia1Info = new IAInfoComponent(PlayViewElementId.IA1_CONTAINER);
        _ia2Info = new IAInfoComponent(PlayViewElementId.IA2_CONTAINER);

        _applicationCanvas = cast Browser.document.createCanvasElement();
        _gameContainer.appendChild(_applicationCanvas);
        _applicationCanvas.width = APPLICATION_WIDTH;
        _applicationCanvas.height = APPLICATION_HEIGHT;
        QuickLogger.info("canvas initialized");
        _stage = new PlayerMapUI(_applicationCanvas);
        _socket = new WebSocket( 'ws://localhost:' + Config.WEB_SOCKET_PORT);

        _socket.addEventListener('open', socketOpenHandler);

        _proxy = new PlayerServerProxy(_socket);
        _proxy.messageSignal.add(serverMessageHandler);

        var t = new Timer(100);
        t.run = updateHandler;

    }

    private function socketOpenHandler(evt:Dynamic):Void {
        QuickLogger.info('Socket Open');
        var url = new URL(Browser.document.URL);
        _proxy.sendMessage(new StartBattle( url.parameters.get(PlayRequestParam.GAME_ID), url.parameters.get(PlayRequestParam.IA1), url.parameters.get(PlayRequestParam.IA2) ));
    }

    private function updateHandler():Void {
        if (_updatePool.length > 0 && _stage.runningActions == 0) {
            var msg = _updatePool.shift();
            if (msg.ia.id == _map.iaList[0].id) {
                _ia1Info.updateData(msg.ia);

            } else if (msg.ia.id == _map.iaList[1].id) {
                _ia2Info.updateData(msg.ia);
            }
            _stage.updateMap(msg.ia, msg.actions);
        }
    }

    private function serverMessageHandler(message:GameServerMessage):Void {
        switch( message.type){
            case Render.MESSAGE_TYPE:
                var render:Render = cast message;
                _map = GameMap.fromGameMapVO(render.map);
                _stage.data = _map;
                _ia1Info.updateData(_map.iaList[0]);
                _ia2Info.updateData(_map.iaList[1]);
            case UpdateRender.MESSAGE_TYPE:
                var update:UpdateRender = cast message;
                _updatePool.push(update);
//_stage.updateMap(update.ia,update.actions);

            default: QuickLogger.error('message inconnu');

        }
    }

}
