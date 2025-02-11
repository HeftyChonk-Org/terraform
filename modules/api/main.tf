data "aws_iam_policy_document" "api_gateway_assume_role" {
  count = var.enable_account_logging ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "api_account_role" {
  count              = var.enable_account_logging ? 1 : 0
  name               = "AWSAPIGatewayPushToCloudWatchLogsRole"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume_role.0.json
}

resource "aws_iam_role_policy_attachment" "main" {
  count      = var.enable_account_logging ? 1 : 0
  role       = aws_iam_role.api_account_role.0.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "api_account" {
  count               = var.enable_account_logging ? 1 : 0
  cloudwatch_role_arn = aws_iam_role.api_account_role.0.arn
}

resource "aws_api_gateway_rest_api" "api" {
  name              = "${var.global_variables.prefix}-api"
  put_rest_api_mode = "merge"
  body              = file("${path.root}/assets/api/api.json")

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_rest_api.api]
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "api_access_log" {
  name              = "API-Gateway-Access-Logs_${aws_api_gateway_rest_api.api.id}/${terraform.workspace}"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_api_gateway_stage" "api_stage" {
  depends_on    = [aws_api_gateway_deployment.api_deployment]
  stage_name    = terraform.workspace
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  variables = {
    "dynamoDBMainTableName"   = var.blog_table_name
    "dynamoDBTagRefTableName" = var.tag_ref_table_name
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_access_log.arn
    format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime]\"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.error.responseType $context.responseLength $context.requestId $context.extendedRequestId"
  }
}

resource "aws_api_gateway_api_key" "api_key" {
  name = "${var.global_variables.prefix}-api-key"
}

resource "aws_api_gateway_usage_plan" "api_usage_plan" {
  name        = "${var.global_variables.prefix}-usage-plan"
  description = "API Usage Plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.api_stage.stage_name
  }

  throttle_settings {
    burst_limit = 50
    rate_limit  = 100
  }
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_usage_plan.id
}
