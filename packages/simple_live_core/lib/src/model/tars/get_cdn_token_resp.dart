import 'package:tars_flutter/tars/codec/tars_displayer.dart';
import 'package:tars_flutter/tars/codec/tars_input_stream.dart';
import 'package:tars_flutter/tars/codec/tars_output_stream.dart';
import 'package:tars_flutter/tars/codec/tars_struct.dart';

class GetCdnTokenResp extends TarsStruct {
  String url = "";

  String cdnType = "";

  String streamName = "";

  int presenterUid = 0;

  String antiCode = "";

  String sTime = "";

  String flvAntiCode = "";

  String hlsAntiCode = "";

  @override
  void readFrom(TarsInputStream inputStream) {
    url = inputStream.read(url, 0, false);
    cdnType = inputStream.read(cdnType, 1, false);
    streamName = inputStream.read(streamName, 2, false);
    presenterUid = inputStream.read(presenterUid, 3, false);
    antiCode = inputStream.read(antiCode, 4, false);
    sTime = inputStream.read(sTime, 5, false);
    flvAntiCode = inputStream.read(flvAntiCode, 6, false);
    hlsAntiCode = inputStream.read(hlsAntiCode, 7, false);
  }

  @override
  void writeTo(TarsOutputStream outputStream) {
    outputStream
      ..write(url, 0)
      ..write(cdnType, 1)
      ..write(streamName, 2)
      ..write(presenterUid, 3)
      ..write(antiCode, 4)
      ..write(sTime, 5)
      ..write(flvAntiCode, 6)
      ..write(hlsAntiCode, 7);
  }

  @override
  Object deepCopy() {
    return GetCdnTokenResp()
      ..url = url
      ..cdnType = cdnType
      ..streamName = streamName
      ..presenterUid = presenterUid
      ..antiCode = antiCode
      ..sTime = sTime
      ..flvAntiCode = flvAntiCode
      ..hlsAntiCode = hlsAntiCode;
  }

  @override
  void displayAsString(StringBuffer sb, int level) {
    TarsDisplayer(sb, level: level)
      ..DisplayString(url, "url")
      ..DisplayString(cdnType, "cdnType")
      ..DisplayString(streamName, "streamName")
      ..DisplayInt(presenterUid, "presenterUid")
      ..DisplayString(antiCode, "antiCode")
      ..DisplayString(sTime, "sTime")
      ..DisplayString(flvAntiCode, "flvAntiCode")
      ..DisplayString(hlsAntiCode, "hlsAntiCode");
  }
}
