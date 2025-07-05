if [ -z "$1" ]; then
  echo "⚠️  Harap masukkan nama service. Contoh: auth"
  exit 1
fi

SERVICE_NAME=$(echo "$1" | tr '[:upper:]' '[:lower:]')
DIR="lib/infrastructure/$SERVICE_NAME"
DIR_MODELS="lib/infrastructure/$SERVICE_NAME/models"
DIR_REMOTE="lib/infrastructure/$SERVICE_NAME/data_source"

# Capitalize first letter manually
CAP_NAME="$(tr '[:lower:]' '[:upper:]' <<< ${SERVICE_NAME:0:1})${SERVICE_NAME:1}"

mkdir -p "$DIR" "$DIR_MODELS" "$DIR_REMOTE"

# 1. {service_name}_repository.dart
cat <<EOL > "$DIR/${SERVICE_NAME}_repository.dart"
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/area/i_${SERVICE_NAME}_facade.dart';
import '../../../domain/area/${SERVICE_NAME}_failure.dart';
import '../../../domain/area/${SERVICE_NAME}_model.dart';
import 'data_source/${SERVICE_NAME}_remote_provider.dart';

@Injectable(as: I${CAP_NAME}Facade)
class ${CAP_NAME}Repository implements I${CAP_NAME}Facade {
  final ${CAP_NAME}RemoteProvider remoteProvider;

  ${CAP_NAME}Repository(this.remoteProvider);

  @override
  Future<Either<${CAP_NAME}Failure, Iterable<${CAP_NAME}Model>>> load${CAP_NAME}s({int page = 0, int size = 10}) async {
    final result = await remoteProvider.load${CAP_NAME}s();

    return result.fold(
      (failure) => left(failure),
      (res) {
        final result = res.map((data) => data.toDomain());
        return right(result);
      },
    );
  }
}
EOL

# 2. {service_name}_model.dart
cat <<EOL > "$DIR_MODELS/${SERVICE_NAME}_dtos.dart"
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../common/functions/app_function.dart';
import '../../../domain/${SERVICE_NAME}/${SERVICE_NAME}_model.dart';
import '${SERVICE_NAME}_boxes.dart';

part '${SERVICE_NAME}_dtos.freezed.dart';
part '${SERVICE_NAME}_dtos.g.dart';

@freezed
class ${CAP_NAME}ModelDto with _\$${CAP_NAME}ModelDto {
  const ${CAP_NAME}ModelDto._();

  const factory ${CAP_NAME}ModelDto({
    int? id,
    String? created_at,
  }) = _${CAP_NAME}ModelDto;

  factory ${CAP_NAME}ModelDto.fromJson(Map<String, dynamic> json) => _\$${CAP_NAME}ModelDtoFromJson(json);

  factory ${CAP_NAME}ModelDto.fromEntity(${CAP_NAME}Entity entity) {
    return ${CAP_NAME}ModelDto(
      id: entity.id,
      created_at: entity.created_at,
    );
  }

  ${CAP_NAME}Entity toEntity() => ${CAP_NAME}Entity(
        id: id ?? 0,
        created_at: created_at,
      );

  factory ${CAP_NAME}ModelDto.fromDomain(${CAP_NAME}Model model) {
    return ${CAP_NAME}ModelDto(
      id: model.id,
      created_at: epochToDateISO(model.created_at),
    );
  }

  ${CAP_NAME}Model toDomain() => ${CAP_NAME}Model(
        id: id ?? 0,
        created_at: dateISOToEpoch(created_at ?? ''),
      );
}
EOL

# 3. {service_name}_boxes.dart
cat <<EOL > "$DIR_MODELS/${SERVICE_NAME}_boxes.dart"
import 'package:objectbox/objectbox.dart';

@Entity()
class ${CAP_NAME}Entity {
  @Id(assignable: true)
  int id = 0;
  String? created_at;

  ${CAP_NAME}Entity({
    this.id = 0,
    this.created_at,
  });
}
EOL

# 4. {service_name}_remote_provider.dart
cat <<EOL > "$DIR_REMOTE/${SERVICE_NAME}_remote_provider.dart"
import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../common/exceptions/exceptions.dart';
import '../../../common/api/api_client.dart';
import '../../../domain/${SERVICE_NAME}/${SERVICE_NAME}_failure.dart';
import '../models/${SERVICE_NAME}_dtos.dart';

@injectable
class ${CAP_NAME}RemoteProvider {
  final ApiClient _apiClient;
  ${CAP_NAME}RemoteProvider(ApiClient apiClient) : _apiClient = apiClient;

  Future<Either<${CAP_NAME}Failure, Iterable<${CAP_NAME}ModelDto>>> load${CAP_NAME}s() async {
    String url = '\$baseUrl/--';

    try {
      final response = await _apiClient.get(
        url,
        headers: {
          'Accept': 'application/json',
          // 'Authorization': 'Bearer \${getToken().bearer_token}', // put token here
        },
        // followRedirects: false,
        // validateStatus: (status) => status! < 500,
      );

      if (response.statusCode == 200) {
        log('response: \${jsonEncode(response.data)}');
      }
    } on AppException catch (exception) {
      return left(${CAP_NAME}Failure.appException(exception));
    }
    return left(const ${CAP_NAME}Failure.unexpectedError());
  }
}

EOL