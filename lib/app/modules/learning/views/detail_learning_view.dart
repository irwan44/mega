import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_downloader/flutter_media_downloader.dart'; // Import yang benar
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/data_endpoint/detaillearning.dart';
import '../../../data/data_endpoint/learning.dart';
import '../../../data/endpoint.dart';

class DetailLearningView extends StatefulWidget {
  final int id; // Learning ID
  final MediaDownload downloader; // Gunakan MediaDownload
  const DetailLearningView({super.key, required this.id, required this.downloader});

  @override
  State<DetailLearningView> createState() => _DetailLearningViewState();
}

class _DetailLearningViewState extends State<DetailLearningView> {
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<DetailLearning> fetchDetailLearning(int id) async {
    try {
      final response = await API.DetailLearningID(id);
      if (response != null) {
        return response;
      } else {
        throw Exception('Failed to load learning details');
      }
    } catch (e) {
      throw Exception('Failed to load learning details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: Text('Learning Detail', style: GoogleFonts.nunito()),
      ),
      body: FutureBuilder<DetailLearning>(
        future: fetchDetailLearning(widget.id), // Gunakan widget.id
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.nunito(fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text(
                'No data found',
                style: GoogleFonts.nunito(fontSize: 16),
              ),
            );
          }

          final learning = snapshot.data!.data;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  learning?.title ?? 'No Title',
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'By: ${learning?.createdBy ?? 'Unknown'}',
                  style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Text(
                  'Created At: ${learning?.createdAt ?? 'Unknown'}',
                  style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 20),
                if (learning?.content != null)
                  Expanded(
                    child: SmartRefresher(
                      controller: _refreshController,
                      enablePullDown: true,
                      header: const WaterDropHeader(),
                      onLoading: _onLoading,
                      onRefresh: _onRefresh,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Image.network(
                                _extractImageUrl(learning!.content!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Text(
                                      'Failed to load image',
                                      style: GoogleFonts.nunito(fontSize: 16),
                                    ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              _stripHtmlIfNeeded(learning.content!),
                              style: GoogleFonts.nunito(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (learning?.fileUpload != null)
                  TextButton.icon(
                    onPressed: () async {
                      final url = _getFileUrl(learning!.fileUpload!);
                      await _requestPermissions();
                      try {
                        await widget.downloader.downloadMedia(context, url);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Download started for $url')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not download file')),
                        );
                      }
                    },
                    icon: Icon(Icons.file_download),
                    label: Text('Download Attachment'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onLoading() {
    _refreshController.loadComplete(); // after data returned, set the footer state to idle
  }

  void _onRefresh() {
    HapticFeedback.lightImpact();
    setState(() {
      _refreshController.refreshCompleted();
    });
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer(
            color: Colors.grey.shade300,
            duration: const Duration(seconds: 2),
            interval: const Duration(seconds: 1),
            child: Container(
              width: double.infinity,
              height: 30,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Shimmer(
            color: Colors.grey.shade300,
            duration: const Duration(seconds: 2),
            interval: const Duration(seconds: 1),
            child: Container(
              width: 100,
              height: 20,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Shimmer(
            color: Colors.grey.shade300,
            duration: const Duration(seconds: 2),
            interval: const Duration(seconds: 1),
            child: Container(
              width: 150,
              height: 20,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Shimmer(
            color: Colors.grey.shade300,
            duration: const Duration(seconds: 2),
            interval: const Duration(seconds: 1),
            child: Container(
              width: double.infinity,
              height: 200,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Shimmer(
            color: Colors.grey.shade300,
            duration: const Duration(seconds: 2),
            interval: const Duration(seconds: 1),
            child: Container(
              width: double.infinity,
              height: 100,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Shimmer(
            color: Colors.grey.shade300,
            duration: const Duration(seconds: 2),
            interval: const Duration(seconds: 1),
            child: Container(
              width: double.infinity,
              height: 40,
              color: Colors.white,
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
    final regex = RegExp(r'<[^>]*>');
    return htmlString.replaceAll(regex, '');
  }
}
