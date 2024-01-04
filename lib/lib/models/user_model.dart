
class user {
  var id;
  var pinCode;
  String? firstName;
  String? lastName;
  var gender;
  String? phone;
  String? birthdate;
  String? email;
  String? username;
  String? password;
  String? image;
  var isApproved;
  String? city;
  String? state;
  String? country;
  String? occupation;
  String? residency;
  var maritalStatus;
  String? qbId;
  String? regDate;
  String? zipcode;
  String? timezone;
  String? deviceToken;
  String? insurance;
  String? policyNumber;
  String? relationship;

  user({
     this.id,
     this.pinCode,
     this.firstName,
     this.lastName,
     this.gender,
     this.phone,
     this.birthdate,
     this.email,
     this.username,
     this.password,
     this.image,
     this.isApproved,
     this.city,
     this.state,
     this.country,
     this.occupation,
     this.residency,
     this.maritalStatus,
     this.qbId,
     this.regDate,
     this.zipcode,
     this.timezone,
     this.deviceToken,
     this.insurance,
     this.policyNumber,
     this.relationship,
  });

  factory user.fromJson(Map<String, dynamic> json) {
    return user(
      id: json['user']['id'],
      pinCode: json['user']['pin_code'],
      firstName: json['user']['first_name'],
      lastName: json['user']['last_name'],
      gender: json['user']['gender'],
      phone: json['user']['phone'],
      birthdate: json['user']['birthdate'],
      email: json['user']['email'],
      username: json['user']['username'],
      password: json['user']['password'],
      image: json['user']['image'],
      isApproved: json['user']['is_approved'],
      city: json['user']['city'],
      state: json['user']['state'],
      country: json['user']['country'],
      occupation: json['user']['occupation'],
      residency: json['user']['residency'],
      maritalStatus: json['user']['marital_status'],
      qbId: json['user']['qb_id'],
      regDate: json['user']['reg_date'],
      zipcode: json['user']['zipcode'],
      timezone: json['user']['timezone'],
      deviceToken: json['user']['device_token'],
      insurance: json['user']['insurance'],
      policyNumber: json['user']['policy_number'],
      relationship: json['user']['relationship'],
    );
  }
}
