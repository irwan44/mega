import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_downloader/flutter_media_downloader.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/data_endpoint/learning.dart';
import '../../../data/endpoint.dart';
import 'detail_learning_view.dart';
import 'package:html/parser.dart' as html;

class LearningView extends StatefulWidget {
  const LearningView({super.key});

  @override
  State<LearningView> createState() => _LearningViewState();
}

class _LearningViewState extends State<LearningView> {
  final _flutterMediaDownloaderPlugin = MediaDownload();
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Learning>>(
        future: API.LearningID(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ShimmerLoadingCard();
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.nunito(),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No Learning Data Found',
                style: GoogleFonts.nunito(),
              ),
            );
          }

          final learningData = snapshot.data!;

          return SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            header: const WaterDropHeader(),
            onLoading: _onLoading,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: Colors.white,
                  expandedHeight: 200.0,
                  flexibleSpace: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final bool isWideScreen = constraints.maxWidth > 600;
                      return FlexibleSpaceBar(
                        title: Opacity(
                          opacity: constraints.biggest.height <= 120 ? 1.0 : 0.0,
                          child: Text(
                            'Learning',
                            style: GoogleFonts.nunito(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        background: Lottie.asset(
                          'assets/lottie/anm_learning.json',
                          width: isWideScreen
                              ? constraints.maxWidth * 0.5
                              : constraints.maxWidth,
                          height: isWideScreen
                              ? constraints.maxHeight * 0.2
                              : constraints.maxHeight * 0.25,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                  pinned: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Learning',
                      style: GoogleFonts.nunito(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'This section provides learning resources to help you understand different concepts better. Click on each item to explore more.',
                      style: GoogleFonts.nunito(
                        fontSize: 16.0,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return LearningCard(
                        learning: learningData[index],
                        downloader: _flutterMediaDownloaderPlugin,
                      );
                    },
                    childCount: learningData.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onLoading() {
    _refreshController.loadComplete();
  }

  void _onRefresh() {
    _refreshController.refreshCompleted();
  }
}

class ShimmerLoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Colors.grey.shade300,
      duration: const Duration(seconds: 2),
      interval: const Duration(seconds: 1),
      enabled: true,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 475),
              childAnimationBuilder: (widget) => SlideAnimation(
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                Shimmer(
                  color: Colors.grey.shade300,
                  child: Container(
                    width: 150,
                    height: 20,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10.0),
                Shimmer(
                  color: Colors.grey.shade300,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer(
                      color: Colors.grey.shade300,
                      child: Container(
                        width: 100,
                        height: 15,
                        color: Colors.white,
                      ),
                    ),
                    Shimmer(
                      color: Colors.grey.shade300,
                      child: Container(
                        width: 100,
                        height: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Shimmer(
                  color: Colors.grey.shade300,
                  child: Container(
                    width: 200,
                    height: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LearningCard extends StatelessWidget {
  final Learning learning;
  final MediaDownload downloader;

  const LearningCard({Key? key, required this.learning, required this.downloader}) : super(key: key);

  Future<void> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AnimationConfiguration.toStaggeredList(
        duration: const Duration(milliseconds: 475),
        childAnimationBuilder: (widget) => SlideAnimation(
          child: FadeInAnimation(
            child: widget,
          ),
        ),
        children: [
          InkWell(
            onTap: () {
              if (learning.id != null) {
                Get.to(() => DetailLearningView(id: learning.id!, downloader: downloader));
              } else {
                Get.snackbar('Error', 'Learning ID is missing.');
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWideScreen = constraints.maxWidth > 600;
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: isWideScreen ? 2 : 3,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: isWideScreen ? 16.0 : 12.0,
                                horizontal: isWideScreen ? 16.0 : 12.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    learning.title ?? 'No Title',
                                    style: GoogleFonts.nunito(
                                      fontSize: isWideScreen ? 20.0 : 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: isWideScreen ? 10.0 : 8.0),
                                  Text(
                                    _stripHtmlIfNeeded(learning.content ?? ''),
                                    style: GoogleFonts.nunito(
                                      fontSize: isWideScreen ? 16.0 : 14.0,
                                      color: Colors.black54,
                                    ),
                                    maxLines: isWideScreen ? 4 : 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: isWideScreen ? 12.0 : 10.0),
                                  // Tampilkan tombol download hanya jika fileUpload tidak null dan tidak kosong
                                  if (learning.fileUpload != null && learning.fileUpload!.isNotEmpty)
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: isWideScreen ? 12.0 : 8.0,
                                          horizontal: isWideScreen ? 16.0 : 10.0,
                                        ),
                                      ),
                                      onPressed: () async {
                                        final url = _getFileUrl(learning.fileUpload!);
                                        await _requestPermissions();
                                        try {
                                          await downloader.downloadMedia(context, url);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Download started for $url')),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Could not download file')),
                                          );
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.download_rounded,
                                            size: isWideScreen ? 20 : 16,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: isWideScreen ? 12.0 : 8.0),
                                          Text(
                                            'Download Attachment',
                                            style: GoogleFonts.nunito(
                                              color: Colors.white,
                                              fontSize: isWideScreen ? 16.0 : 14.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: isWideScreen ? 3 : 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network(
                                  _extractImageUrl(learning.content ?? ''),
                                  width: isWideScreen ? 150 : 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Text(
                                    'Failed to load image',
                                    style: GoogleFonts.nunito(fontSize: isWideScreen ? 16.0 : 14.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10, left: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'By: ${learning.createdBy ?? ''}',
                              style: GoogleFonts.nunito(
                                color: Colors.grey,
                                fontSize: isWideScreen ? 14.0 : 12.0,
                              ),
                            ),
                            Text(
                              'Created: ${learning.createdAt ?? ''}',
                              style: GoogleFonts.nunito(
                                color: Colors.grey,
                                fontSize: isWideScreen ? 14.0 : 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10)
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _extractImageUrl(String content) {
    final regex = RegExp(r'src="([^"]+)"');
    final match = regex.firstMatch(content);
    if (match != null && match.groupCount > 0) {
      final imageUrl = match.group(1)!;
      return imageUrl.startsWith('http')
          ? imageUrl
          : 'https://agencydashboard.megainsurance.co.id$imageUrl';
    }
    return '';
  }

  String _getFileUrl(String filePath) {
    final fullUrl = filePath.startsWith('http')
        ? filePath
        : 'https://agencydashboard.megainsurance.co.id$filePath';
    return fullUrl;
  }

  String _stripHtmlIfNeeded(String htmlString) {
    // Remove HTML tags
    final regex = RegExp(r'<[^>]*>');
    String strippedString = htmlString.replaceAll(regex, '');

    // Decode HTML entities using the parser
    String decodedString = html.parse(strippedString).documentElement?.text ?? '';

    return decodedString;
  }
}
