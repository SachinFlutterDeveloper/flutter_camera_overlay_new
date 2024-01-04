class ExpData {
  String? status;
  String? billing;
  Data? data;
  String? message;

  ExpData({this.status, this.billing, this.data, this.message});

  ExpData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    billing = json['billing'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['billing'] = billing;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Data {
  String? id;
  String? dateof;
  String? patientId;
  String? packageId;
  String? expiry;
  String? status;
  String? stripePlanId;
  String? amount;
  String? stripeSubsId;
  String? paymentFrom;
  String? subscriptionId;
  String? pkgMode;
  String? packageName;
  String? pkgType;

  Data(
      {this.id,
      this.dateof,
      this.patientId,
      this.packageId,
      this.expiry,
      this.status,
      this.stripePlanId,
      this.amount,
      this.stripeSubsId,
      this.paymentFrom,
      this.subscriptionId,
      this.pkgMode,
      this.packageName,
      this.pkgType});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dateof = json['dateof'];
    patientId = json['patient_id'];
    packageId = json['package_id'];
    expiry = json['expiry'];
    status = json['status'];
    stripePlanId = json['stripe_plan_id'];
    amount = json['amount'];
    stripeSubsId = json['stripe_subs_id'];
    paymentFrom = json['payment_from'];
    subscriptionId = json['subscription_id'];
    pkgMode = json['pkg_mode'];
    packageName = json['package_name'];
    pkgType = json['pkg_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['dateof'] = dateof;
    data['patient_id'] = patientId;
    data['package_id'] = packageId;
    data['expiry'] = expiry;
    data['status'] = status;
    data['stripe_plan_id'] = stripePlanId;
    data['amount'] = amount;
    data['stripe_subs_id'] = stripeSubsId;
    data['payment_from'] = paymentFrom;
    data['subscription_id'] = subscriptionId;
    data['pkg_mode'] = pkgMode;
    data['package_name'] = packageName;
    data['pkg_type'] = pkgType;
    return data;
  }
}
