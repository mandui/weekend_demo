library demo_aqueduct.globals;
import 'package:demo_aqueduct/data/definition/owner.dart';

List<Owner> registedOwners =List();

Owner getOwner(String wechatId) {
  for (Owner owner in registedOwners) {
    if (owner.wechatID ==wechatId)
      return owner;
  }

  return null;
}

void delOwner(String wechatId) {
  for (Owner owner in registedOwners) {
    if (owner.wechatID ==wechatId) {
      registedOwners.remove(owner);
      break;
    }
  }
}

bool userExist(String wechatId) {
  return registedOwners.contains(wechatId);
}

void addProperty(String wechatId, String propertyId, String communityId) {
  for (Owner owner in registedOwners) {
    if (owner.wechatID ==wechatId) {

      if (!owner.proertyIds.contains(propertyId)) {
        owner.proertyIds.add(propertyId);

        if (!owner.communityIds.contains(communityId))
          owner.communityIds.add(communityId);
      }
      break;
    }
  }
}

Map<String, dynamic> listCommunityIds(String wechatId) {
  for (Owner owner in registedOwners) {
    if (owner.wechatID ==wechatId) {
      final jsonMap =Map<String, dynamic>();
      jsonMap["communityIds"] =owner.communityIds;

      return jsonMap;
    }
  }
  return null;
}

Map<String, dynamic> listPropertyIds(String wechatId) {
  for (Owner owner in registedOwners) {
    if (owner.wechatID ==wechatId) {
      final jsonMap =Map<String, dynamic>();
      jsonMap["propertyIds"] =owner.proertyIds;

      return jsonMap;
    }
  }
  return null;
}

void regOwner(String wechatId, { 
  String id = "000000", String idType = "身份证", String name = "秦先生"}) {
  print("some some thing");
  if (wechatId ==null) 
    return;

  bool shouldAdd =true;
  for (Owner owner in registedOwners) {
    if (owner.wechatID ==wechatId) {
      shouldAdd =false;
      break;
    }
  }

  if (shouldAdd) {
    final owner =Owner(wechatId)
        ..ownerName =name
        ..idNo =id
        ..idType =idType;
    registedOwners.add(owner);

    print("reg owner num: ${registedOwners.length}");
  }
}