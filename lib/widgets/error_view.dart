import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

String friendlyErrorMessage(Object? error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'La conexión tardó demasiado. Revisa tu red e intenta de nuevo.';
      case DioExceptionType.connectionError:
        return 'Parece que no hay internet.';
      case DioExceptionType.badResponse:
        return 'No pudimos cargar los datos. Intenta más tarde.';
      default:
        return 'Algo salió mal. Intenta de nuevo.';
    }
  }
  return 'Algo salió mal. Intenta de nuevo.';
}

class ErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            friendlyErrorMessage(error),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
