class Property {
  Property(this.propId);
  // key
  String propId;

  // others
  PropertyInfo info;
  PropertyAccount account;
}

class PropertyInfo {
  String communityId;
  String addrDetails;
  num area;
  num price;
  String boughtDate;
}

class PropertyAccount {
  String bankName;
  String accountNo;

  String firstDate;
  List<Transaction> transactions;
}

class Transaction {
  String date;
  String desc;
  num money;
  String extra;
}