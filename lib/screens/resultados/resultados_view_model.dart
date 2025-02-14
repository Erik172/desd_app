import 'dart:async';
import 'package:desd_app/services/result_service.dart';
import 'package:desd_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResultadosViewModel extends ChangeNotifier {
  final BuildContext context;
  final ResultService resultService = ResultService();
  late final UserService userService;
  final ScrollController scrollController = ScrollController();
  List<dynamic> results = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  int totalResults = 0;
  Timer? timer;
  int? userId;

  ResultadosViewModel(this.context) {
    userService = UserService(context: context);
    _initialize();
  }

  Future<void> _initialize() async {
    final user = await userService.me();
    userId = user['id'];
    await fetchResults();

    scrollController.addListener(_onScroll);
    timer = Timer.periodic(const Duration(seconds: 2), (_) => updateResults());
  }

  void _onScroll() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && hasMore) {
      fetchMoreResults();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchResults() async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await resultService.fetchResults(context: context, page: 1, userId: userId);
      results = response['results'] ?? [];
      totalResults = response['total'] ?? 0;
      hasMore = currentPage < (response['pages'] ?? 0);
      currentPage = 1;
    } catch (e) {
      _handleError('Error fetching results: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreResults() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await resultService.fetchResults(context: context, page: currentPage + 1, userId: userId);
      totalResults = response['total'] ?? 0;
      results.addAll(response['results'] ?? []);
      hasMore = currentPage < (response['pages'] ?? 0);
      currentPage++;
    } catch (e) {
      _handleError('Error fetching more results: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateResults() async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await resultService.fetchResults(
        context: context,
        page: currentPage,
        perPage: 50,
        userId: userId,
      );

      totalResults = response['total_results'] ?? 0;
      final updatedResults = response['results'] ?? [];
      final startIndex = (currentPage - 1) * 50;
      final endIndex = startIndex + updatedResults.length;

      if (startIndex < results.length) {
        results.replaceRange(
          startIndex,
          endIndex < results.length ? endIndex.toInt() : results.length,
          updatedResults,
        );
      } else {
        results.addAll(updatedResults);
      }
      hasMore = currentPage < (response['pages'] ?? 0);
    } catch (e) {
      _handleError('Error updating results: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _handleError(String errorMessage) {
    print(errorMessage);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }

  String formatDate(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  String calculateDuration(String startDate, String endDate) {
    final DateTime startDateTime = DateTime.parse(startDate);
    final DateTime endDateTime = DateTime.parse(endDate);
    final Duration duration = endDateTime.difference(startDateTime);

    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    return '${hours}h ${minutes}m ${seconds}s';
  }

  Future<void> downloadResult({required String collectionId}) async {
    try {
      await resultService.downloadResult(context: context, collectionId: collectionId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resultado descargado con éxito.'),
        ),
      );
    } catch (e) {
      _handleError('Error downloading result: $e');
    }
  }

  Future<void> deleteResult({required String collectionId}) async {
    try {
      await resultService.deleteResult(context: context, collectionId: collectionId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resultado eliminado con éxito.'),
        ),
      );
    } catch (e) {
      _handleError('Error deleting result: $e');
    }
  }

  Color getStatusColor(String status, BuildContext context) {
    switch (status) {
      case 'UPLOADING':
        return Colors.purple;
      case 'COMPLETED':
        return Colors.green;
      case 'RUNNING':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}