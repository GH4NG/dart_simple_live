import 'package:tars_flutter/tars/codec/tars_displayer.dart';
import 'package:tars_flutter/tars/codec/tars_input_stream.dart';
import 'package:tars_flutter/tars/codec/tars_output_stream.dart';
import 'package:tars_flutter/tars/codec/tars_struct.dart';

class GetCdnTokenReq extends TarsStruct {
  String url = "";

  String cdnType = "";

  String streamName = "";

  int presenterUid = 0;

  @override
  void readFrom(TarsInputStream inputStream) {
    url = inputStream.read(url, 0, false);
    cdnType = inputStream.read(cdnType, 1, false);
    streamName = inputStream.read(streamName, 2, false);
    presenterUid = inputStream.read(presenterUid, 3, false);
  }

  @override
  void writeTo(TarsOutputStream outputStream) {
    outputStream
      ..write(url, 0)
      ..write(cdnType, 1)
      ..write(streamName, 2)
      ..write(presenterUid, 3);
  }

  @override
  Object deepCopy() {
    return GetCdnTokenReq()
      ..url = url
      ..cdnType = cdnType
      ..streamName = streamName
      ..presenterUid = presenterUid;
  }

  @override
  void displayAsString(StringBuffer sb, int level) {
    TarsDisplayer(sb, level: level)
      ..DisplayString(url, "url")
      ..DisplayString(cdnType, "cdnType")
      ..DisplayString(streamName, "streamName")
      ..DisplayInt(presenterUid, "presenterUid");
  }
}
