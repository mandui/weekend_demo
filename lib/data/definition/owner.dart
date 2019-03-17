class Owner {
  
  Owner(this.wechatID);
  // key
  String wechatID;

  // others
  // Info section
  String idType;
  String idNo;
  String ownerName;
  String sex;

  // properties
  List<String> proertyIds =List();
  List<String> communityIds =List();
  Map<String, num> perpertyNumInComm =Map();
}