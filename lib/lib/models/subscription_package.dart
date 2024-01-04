class PackageObject {
  final String id;
  final String packageName;
  final String durationMonth;
  String amount;
  String isDeleted;
  String pkgType;
  String pkgMode;
  String? stripePlanId;
  String appstorePkgId;
  String androidPkgId;

//<editor-fold desc="Data Methods">
  PackageObject({
    required this.id,
    required this.packageName,
    required this.durationMonth,
    required this.amount,
    required this.isDeleted,
    required this.pkgType,
    required this.pkgMode,
    this.stripePlanId,
    required this.appstorePkgId,
    required this.androidPkgId,
  });

  PackageObject copyWith({
    String? id,
    String? packageName,
    String? durationMonth,
    String? amount,
    String? isDeleted,
    String? pkgType,
    String? pkgMode,
    String? stripePlanId,
    String? appstorePkgId,
    String? androidPkgId,
  }) {
    return PackageObject(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      durationMonth: durationMonth ?? this.durationMonth,
      amount: amount ?? this.amount,
      isDeleted: isDeleted ?? this.isDeleted,
      pkgType: pkgType ?? this.pkgType,
      pkgMode: pkgMode ?? this.pkgMode,
      stripePlanId: stripePlanId ?? this.stripePlanId,
      appstorePkgId: appstorePkgId ?? this.appstorePkgId,
      androidPkgId: androidPkgId ?? this.androidPkgId,
    );
  }

  factory PackageObject.fromJson(Map<String, dynamic> map) {
    return PackageObject(
      id: map['id'] as String,
      packageName: map['package_name'] as String,
      durationMonth: map['duration_month'] as String,
      amount: map['amount'] as String,
      isDeleted: map['is_deleted'] as String,
      pkgType: map['pkg_type'] as String,
      pkgMode: map['pkg_mode'] as String,
      stripePlanId: map['stripe_plan_id'] as String,
      appstorePkgId: map['appstore_pkg_id'] as String,
      androidPkgId: map['android_pkg_id'] as String,
    );
  }

//</editor-fold>
}

class SubscriptionPackage {
  int? success;
  List<PackageObject>? data;
  List<PackageObject>? familyPackages;

  SubscriptionPackage({this.success, this.data});

  SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <PackageObject>[];
      json['data'].forEach((v) {
        data!.add(PackageObject.fromJson(v));
      });
    }
    if (json['family_packages'] != null) {
      familyPackages = <PackageObject>[];
      json['family_packages'].forEach((v) {
        familyPackages!.add(PackageObject.fromJson(v));
      });
    }
  }
}
