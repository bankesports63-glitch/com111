import 'package:cloud_firestore/cloud_firestore.dart';

class UserAddress {
  String id;
  String tag; // e.g., บ้าน, ที่ทำงาน
  String fullAddress;
  String phone;
  bool isDefault;

  UserAddress({
    required this.id,
    required this.tag,
    required this.fullAddress,
    required this.phone,
    this.isDefault = false,
  });

  factory UserAddress.fromMap(Map<String, dynamic> data) {
    return UserAddress(
      id: data['id'] ?? '',
      tag: data['tag'] ?? 'ที่อยู่',
      fullAddress: data['fullAddress'] ?? '',
      phone: data['phone'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tag': tag,
      'fullAddress': fullAddress,
      'phone': phone,
      'isDefault': isDefault,
    };
  }
}

class UserProfile {
  String uid;
  String email;
  String displayName;
  String photoUrl;
  List<UserAddress> addresses;

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.photoUrl = '',
    this.addresses = const [],
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final addressList = (data['addresses'] as List<dynamic>? ?? []).map((e) => UserAddress.fromMap(e as Map<String, dynamic>)).toList();
    
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      addresses: addressList,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'addresses': addresses.map((a) => a.toMap()).toList(),
    };
  }
}
