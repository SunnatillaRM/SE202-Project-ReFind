class Claim {
  final int? claimId;
  final int itemId;
  final int claimantId;
  final String? message;
  final String status; // 'pending', 'approved', 'rejected'
  final int? createdAt;

  Claim({
    this.claimId,
    required this.itemId,
    required this.claimantId,
    this.message,
    this.status = 'pending',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'claim_id': claimId,
      'item_id': itemId,
      'claimant_id': claimantId,
      'message': message,
      'status': status,
      'created_at': createdAt ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Claim.fromMap(Map<String, dynamic> map) {
    return Claim(
      claimId: map['claim_id'] as int?,
      itemId: map['item_id'] as int,
      claimantId: map['claimant_id'] as int,
      message: map['message'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['created_at'] as int?,
    );
  }
}
