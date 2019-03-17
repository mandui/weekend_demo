import 'dart:io';
import 'dart:convert';
import 'package:aqueduct/aqueduct.dart';
import 'package:demo_aqueduct/data/definition/community.dart';
import 'package:demo_aqueduct/data/definition/property.dart';
import 'package:demo_aqueduct/data/global.dart' as globals;

class DataProvider extends ResourceController {

  @requiredBinding
  @Bind.query("api") String api;
  @Bind.query("wechatId") String wechatId;
  @Bind.query("propertyId") String propertyId;
  @Bind.query("communityId") String communityId;

  // under /data/
  @Operation.get("which") 
  Future<Response> getData() async {
    final which = request.path.variables['which'];
    print("testWechatAPI: $which");

    switch (which) {
      // /data/community_list used in search community
      case "update":
        _updateWithReq();
        return Response.ok("update complete.")..contentType =ContentType.text;
      
      case "query":
        final json = _queryWithReq();
        return Response.ok(json)..contentType =ContentType.json;
        break;
      default:
        return Response.ok("not such method")..contentType =ContentType.text;
    }
  }

  Map<String, dynamic> _queryWithReq() {
    print("_queryWithReq: $api");
      switch (api) {
        // user wants to list his properties
        // the url should be /data/query?api=list_properties&wechatId=xxxxx
        case "list_properties":
            print("list_properties wechatID: $wechatId");
            return globals.listPropertyIds(wechatId);
        // the url should be /data/query?api=list_communities&wechatId=xxxxx
        case "list_communities":
            print("list_communities wechatID: $wechatId");
            return globals.listCommunityIds(wechatId);
        // when in comm menu, user select maintainess events
        default: return null;
    }
  }
  
  void _updateWithReq() {
    print("_updateWithReq: $api");
    switch (api) {
      case "reg_owner":
        _registeOwner();
        break;
      
      case "add_property":
        _addProperty();
        break;
      default:
    } 
  }

  // the url should be /data/update?api=reg_owner&wechatId=xxxxx
  void _registeOwner() {
    globals.regOwner(wechatId);
  }

  // the url should be /data/update?api=reg_owner&wechatId=xxxxx&propertyId=ppppp&communityId=cccccc
  void _addProperty() {
    globals.addProperty(wechatId, propertyId, communityId);
  } 

}

class FakeData {

  String getJsonCommInfos() {
    final jsonMap = {"matched_comm": [
      fakeCommunities[0].info.toJsonStr(),
      fakeCommunities[1].info.toJsonStr()
    ]};

    return json.encode(jsonMap);
  }


  List<Community> fakeCommunities;
  List<Property> fakeProperties;

  void prepare() {
    _prepareProperties();
    _prepareCommunities();
  }

  void _prepareCommunities() {
    final info1 =CommunityInfo()
        ..name = "恒大翡翠华庭"
        ..addr = "济南市槐荫区淄博路与威海路交汇处"
        ..manager = "金碧物业"
        ..area = 143000;
    
    final info2 =CommunityInfo()
        ..name = "恒大御峰广场"
        ..addr = "济南市槐荫区青岛路与腊山河东路交叉口"
        ..manager = "金碧物业"
        ..area = 138200;

    final comm1 =Community("comm_01")
        ..info =info1
        ..maintenanceEvents =_fakeEvents();
    
    final comm2 =Community("comm_02")
        ..info =info2
        ..maintenanceEvents =_fakeEvents();

    fakeCommunities = [comm1, comm2];
  }

  void _prepareProperties() {
    final info1 =PropertyInfo()
        ..communityId = "comm_01"
        ..boughtDate = "2010年12月1日"
        ..area = 112.35
        ..addrDetails = "1号楼2单元1103户";

    final info2 =PropertyInfo()
        ..communityId = "comm_02"
        ..boughtDate = "2013年9月30日"
        ..area = 264.13
        ..addrDetails = "5号楼603户";

    final account =PropertyAccount()
        ..accountNo = "187402758"
        ..bankName ="交通银行"
        ..firstDate ="2012年3月"
        ..transactions = _fakeTransactions();

    final prop1 =Property("prop_01")
        ..account =account
        ..info =info1;
    
    final prop2 =Property("prop_02")
        ..info =info2
        ..account =account;

    fakeProperties.add(prop1);
    fakeProperties.add(prop2);
  }  

  //Property house1 =Property("propId_01")..
  List<Transaction> _fakeTransactions() {
    final trans1 =Transaction()
          ..date = "2013年3月"
          ..desc = "首次交存"
          ..money = 5023.6;

    final trans2 =Transaction()
          ..date = "2014年3月"
          ..desc = "结息"
          ..money = 110.52;

    final trans21 =Transaction()
          ..date = "2014年8月"
          ..desc = "维修费用"
          ..money = -863.52;

    final trans3 =Transaction()
          ..date = "2015年3月"
          ..desc = "结息"
          ..money = 93.95;

    final trans4 =Transaction()
          ..date = "2016年3月"
          ..desc = "结息"
          ..money = 109.11;

    final trans41 =Transaction()
          ..date = "2016年11月"
          ..desc = "维修费用"
          ..money = -397.25;

    final trans5 =Transaction()
          ..date = "2017年3月"
          ..desc = "结息"
          ..money = 109.91;

    final trans6 =Transaction()
          ..date = "2018年3月"
          ..desc = "结息"
          ..money = 104.48;

    final trans7 =Transaction()
          ..date = "2019年3月"
          ..desc = "结息"
          ..money = 107.31;

    // start 5023.6 now 4389
    // interest 634.28
    final List<Transaction> trans = [trans1, trans2, trans21, trans3, 
      trans4, trans41, trans5, trans6, trans7];

    return trans;
  }

  List<CommunityEvent> _fakeEvents() {

    final ch1 = Choice()
      ..choiceDesc ="三个月"
      ..areaPercent =13
      ..ownerPercent =17;
    
    final ch2 = Choice()
      ..choiceDesc ="六个月"
      ..areaPercent =25
      ..ownerPercent =24;

    final ev1 = CommunityEvent()
        ..desc = "您认为电梯维护应多久进行一次？"
        ..choices = [ch1, ch2];
    
    final ch3 = Choice()
      ..choiceDesc ="同意"
      ..areaPercent =35
      ..ownerPercent =32;
    
    final ch4 = Choice()
      ..choiceDesc ="拒绝"
      ..areaPercent =15
      ..ownerPercent =18;

    final ev2 = CommunityEvent()
        ..desc = "您同意小区门口加装门禁吗？"
        ..choices = [ch3, ch4];
    
    return [ev1, ev2];
  }
}


