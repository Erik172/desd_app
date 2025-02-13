import 'package:desd_app/services/result_service.dart';
import 'package:desd_app/services/user_service.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  late UserService userService;
  final ResultService resultService = ResultService();
  Map<String, dynamic> userInfo = {};
  int numResultsPending = 0;
  int numResultsCompleted = 0;
  int numResultsRunning = 0;
  int numResultsFailed = 0;
  int numResultsUploading = 0;
  int? userId;

  BuildContext context;

  HomeViewModel(this.context) {
    userService = UserService(context: context);
    userService.me().then((user) {
      userId = user['id'];
      userInfo = user;
      fetchResults();
    });
  }

  Future<void> fetchResults() async {
    final statuses = ['COMPLETED', 'PENDING', 'RUNNING', 'FAILED', 'UPLOADING'];
    final results = await Future.wait(statuses.map((status) => resultService.fetchResults(context: context, userId: userId, status: status)));

    numResultsCompleted = results[0]['total_results'];
    numResultsPending = results[1]['total_results'];
    numResultsRunning = results[2]['total_results'];
    numResultsFailed = results[3]['total_results'];
    numResultsUploading = results[4]['total_results'];
    
    notifyListeners();
  }
}