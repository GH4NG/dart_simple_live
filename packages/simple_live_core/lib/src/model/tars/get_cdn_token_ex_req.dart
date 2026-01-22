import 'package:tars_dart/tars/codec/tars_displayer.dart';
import 'package:tars_dart/tars/codec/tars_input_stream.dart';
import 'package:tars_dart/tars/codec/tars_output_stream.dart';
import 'package:tars_dart/tars/codec/tars_struct.dart';

import 'package:simple_live_core/src/model/tars/huya_user_id.dart';

class GetCdnTokenExReq extends TarsStruct {
  String sFlvUrl = ""; //tag 0
  String sStreamName = ""; //tag 1
  int iLoopTime = 0; //tag 2
  HuyaUserId tId = HuyaUserId(); //tag 3
  int iAppId = 66; //tag 4

  @override
  void readFrom(TarsInputStream inputStream) {
    sFlvUrl = inputStream.read(sFlvUrl, 0, false);
    sStreamName = inputStream.read(sStreamName, 1, false);
    iLoopTime = inputStream.read(iLoopTime, 2, false);
    tId = inputStream.read(tId, 3, false);
    iAppId = inputStream.read(iAppId, 4, false);
  }

  @override
  void writeTo(TarsOutputStream outputStream) {
    outputStream
      ..write(sFlvUrl, 0)
      ..write(sStreamName, 1)
      ..write(iLoopTime, 2)
      ..write(tId, 3)
      ..write(iAppId, 4);
  }

  @override
  TarsStruct deepCopy() {
    return GetCdnTokenExReq()
      ..sFlvUrl = sFlvUrl
      ..sStreamName = sStreamName
      ..iLoopTime = iLoopTime
      ..tId = tId
      ..iAppId = iAppId;
  }

  @override
  void displayAsString(StringBuffer sb, int level) {
    TarsDisplayer(sb, level: level)
      ..DisplayString(sFlvUrl, "sFlvUrl")
      ..DisplayString(sStreamName, "sStreamName")
      ..DisplayInt(iLoopTime, "iLoopTime")
      ..DisplayTarsStruct(tId, "tId")
      ..DisplayInt(iAppId, "iAppId");
  }
}
