import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'paws_card.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: PawsCard,
)
Widget defaultCard(BuildContext context) {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: PawsCard(
        name: 'Max',
        species: 'Dog',
        breed: 'Golden Retriever',
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'With Image',
  type: PawsCard,
)
Widget cardWithImage(BuildContext context) {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: PawsCard(
        name: 'Luna',
        species: 'Cat',
        breed: 'Persian',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=200',
      ),
    ),
  );
}
