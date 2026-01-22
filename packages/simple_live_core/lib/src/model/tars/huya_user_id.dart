import 'package:tars_dart/tars/codec/tars_displayer.dart';
import 'package:tars_dart/tars/codec/tars_input_stream.dart';
import 'package:tars_dart/tars/codec/tars_output_stream.dart';
import 'package:tars_dart/tars/codec/tars_struct.dart';

class HuyaUserId extends TarsStruct {
  int lUid = 0;
  String sGuid = "";
  String sToken = "";
  String sHuYaUA = "";
  String sCookie = "";
  int iTokenType = 0;
  String sDeviceInfo = "";
  String sQIMEI = "";

  @override
  void readFrom(TarsInputStream inputStream) {
    lUid = inputStream.read(lUid, 0, false);
    sGuid = inputStream.read(sGuid, 1, false);
    sToken = inputStream.read(sToken, 2, false);
    sHuYaUA = inputStream.read(sHuYaUA, 3, false);
    sCookie = inputStream.read(sCookie, 4, false);
    iTokenType = inputStream.read(iTokenType, 5, false);
    sDeviceInfo = inputStream.read(sDeviceInfo, 6, false);
    sQIMEI = inputStream.read(sQIMEI, 7, false);
  }

  @override
  void writeTo(TarsOutputStream outputStream) {
    outputStream
      ..write(lUid, 0)
      ..write(sGuid, 1)
      ..write(sToken, 2)
      ..write(sHuYaUA, 3)
      ..write(sCookie, 4)
      ..write(iTokenType, 5)
      ..write(sDeviceInfo, 6)
      ..write(sQIMEI, 7);
  }

  @override
  Object deepCopy() {
    return HuyaUserId()
      ..lUid = lUid
      ..sGuid = sGuid
      ..sToken = sToken
      ..sHuYaUA = sHuYaUA
      ..sCookie = sCookie
      ..iTokenType = iTokenType
      ..sDeviceInfo = sDeviceInfo
      ..sQIMEI = sQIMEI;
  }

  @override
  void displayAsString(StringBuffer sb, int level) {
    TarsDisplayer(sb, level: level)
      ..DisplayInt(lUid, "lUid")
      ..DisplayString(sGuid, "sGuid")
      ..DisplayString(sToken, "sToken")
      ..DisplayString(sHuYaUA, "sHuYaUA")
      ..DisplayString(sCookie, "sCookie")
      ..DisplayInt(iTokenType, "iTokenType")
      ..DisplayString(sDeviceInfo, "sDeviceInfo")
      ..DisplayString(sQIMEI, "sQIMEI");
  }
}
