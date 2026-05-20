import 'package:equatable/equatable.dart';

class Labour extends Equatable {
  final String id;
  final String name;
  final String? phoneOptional;
  final DateTime createdAt;

  const Labour({
    required this.id,
    required this.name,
    this.phoneOptional,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, phoneOptional, createdAt];
}
