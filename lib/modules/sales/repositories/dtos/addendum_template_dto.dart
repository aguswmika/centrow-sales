import 'package:centrow_sales/modules/sales/entities/addendum_template.dart';

class AddendumTemplateDto {
  final String id;
  final String title;

  const AddendumTemplateDto({required this.id, required this.title});

  factory AddendumTemplateDto.fromJson(Map<String, dynamic> json) {
    return AddendumTemplateDto(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }

  AddendumTemplate toEntity() => AddendumTemplate(id: id, title: title);

  Map<String, dynamic> toJson() => {'id': id, 'title': title};
}
