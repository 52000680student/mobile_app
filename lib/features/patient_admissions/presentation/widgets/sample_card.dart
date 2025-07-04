import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/patient_models.dart';

class SampleCard extends StatelessWidget {
  final SampleInfo sample;

  const SampleCard({
    super.key,
    required this.sample,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1976D2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sample header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.sample(sample.number)}: ${_getSampleTypeText(sample.type, l10n)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sample.id,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: sample.isEnabled,
                onChanged: (value) {
                  // Handle switch toggle
                },
                activeColor: const Color(0xFF1976D2),
                inactiveThumbColor: Colors.grey.shade400,
                activeTrackColor: Colors.blue[100],
                inactiveTrackColor: Colors.grey[200],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sample details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Sample info
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem(l10n.timeCollected, sample.timeCollected),
                    const SizedBox(height: 8),
                    _buildDetailItem(l10n.collectedBy, sample.collectedBy),
                    const SizedBox(height: 8),
                    _buildDetailItem(
                        l10n.quality, _getQualityText(sample.quality, l10n)),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Right column - Services
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.service,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...sample.services
                        .map((service) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getServiceText(service.name, l10n),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1976D2),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Mã DV: ${service.code} | Sub SID: ${service.subCode} | XN: ${service.description}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        ,
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  String _getSampleTypeText(String type, AppLocalizations l10n) {
    switch (type) {
      case 'venousBlood':
        return l10n.venousBlood;
      case 'urine':
        return l10n.urine;
      default:
        return type;
    }
  }

  String _getQualityText(String quality, AppLocalizations l10n) {
    switch (quality) {
      case 'good':
        return l10n.good;
      default:
        return quality;
    }
  }

  String _getServiceText(String serviceName, AppLocalizations l10n) {
    switch (serviceName) {
      case 'comprehensiveBloodTest':
        return l10n.comprehensiveBloodTest;
      case 'generalUrineAnalysis':
        return l10n.generalUrineAnalysis;
      default:
        return serviceName;
    }
  }
}
