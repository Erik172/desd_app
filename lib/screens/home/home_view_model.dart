import 'package:desd_app/services/result_service.dart';
import 'package:desd_app/services/user_service.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  late UserService userService;
  final ResultService resultService = ResultService();
  Map<String, dynamic> user = {};
  int numResultsPending = 0;
  int numResultsCompleted = 0;
  int numResultsRunning = 0;
  int numResultsFailed = 0;

  BuildContext context;

  HomeViewModel(this.context) {
    userService = UserService(context: context);
    userService.me().then((value) {
      user = value;
      notifyListeners();
    });
    fetchResults();
  }

  Future<void> fetchResults() async {
    final statuses = ['COMPLETED', 'PENDING', 'RUNNING', 'FAILED'];
    final results = await Future.wait(statuses.map((status) => resultService.fetchResults(context: context, userId: user['id'], status: status)));

    numResultsCompleted = results[0]['total'];
    numResultsPending = results[1]['total'];
    numResultsRunning = results[2]['total'];
    numResultsFailed = results[3]['total'];
    
    notifyListeners();
  }
}