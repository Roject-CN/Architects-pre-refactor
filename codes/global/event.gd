extends Node

#负责放置一些全局事件的信号通信

#建造建造开始时和结束后发出 用于 MainTime在建造建筑时暂停计时
signal building_ui_enter
signal building_ui_quit
signal building_end

#关于员工 第一个是员工开始在placehodlerui 中工作增加建筑值属性 第二个则不需要工作了
#后面再搞
signal craftsman_become_busy
signal craftsman_become_lazy
