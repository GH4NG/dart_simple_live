import 'package:simple_live_app/app/controller/base_controller.dart';
import 'package:simple_live_app/app/utils.dart';
import 'package:simple_live_app/models/db/history.dart';
import 'package:simple_live_app/services/history_service.dart';

class HistoryController extends BasePageController<History> {
  @override
  Future<List<History>> getData(int page, int pageSize) {
    if (page > 1) {
      return Future.value([]);
    }
    return Future.value(HistoryService.instance.getHistories());
  }

  Future<void> clean() async {
    var result = await Utils.showAlertDialog("确定要清空观看记录吗?", title: "清空观看记录");
    if (!result) {
      return;
    }
    await HistoryService.instance.historyClear();
    refreshData();
  }

  Future<void> removeItem(History item) async {
    await HistoryService.instance.delHistory(item.id);
    refreshData();
  }
}
