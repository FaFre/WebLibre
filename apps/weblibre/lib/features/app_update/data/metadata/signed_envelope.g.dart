// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signed_envelope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DsseEnvelope _$DsseEnvelopeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DsseEnvelope', json, ($checkedConvert) {
      final val = DsseEnvelope(
        payloadType: $checkedConvert('payloadType', (v) => v as String),
        payload: $checkedConvert('payload', (v) => v as String),
        signatures: $checkedConvert(
          'signatures',
          (v) => (v as List<dynamic>)
              .map((e) => DsseSignature.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

DsseSignature _$DsseSignatureFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DsseSignature', json, ($checkedConvert) {
      final val = DsseSignature(
        keyid: $checkedConvert('keyid', (v) => v as String),
        sig: $checkedConvert('sig', (v) => v as String),
      );
      return val;
    });
