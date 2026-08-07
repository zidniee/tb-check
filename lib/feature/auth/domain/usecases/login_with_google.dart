import 'package:dartz/dartz.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/auth_response_dto.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogleUseCase {
  final AuthRepository repository;

  LoginWithGoogleUseCase(this.repository);

  Future<Either<ApiException, AuthResponseDTO>> call() async {
    return await repository.loginWithGoogle();
  }
}
