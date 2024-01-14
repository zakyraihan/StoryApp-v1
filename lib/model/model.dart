// To parse this JSON data, do
//
//     final storyResult = storyResultFromJson(jsonString);

import 'dart:convert';

StoryResult storyResultFromJson(String str) =>
    StoryResult.fromJson(json.decode(str));

String storyResultToJson(StoryResult data) => json.encode(data.toJson());

class StoryResult {
  String description;
  String imagePath;

  StoryResult({
    required this.description,
    required this.imagePath,
  });

  factory StoryResult.fromJson(Map<String, dynamic> json) => StoryResult(
        description: json["description"],
        imagePath: json["imagePath"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "imagePath": imagePath,
      };
}
