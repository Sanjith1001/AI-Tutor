import 'package:flutter/material.dart';
import 'lesson_video_player.dart';

class CourseVideoSection extends StatelessWidget {
  final List<Map<String, String>> videos;
  final String sectionTitle;

  const CourseVideoSection({
    Key? key,
    required this.videos,
    required this.sectionTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            sectionTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: LessonVideoPlayer(
                videoUrl: video['url'] ?? '',
                title: video['title'] ?? 'Video ${index + 1}',
                description: video['description'],
                autoPlay: false,
              ),
            );
          },
        ),
      ],
    );
  }
}

// Example usage widget
class VideoLessonExample extends StatelessWidget {
  const VideoLessonExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sampleVideos = [
      {
        'title': 'Introduction to Flutter',
        'url':
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        'description': 'Learn the basics of Flutter development',
      },
      {
        'title': 'Flutter Widgets Overview',
        'url': 'https://www.youtube.com/watch?v=wE7khGHVkYY',
        'description': 'Understanding Flutter widgets and their usage',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Lessons'),
      ),
      body: SingleChildScrollView(
        child: CourseVideoSection(
          sectionTitle: 'Flutter Fundamentals',
          videos: sampleVideos,
        ),
      ),
    );
  }
}
