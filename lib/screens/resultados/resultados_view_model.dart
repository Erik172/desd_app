// ignore_for_file: use_build_context_synchronously

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
    userService.me().then((user) {
      userId = user['id'];
      fetchResults(); // Fetch results for the new user
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && hasMore) {
        fetchMoreResults();
      }
    });

    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      updateResults();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  /// Obtiene los resultados de manera asíncrona.
  /// 
  /// Si la carga ya está en progreso (`isLoading` es verdadero), la función retorna inmediatamente.
  /// 
  /// La función establece `isLoading` a verdadero y notifica a los oyentes antes de intentar
  /// obtener los resultados desde el servicio `resultService`. Si la solicitud es exitosa,
  /// actualiza `totalResults`, `results` y `hasMore` con los datos obtenidos.
  /// 
  /// En caso de error, imprime un mensaje de error en la consola.
  /// 
  /// Finalmente, establece `isLoading` a falso y notifica a los oyentes.
  /// 
  /// Excepciones:
  /// - Cualquier excepción lanzada durante la obtención de resultados se captura y se imprime.
  Future<void> fetchResults() async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await resultService.fetchResults(context: context, page: 1, userId: userId);
      results = response['results']; // Actualizar la lista de resultados
      totalResults = response['total'];
      hasMore = currentPage < response['pages'];
      currentPage = 1;
    } catch (e) {
      print('Error fetching results: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene más resultados de forma asíncrona.
  ///
  /// Si ya se está cargando (`isLoading` es verdadero) o no hay más resultados
  /// (`hasMore` es falso), la función retorna inmediatamente.
  ///
  /// La función establece `isLoading` a verdadero y notifica a los oyentes.
  /// Luego intenta obtener más resultados del servicio `resultService` usando
  /// la página siguiente (`currentPage + 1`) y un número fijo de resultados por
  /// página (`perPage: 50`).
  ///
  /// Si la solicitud es exitosa, actualiza `totalResults` con el total de
  /// resultados obtenidos, agrega los nuevos resultados a la lista `results`,
  /// actualiza `hasMore` para indicar si hay más páginas disponibles y
  /// aumenta `currentPage`.
  ///
  /// Si ocurre un error durante la solicitud, se imprime un mensaje de error.
  ///
  /// Finalmente, establece `isLoading` a falso y notifica a los oyentes.
  Future<void> fetchMoreResults() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await resultService.fetchResults(context: context, page: currentPage + 1, userId: userId);
      totalResults = response['total'];
      results.addAll(response['results']); // Agregar más resultados a la lista
      hasMore = currentPage < response['pages'];
      currentPage++;
    } catch (e) {
      print('Error fetching more results: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza los resultados obtenidos del servicio de resultados.
  /// 
  /// Esta función se encarga de obtener los resultados de la página actual
  /// y actualizar la lista de resultados visibles, manteniendo las páginas
  /// anteriores intactas. Si ya se está cargando, la función retorna 
  /// inmediatamente.
  /// 
  /// La función realiza las siguientes acciones:
  /// - Establece el estado de carga a `true` y notifica a los oyentes.
  /// - Intenta obtener los resultados de la página actual desde el servicio.
  /// - Actualiza el total de resultados y los resultados visibles.
  /// - Maneja cualquier error que ocurra durante la obtención de resultados.
  /// - Establece el estado de carga a `false` y notifica a los oyentes.
  /// 
  /// En caso de error, se imprime un mensaje de error en la consola.
  Future<void> updateResults() async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      // Obtén solo la página actual y los resultados necesarios para ella
      final response = await resultService.fetchResults(
        context: context,
        page: currentPage,
        perPage: 50, // Ajusta este valor según la cantidad que se muestra por página
        userId: userId,
      );

      totalResults = response['total_results'];
      // Actualiza los resultados visibles, manteniendo las páginas anteriores intactas
      final updatedResults = response['results'];
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
      hasMore = currentPage < response['pages'];
    } catch (e) {
      print('Error updating results: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String formatDate(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  /// Calcula la duración entre dos fechas dadas en formato de cadena.
  ///
  /// Toma dos fechas en formato de cadena, las convierte a objetos DateTime,
  /// calcula la diferencia entre ellas y devuelve la duración en un formato
  /// legible de horas, minutos y segundos.
  ///
  /// Parámetros:
  /// - `startDate`: La fecha de inicio en formato de cadena (por ejemplo, "2023-01-01T12:00:00").
  /// - `endDate`: La fecha de fin en formato de cadena (por ejemplo, "2023-01-01T14:30:45").
  ///
  /// Retorna:
  /// - Una cadena que representa la duración en el formato 'Xh Ym Zs', donde X
  ///   es el número de horas, Y es el número de minutos y Z es el número de segundos.
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
    await resultService.downloadResult(context: context, collectionId: collectionId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resultado descargado con éxito.'),
      ),
    );
  }

  Future<void> deleteResult({required collectionId}) async {
    await resultService.deleteResult(context: context, collectionId: collectionId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resultado eliminado con éxito.'),
      ),
    );
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