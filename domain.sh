#!/bin/bash

if [ -z "$1" ]; then
  echo "⚠️  Harap masukkan nama service. Contoh: auth"
  exit 1
fi

SERVICE_NAME=$(echo "$1" | tr '[:upper:]' '[:lower:]')
DIR="lib/domain/$SERVICE_NAME"

# Capitalize first letter manually
CAP_NAME="$(tr '[:lower:]' '[:upper:]' <<< ${SERVICE_NAME:0:1})${SERVICE_NAME:1}"

mkdir -p "$DIR"

# 1. i_{service_name}_facade.dart
cat <<EOL > "$DIR/i_${SERVICE_NAME}_facade.dart"
import 'package:dartz/dartz.dart';
import '${SERVICE_NAME}_failure.dart';
import '${SERVICE_NAME}_model.dart';

abstract class I${CAP_NAME}Facade {
  Future<Either<${CAP_NAME}Failure, Iterable<${CAP_NAME}Model>>> load${CAP_NAME}s();
}
EOL

# 2. {service_name}_failure.dart
cat <<EOL > "$DIR/${SERVICE_NAME}_failure.dart"
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../common/exceptions/exceptions.dart';

part '${SERVICE_NAME}_failure.freezed.dart';

@freezed
class ${CAP_NAME}Failure with _\$${CAP_NAME}Failure {
  const factory ${CAP_NAME}Failure.notFound() = _NotFound;
  const factory ${CAP_NAME}Failure.emptyList() = _EmptyList;
  const factory ${CAP_NAME}Failure.unexpectedError([String? err]) = _UnexpectedError;
  const factory ${CAP_NAME}Failure.appException(AppException exception) = _AppException;
}
EOL

# 3. {service_name}_model.dart
cat <<EOL > "$DIR/${SERVICE_NAME}_model.dart"
import 'package:freezed_annotation/freezed_annotation.dart';
part '${SERVICE_NAME}_model.freezed.dart';

@freezed
class ${CAP_NAME}Model with _\$${CAP_NAME}Model {
  const ${CAP_NAME}Model._();

  const factory ${CAP_NAME}Model({
    required int id,
    required int created_at,
  }) = _${CAP_NAME}Model;

  factory ${CAP_NAME}Model.empty() => const ${CAP_NAME}Model(id: 0, created_at: 0);
}
EOL

echo "✅ File set created in $DIR:"
