import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final title = args['title'] ?? 'Untitled';
    final Timestamp? createdTs = args['created'];
    final created = createdTs?.toDate();
    final createdStr = created != null
        ? '${created.year}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')} ${created.hour}:${created.minute.toString().padLeft(2, '0')}'
        : 'Unknown date';

    final image1 = args['image1'] as Map<String, dynamic>;
    final image2 = args['image2'] as Map<String, dynamic>;

    final labels = [
      'Smile',
      'Left Eye Open',
      'Right Eye Open',
      'Mouth Gap',
      'Eyebrow Gap',
    ];

    final values1 = [
      image1['smiling'] ?? 0.0,
      image1['leftEyeOpen'] ?? 0.0,
      image1['rightEyeOpen'] ?? 0.0,
      image1['mouthGap'] ?? 0.0,
      image1['eyebrowGap'] ?? 0.0,
    ];

    final values2 = [
      image2['smiling'] ?? 0.0,
      image2['leftEyeOpen'] ?? 0.0,
      image2['rightEyeOpen'] ?? 0.0,
      image2['mouthGap'] ?? 0.0,
      image2['eyebrowGap'] ?? 0.0,
    ];

    final image1Url = image1['url'] ?? '';
    final image2Url = image2['url'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Comparison Detail')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Created at: $createdStr', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              image1Url != ''
                  ? Image.network(image1Url, width: 120, height: 120, fit: BoxFit.cover)
                  : const Icon(Icons.image, size: 100),
              image2Url != ''
                  ? Image.network(image2Url, width: 120, height: 120, fit: BoxFit.cover)
                  : const Icon(Icons.image, size: 100),
            ],
          ),
          const SizedBox(height: 24),
          ...List.generate(labels.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(labels[index],
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildBar(values1[index], 'Image 1'),
                            const SizedBox(height: 4),
                            _buildBar(values2[index], 'Image 2'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${(values1[index] * 100).toStringAsFixed(0)}%'),
                          const SizedBox(height: 4),
                          Text('${(values2[index] * 100).toStringAsFixed(0)}%'),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBar(double value, String label) {
    final clamped = value.clamp(0.0, 1.0);
    final color = Color.lerp(Colors.red, Colors.green, clamped);

    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(height: 20, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              FractionallySizedBox(
                widthFactor: clamped,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}