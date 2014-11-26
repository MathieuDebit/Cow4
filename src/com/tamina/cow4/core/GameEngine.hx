package com.tamina.cow4.core;
import com.tamina.cow4.socket.SheepIA;
import com.tamina.cow4.data.Mock;
import com.tamina.cow4.model.Game;
import com.tamina.cow4.socket.IA;
import com.tamina.cow4.model.GameMap;
class GameEngine {

    private var _currentTurn:Int;
    private var _endBattleDate:Date;
    private var _data:GameMap;
    private var _isComputing:Bool;
    private var _maxNumTurn:Int;
    private var _startBattleDate:Date;
    private var _sheep:IA;

    private var _IAList:Array<IA>;
    public function new( iaList:Array<IA>) {
        _IAList = iaList;
        _sheep = new SheepIA();
        _data = Mock.instance.getTestMap(25, 25);
        _data.getCellAt(0,0).occupant = _IAList[0].toInfo();
        _data.getCellAt(24,24).occupant = _IAList[1].toInfo();
        _data.getCellAt(12,12).occupant = _sheep.toInfo();
    }

    public function start():Void {
        _currentTurn = 0;
        _isComputing = false;

        /*_IAList[0].turnResult_completeSignal.add(IA_ordersResultHandler);
        _IAList[0].turnMaxDuration_reachSignal.add(maxDuration_reachHandler);
        _IAList[0].turnResult_errorSignal.add(turnResultErrorHandler);

        _IAList[1].turnResult_completeSignal.add(IA_ordersResultHandler);
        _IAList[1].turnMaxDuration_reachSignal.add(maxDuration_reachHandler);
        _IAList[1].turnResult_errorSignal.add(turnResultErrorHandler);*/

        _maxNumTurn = Game.GAME_MAX_NUM_TURN;
        _startBattleDate = Date.now();
        _currentTurn = 0;
        _isComputing = true;

    }


    private function retrieveIAOrders(targetIA:IA):Void {
        targetIA.sendIAOrder(_data);
    }
}